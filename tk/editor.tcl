# A small UTF-8 editor: menus, file dialogs, undo, and unsaved-change prompts.
package require Tk

namespace eval editor {
    variable path ""
}

proc editor::title {} {
    variable path
    set name [expr {$path eq "" ? "Untitled" : [file tail $path]}]
    set mark [expr {[.text edit modified] ? " *" : ""}]
    wm title . "$name$mark - Tk editor"
}

proc editor::save {{choosePath 0}} {
    variable path
    set target $path
    if {$choosePath || $target eq ""} {
        set target [tk_getSaveFile -parent . -defaultextension .txt \
            -filetypes {{{Text files} {.txt}} {{All files} *}}]
    }
    if {$target eq ""} { return 0 }
    if {[catch {
        set channel [open $target w]
        try {
            fconfigure $channel -encoding utf-8 -translation lf
            puts -nonewline $channel [.text get 1.0 end-1c]
        } finally {
            close $channel
        }
    } message]} {
        tk_messageBox -parent . -icon error -type ok -message "Could not save the file" -detail $message
        return 0
    }
    set path $target
    .text edit modified 0
    title
    return 1
}

proc editor::canDiscard {} {
    if {![.text edit modified]} { return 1 }
    set answer [tk_messageBox -parent . -icon question -type yesnocancel \
        -message "Save your changes first?"]
    switch -- $answer {
        yes { return [save] }
        no { return 1 }
        default { return 0 }
    }
}

proc editor::load {} {
    variable path
    if {![canDiscard]} { return }
    set target [tk_getOpenFile -parent . \
        -filetypes {{{Text files} {.txt .tcl .md}} {{All files} *}}]
    if {$target eq ""} { return }
    if {[catch {
        set channel [open $target r]
        try {
            fconfigure $channel -encoding utf-8
            set contents [read $channel]
        } finally {
            close $channel
        }
    } message]} {
        tk_messageBox -parent . -icon error -type ok -message "Could not open the file" -detail $message
        return
    }
    .text delete 1.0 end
    .text insert 1.0 $contents
    .text edit reset
    .text edit modified 0
    set path $target
    title
}

proc editor::quit {} {
    if {[canDiscard]} { destroy . }
}

wm geometry . 760x480
wm protocol . WM_DELETE_WINDOW editor::quit
menu .menu
. configure -menu .menu
menu .menu.file -tearoff 0
menu .menu.edit -tearoff 0
.menu add cascade -label File -menu .menu.file
.menu add cascade -label Edit -menu .menu.edit
.menu.file add command -label "Open..." -command editor::load
.menu.file add command -label Save -command editor::save
.menu.file add command -label "Save as..." -command {editor::save 1}
.menu.file add separator
.menu.file add command -label Quit -command editor::quit
.menu.edit add command -label Undo -command {catch {.text edit undo}}
.menu.edit add command -label Redo -command {catch {.text edit redo}}
.menu.edit add separator
foreach action {Cut Copy Paste} {
    .menu.edit add command -label $action -command [list event generate .text <<$action>>]
}
text .text -undo 1 -wrap word -font TkFixedFont -padx 12 -pady 12
ttk::scrollbar .scroll -orient vertical -command {.text yview}
.text configure -yscrollcommand {.scroll set}
ttk::label .hint -text "UTF-8 text | Open, edit, then Save | Undo and redo in the Edit menu" -padding 8
grid .text -row 0 -column 0 -sticky nsew
grid .scroll -row 0 -column 1 -sticky ns
grid .hint -row 1 -column 0 -columnspan 2 -sticky ew
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1
bind .text <<Modified>> {editor::title}
foreach {key command} {o editor::load s editor::save q editor::quit} {
    bind . <Control-$key> "$command; break"
    if {[tk windowingsystem] eq "aqua"} { bind . <Command-$key> "$command; break" }
}
editor::title
focus .text
