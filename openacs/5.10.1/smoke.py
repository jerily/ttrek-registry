#!/usr/bin/env python3
"""Build-independent integration check: smoke.py /absolute/project/directory [ttrek].

Runs the installed OpenACS package's named scripts to create an isolated PostgreSQL
cluster, installs OpenACS through its web installer, restarts it, and verifies
the schema and application response.
Uses a private Unix socket for PostgreSQL and loopback HTTP for NaviServer.
Stops both processes on success or failure; retains failed runs for diagnosis.
"""

import getpass
import os
from pathlib import Path
import secrets
import shutil
import signal
import socket
import subprocess
import sys
import tempfile
import time
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import urlopen


def main():
    if len(sys.argv) not in (2, 3):
        raise SystemExit("Usage: smoke.py PROJECT_DIR [TTREK]")
    ttrek = shutil.which(sys.argv[2] if len(sys.argv) == 3 else "ttrek")
    if ttrek is None:
        raise SystemExit("ttrek was not found; supply its path as the second argument")
    ttrek = str(Path(ttrek).resolve())
    project = Path(sys.argv[1]).resolve()
    prefix = project / "ttrek-venv/local"
    pg = prefix / "postgresql/bin"
    work = Path(tempfile.mkdtemp(prefix="ttrek-openacs-smoke-"))
    runtime = work / "openacs-local"
    sock = runtime / "socket"
    site = runtime / "site"
    env = {key: value for key, value in os.environ.items()
           if not key.startswith("oacs_") and key not in ("OACS_PREFIX", "OACS_RUNTIME")}
    env.update(OACS_RUNTIME=str(runtime), SHELL="/bin/sh", TTREK_NO_UPDATE_CHECK="1")
    server = None
    success = False
    print(f"Temporary instance: {work}", flush=True)

    with (work / "commands.log").open("w") as command_log, \
         (work / "naviserver.log").open("w") as server_log:

        def run(*args):
            return subprocess.run(
                [str(arg) for arg in args], check=True, text=True,
                stdout=command_log, stderr=subprocess.STDOUT, timeout=90,
                cwd=project, env=env,
            )

        def sql(statement):
            return subprocess.check_output(
                [str(pg / "psql"), "-X", "-h", str(sock), "-p", "55432",
                 "-U", getpass.getuser(), "-d", "openacs", "-v", "ON_ERROR_STOP=1", "-Atc", statement],
                text=True, timeout=30,
            ).strip()

        def database_running():
            return subprocess.run(
                [str(pg / "pg_ctl"), "-D", str(runtime / "db"), "status"],
                stdout=command_log, stderr=subprocess.STDOUT, timeout=10,
            ).returncode == 0

        def stop_server():
            if server is not None and server.poll() is None:
                # Signal ttrek, its script, and foreground NaviServer together,
                # as a terminal does for Ctrl-C. PostgreSQL has its own session.
                os.killpg(server.pid, signal.SIGINT)
                try:
                    server.wait(timeout=30)
                except subprocess.TimeoutExpired:
                    os.killpg(server.pid, signal.SIGKILL)
                    server.wait(timeout=10)
                deadline = time.monotonic() + 30
                while database_running() and time.monotonic() < deadline:
                    time.sleep(0.1)

        try:
            run(ttrek, "run", "-package", "openacs", "-script", "init-local")
            assert not database_running(), "init-local left PostgreSQL running"
            assert runtime.stat().st_mode & 0o777 == 0o700

            # Reinitialization and the helper must preserve existing instances.
            marker = site / "keep.txt"
            marker.write_text("existing instance\n")
            retry = subprocess.run(
                [ttrek, "run", "-package", "openacs", "-script", "init-local"], cwd=project, env=env,
                stdout=command_log, stderr=subprocess.STDOUT, timeout=10,
            )
            assert retry.returncode != 0 and marker.read_text() == "existing instance\n"
            assert not database_running()
            retry = subprocess.run(
                [str(prefix / "bin/openacs-create-instance"), str(site)],
                stdout=command_log, stderr=subprocess.STDOUT, timeout=10,
            )
            assert retry.returncode != 0 and marker.read_text() == "existing instance\n"

            with socket.socket() as probe:
                probe.bind(("127.0.0.1", 0))
                port = probe.getsockname()[1]
            url = f"http://127.0.0.1:{port}/"
            env.update(oacs_httpport=str(port), oacs_hostname="127.0.0.1",
                       oacs_ipaddress="127.0.0.1", oacs_httpsport="",
                       oacs_smtpdport="", oacs_nscpport="")
            command = [ttrek, "run", "-package", "openacs", "-script", "start-local"]

            def start_server():
                return subprocess.Popen(command, env=env, cwd=project, start_new_session=True,
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
            sql("CREATE EXTENSION pgcrypto")
            assert sql("SELECT 'k=>v'::hstore -> 'k'") == "v"
            assert sql("SHOW listen_addresses") == ""
            assert sql("SHOW unix_socket_directories") == str(sock)
            print("Named scripts, PostgreSQL cluster and extensions: PASS", flush=True)
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
            assert not database_running(), "start-local left PostgreSQL running after the installer"

            server = start_server()
            page = wait_for_page()
            assert sql("SELECT count(*) FROM apm_packages WHERE package_key='acs-kernel'") == "1"
            assert sql("SELECT count(*) FROM parties WHERE email='admin@example.invalid'") == "1"
            print("OpenACS schema and administrator installation: PASS", flush=True)

            (work / "installed.html").write_text(page)
            assert "ttrek OpenACS smoke" in page
            assert "OpenACS Installer" not in page
            run(pg / "pg_dump", "-h", sock, "-p", "55432", "-U", getpass.getuser(), "-d", "openacs",
                "--schema-only", "-f", work / "schema.sql")
            assert (work / "schema.sql").stat().st_size > 1000
            print("OpenACS restart, HTTP response, and pg_dump: PASS", flush=True)
            stop_server()
            assert not database_running(), "start-local left PostgreSQL running after Ctrl-C"
            print("Ctrl-C stops NaviServer and PostgreSQL: PASS", flush=True)
            success = True
        finally:
            stop_server()
            if database_running():
                run(pg / "pg_ctl", "-D", runtime / "db", "-m", "fast", "-w", "stop")
            if success:
                shutil.rmtree(work)
            else:
                print(f"Failed run retained at {work}", file=sys.stderr)


if __name__ == "__main__":
    main()
