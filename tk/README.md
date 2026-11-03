# Tk examples

Tk adds desktop windows and widgets to Tcl. These recipes provide
[Tk 8.6.18 and 9.1.0](https://www.tcl-lang.org/software/tcltk/download.html),
each with the matching Tcl release line.

On Debian/Ubuntu, install the build prerequisites first:

```sh
sudo apt install build-essential pkg-config libx11-dev libxft-dev libharfbuzz-dev
```

HarfBuzz is needed for Tk 9.1's default bidirectional text support. The examples
need a graphical desktop with an X display (`DISPLAY` set); Wayland desktops
can use XWayland.

## Install

Set `REGISTRY` to your registry checkout, then create a project:

```sh
REGISTRY=/absolute/path/to/ttrek-registry
mkdir tk-project
cd tk-project
ttrek init -y
ttrek install -registry "$REGISTRY" tk@9.1.0
```

For Tk 8.6, install `tk@8.6.18` instead and use `wish8.6` below.
Use separate project directories to try both release lines.

## Run the examples

From the project directory, run one command at a time and close its window
before starting the next:

```sh
ttrek run wish9.1 "$REGISTRY/tk/tasks.tcl"
ttrek run wish9.1 "$REGISTRY/tk/editor.tcl"
ttrek run wish9.1 "$REGISTRY/tk/chart.tcl"
```

- **Tasks:** add tasks, choose a priority, and toggle completion with Space.
  Demonstrates themed form controls and a table. Tasks last for this session.
- **Editor:** open and save UTF-8 text files, undo edits, and use file dialogs.
  Prompts before discarding unsaved changes.
- **Chart:** watch simulated data, adjust the sampling speed, and pause/resume.
  Demonstrates canvas drawing and timers while the window stays responsive.

The scripts work with both versions and require only Tcl/Tk. They stay in this
checkout; copy them anywhere to experiment. The installed interpreters are
named `wish9.1` and `wish8.6`.

To explore Tk's installed widget gallery (either version):

```sh
ttrek run -package tk -script demo-widgets
```

The gallery command requires a `ttrek` version with `run -package` support.
