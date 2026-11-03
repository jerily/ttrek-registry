# Simulated telemetry, drawn on a resizable canvas without blocking the UI.
# Use after callbacks for small chunks of work; never sleep in a GUI callback.
package require Tk

namespace eval chart {
    variable samples {}
    variable running 1
    variable interval 150
    variable timer ""
    variable phase 0.0
    variable status "Waiting for a sample"
}

proc chart::draw {} {
    variable samples
    set width [winfo width .plot]
    set height [winfo height .plot]
    if {$width < 100 || $height < 100} { return }
    .plot delete all
    set left 45
    set right [expr {$width - 20}]
    set top 20
    set bottom [expr {$height - 30}]
    foreach value {0 25 50 75 100} {
        set y [expr {$bottom - $value * ($bottom - $top) / 100.0}]
        .plot create line $left $y $right $y -fill #dce2e8
        .plot create text [expr {$left - 8}] $y -text $value -anchor e -fill #475569
    }
    .plot create text $left [expr {$height - 12}] -text "Most recent 100 samples" -anchor w
    set points {}
    set index [expr {100 - [llength $samples]}]
    foreach value $samples {
        lappend points [expr {$left + $index * ($right - $left) / 99.0}] \
            [expr {$bottom - $value * ($bottom - $top) / 100.0}]
        incr index
    }
    if {[llength $points] >= 4} {
        .plot create line {*}$points -fill #2563eb -width 3 -tags signal
    }
}

proc chart::tick {} {
    variable samples
    variable running
    variable interval
    variable timer
    variable phase
    variable status
    set timer ""
    if {!$running} { return }
    set phase [expr {$phase + 0.15}]
    set value [expr {50 + 30 * sin($phase) + 10 * (rand() - 0.5)}]
    lappend samples $value
    set samples [lrange $samples end-99 end]
    set status [format "Simulated reading: %.1f / 100" $value]
    draw
    set timer [after [expr {int($interval)}] chart::tick]
}

proc chart::toggle {} {
    variable running
    variable timer
    if {$running} {
        set running 0
        after cancel $timer
        set timer ""
        .controls.toggle configure -text Resume
    } else {
        set running 1
        .controls.toggle configure -text Pause
        tick
    }
}

proc chart::quit {} {
    after cancel $::chart::timer
    destroy .
}

wm title . "Tk live chart - simulated data"
wm geometry . 760x420
wm minsize . 500 260
wm protocol . WM_DELETE_WINDOW chart::quit
ttk::frame .controls -padding 12
ttk::button .controls.toggle -text Pause -command chart::toggle
ttk::label .controls.label -text "Sample interval (50-500 ms)"
ttk::scale .controls.speed -from 50 -to 500 -variable ::chart::interval
pack .controls.toggle .controls.label -side left -padx 6
pack .controls.speed -side left -fill x -expand 1 -padx 6
canvas .plot -background white -highlightthickness 0
ttk::label .status -textvariable ::chart::status -padding 12
pack .controls -side top -fill x
pack .status -side bottom -fill x
pack .plot -fill both -expand 1
bind .plot <Configure> {chart::draw}
chart::tick
