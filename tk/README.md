# Tk examples

Tk adds desktop windows and widgets to Tcl. These recipes provide
[Tk 8.6.18 and 9.1.0](https://www.tcl-lang.org/software/tcltk/download.html),
each with the matching Tcl release line.

On Debian/Ubuntu, install the build prerequisites first:

```sh
sudo apt install build-essential pkg-config libx11-dev libxft-dev libharfbuzz-dev
```

Both recipes use system X11, Xft, Fontconfig, and FreeType libraries. Tk 9.1
also requires system HarfBuzz development files; Tk 8.6 does not need HarfBuzz.
The registry supplies Tcl and zlib. Install the development packages above
before running `ttrek install`; runtime libraries alone are insufficient.
The examples need a graphical desktop with an X display (`DISPLAY` set);
Wayland desktops can use XWayland.

## Install

Sync the default registry, then create a project and install the latest Tk:

```sh
ttrek sync
mkdir tk-project
cd tk-project
ttrek init -y
ttrek install tk -y
```

For Tk 8.6, run `ttrek install tk@8.6.18 -y` instead and use `wish8.6` below.
Use separate project directories to try both release lines.

To use a development checkout, pass `-registry /path/to/ttrek-registry` to
`ttrek init` or `ttrek install`. A project with a saved registry path continues
to use that registry instead of the synced default.

## Run the examples

From the project directory, run one command at a time and close its window
before starting the next:

```sh
REGISTRY="$HOME/.local/ttrek-registry" # Or your development checkout.
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
