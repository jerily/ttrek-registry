#!/usr/bin/env python3
"""Build-independent integration check: smoke.py /absolute/install/prefix.

Creates an isolated PostgreSQL cluster, installs OpenACS through its web
installer, restarts it, and verifies the schema and application response.
Uses a private Unix socket for PostgreSQL and loopback HTTP for NaviServer.
Stops both processes on success or failure; retains failed runs for diagnosis.
"""

import getpass
import os
from pathlib import Path
import secrets
import shlex
import shutil
import socket
import subprocess
import sys
import tempfile
import time
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import urlopen


def main():
    if len(sys.argv) != 2:
        raise SystemExit("Usage: smoke.py INSTALL_PREFIX")
    prefix = Path(sys.argv[1]).resolve()
    pg = prefix / "postgresql/bin"
    work = Path(tempfile.mkdtemp(prefix="ttrek-openacs-smoke-"))
    sock = work / "socket"
    sock.mkdir()
    site = work / "site"
    pg_started = False
    server = None
    success = False
    print(f"Temporary instance: {work}", flush=True)

    with (work / "commands.log").open("w") as command_log, \
         (work / "naviserver.log").open("w") as server_log:

        def run(*args):
            return subprocess.run(
                [str(arg) for arg in args], check=True, text=True,
                stdout=command_log, stderr=subprocess.STDOUT, timeout=90,
            )

        def sql(statement):
            return subprocess.check_output(
                [str(pg / "psql"), "-X", "-h", str(sock), "-p", "5432",
                 "-d", "openacs", "-v", "ON_ERROR_STOP=1", "-Atc", statement],
                text=True, timeout=30,
            ).strip()

        def stop_server():
            if server is not None and server.poll() is None:
                server.terminate()
                try:
                    server.wait(timeout=30)
                except subprocess.TimeoutExpired:
                    server.kill()
                    server.wait(timeout=10)

        try:
            run(pg / "initdb", "-D", work / "db", "--encoding=UTF8",
                "--no-locale", "--auth-local=peer", "--auth-host=reject")
            options = shlex.join(["-k", str(sock), "-p", "5432", "-c", "listen_addresses="])
            run(pg / "pg_ctl", "-D", work / "db", "-l", work / "postgres.log",
                "-o", options, "-w", "start")
            pg_started = True
            run(pg / "createdb", "-h", sock, "-p", "5432", "--encoding=UTF8", "openacs")
            sql("CREATE EXTENSION hstore; CREATE EXTENSION pgcrypto")
            assert sql("SELECT 'k=>v'::hstore -> 'k'") == "v"
            print("PostgreSQL cluster and extensions: PASS", flush=True)

            run(prefix / "bin/openacs-create-instance", site)
            # Recreating an instance must fail without modifying existing files.
            marker = site / "keep.txt"
            marker.write_text("existing instance\n")
            retry = subprocess.run(
                [str(prefix / "bin/openacs-create-instance"), str(site)],
                stdout=command_log, stderr=subprocess.STDOUT, timeout=10,
            )
            assert retry.returncode != 0 and marker.read_text() == "existing instance\n"

            with socket.socket() as probe:
                probe.bind(("127.0.0.1", 0))
                port = probe.getsockname()[1]
            url = f"http://127.0.0.1:{port}/"
            env = {key: value for key, value in os.environ.items()
                   if not key.startswith("oacs_")}
            env.update(PGHOST=str(sock), oacs_db_host="localhost", oacs_db_port="5432",
                       oacs_db_name="openacs", oacs_db_user=getpass.getuser(),
                       oacs_httpport=str(port), oacs_hostname="127.0.0.1",
                       oacs_ipaddress="127.0.0.1", oacs_httpsport="",
                       oacs_smtpdport="", oacs_nscpport="")
            command = [str(prefix / "bin/nsd"), "-f", "-t",
                       str(site / "etc/ttrek-config.tcl")]

            def start_server():
                return subprocess.Popen(command, env=env, cwd=site,
                                        stdout=server_log, stderr=subprocess.STDOUT)

            def wait_for_page():
                deadline = time.monotonic() + 90
                while time.monotonic() < deadline:
                    if server.poll() is not None:
                        raise RuntimeError(f"NaviServer exited: {server.returncode}")
                    try:
                        with urlopen(url, timeout=5) as response:
                            return response.read().decode("utf-8")
                    except HTTPError as error:
                        (work / "http-error.html").write_bytes(error.read())
                        raise RuntimeError(f"NaviServer returned HTTP {error.code}") from error
                    except URLError:
                        time.sleep(0.25)
                raise RuntimeError("NaviServer did not serve a page within 90 seconds")

            server = start_server()
            page = wait_for_page()
            (work / "installer.html").write_text(page)
            assert "driver is correctly installed and configured" in page
            assert "Start installation" in page
            print("OpenACS installer prerequisites: PASS", flush=True)

            password = secrets.token_urlsafe(24)
            form = dict(email="admin@example.invalid", first_names="Recipe", last_name="Test",
                        password=password, password_confirmation=password, system_url=url,
                        system_name="ttrek OpenACS smoke", publisher_name="Recipe test")
            with urlopen(url + "installer/install", data=urlencode(form).encode(), timeout=240) as response:
                installation = response.read().decode("utf-8")
            (work / "installation.html").write_text(installation)
            assert "Installation finished" in installation
            server.wait(timeout=60)
            assert server.returncode == 0
            assert sql("SELECT count(*) FROM apm_packages WHERE package_key='acs-kernel'") == "1"
            assert sql("SELECT count(*) FROM parties WHERE email='admin@example.invalid'") == "1"
            print("OpenACS schema and administrator installation: PASS", flush=True)

            server = start_server()
            page = wait_for_page()
            (work / "installed.html").write_text(page)
            assert "ttrek OpenACS smoke" in page
            assert "OpenACS Installer" not in page
            run(pg / "pg_dump", "-h", sock, "-p", "5432", "-d", "openacs",
                "--schema-only", "-f", work / "schema.sql")
            assert (work / "schema.sql").stat().st_size > 1000
            print("OpenACS restart, HTTP response, and pg_dump: PASS", flush=True)
            success = True
        finally:
            stop_server()
            if pg_started:
                run(pg / "pg_ctl", "-D", work / "db", "-m", "fast", "-w", "stop")
            if success:
                shutil.rmtree(work)
            else:
                print(f"Failed run retained at {work}", file=sys.stderr)


if __name__ == "__main__":
    main()
