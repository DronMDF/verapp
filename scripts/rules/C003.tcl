#!/usr/bin/tclsh
# Disable free code block

foreach f [getSourceFileNames] {
	set state "invalid"
	foreach t [getTokens $f 1 0 -1 -1 {}] {
		set lineNumber [lindex $t 1]
		set token [lindex $t 3]
		if {$token == "semicolon"} {
			set state "invalid"
		} elseif {$token == "leftbrace" && $state == "invalid"} {
			report $f $lineNumber "Invalid code block"
			set state "valid"
		} elseif {$token != "space" && $token != "space2" && $token != "newline"} {
			set state "valid"
		}
	}
}
