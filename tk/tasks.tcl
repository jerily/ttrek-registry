# Run with wish8.6 or wish9.1. Tasks live only for this session.
# Demonstrates themed widgets, variable binding, a table, and keyboard events.
package require Tk

namespace eval tasks {
    variable title ""
    variable priority Normal
    variable status ""
}

proc tasks::summarize {} {
    set rows [.tasks children {}]
    set done 0
    foreach row $rows {
        if {[.tasks set $row state] eq "Done"} { incr done }
    }
    set ::tasks::status "$done of [llength $rows] tasks completed (session only)"
}

proc tasks::add {} {
    variable title
    variable priority
    set text [string trim $title]
    if {$text eq ""} { return }
    set row [.tasks insert {} end -values [list $text $priority Open]]
    .tasks selection set $row
    .tasks see $row
    set title ""
    summarize
    focus .entry.title
}

proc tasks::toggle {} {
    foreach row [.tasks selection] {
        set done [expr {[.tasks set $row state] eq "Open"}]
        .tasks set $row state [expr {$done ? "Done" : "Open"}]
        .tasks item $row -tags [expr {$done ? "done" : ""}]
    }
    summarize
}

proc tasks::remove {} {
    foreach row [.tasks selection] { .tasks delete $row }
    summarize
}

wm title . "Tk task list"
wm minsize . 560 300
ttk::frame .entry -padding 12
ttk::label .entry.label -text "Task"
ttk::entry .entry.title -textvariable ::tasks::title
ttk::combobox .entry.priority -textvariable ::tasks::priority \
    -values {Low Normal High} -state readonly -width 8
ttk::button .entry.add -text "Add task" -command tasks::add
grid .entry.label .entry.title .entry.priority .entry.add -padx 4 -sticky ew
grid columnconfigure .entry 1 -weight 1

ttk::treeview .tasks -columns {title priority state} -show headings -height 10
foreach {column label width} {title Task 340 priority Priority 90 state Status 90} {
    .tasks heading $column -text $label
    .tasks column $column -width $width
}
.tasks tag configure done -foreground #777777
ttk::scrollbar .scroll -orient vertical -command {.tasks yview}
.tasks configure -yscrollcommand {.scroll set}

ttk::frame .actions -padding 12
ttk::button .actions.toggle -text "Toggle completed" -command tasks::toggle
ttk::button .actions.remove -text "Remove selected" -command tasks::remove
pack .actions.toggle .actions.remove -side left -padx 4
ttk::label .status -textvariable ::tasks::status -padding {16 0 16 12}

grid .entry -row 0 -column 0 -columnspan 2 -sticky ew
grid .tasks -row 1 -column 0 -sticky nsew -padx {16 0}
grid .scroll -row 1 -column 1 -sticky ns -padx {0 16}
grid .actions -row 2 -column 0 -columnspan 2 -sticky ew
grid .status -row 3 -column 0 -columnspan 2 -sticky ew
grid columnconfigure . 0 -weight 1
grid rowconfigure . 1 -weight 1
bind .entry.title <Return> {tasks::add}
bind .tasks <space> {tasks::toggle; break}
bind .tasks <Delete> {tasks::remove}

foreach title {"Try adding a task" "Select a task and press Space" "Resize this window"} {
    set ::tasks::title $title
    tasks::add
}
