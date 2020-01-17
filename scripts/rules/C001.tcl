#!/usr/bin/tclsh
# Number of methods per class

set methodsPerClass [getParameter "method-per-class" 3]

foreach f [getSourceFileNames] {
	set state "global"
	foreach t [getTokens $f 1 0 -1 -1 {}] {
		set lineNumber [lindex $t 1]
		set token [lindex $t 3]
		if {$state == "global" && $token == "class"} {
			set state "class"
		} elseif {$state == "class" && $token == "leftbrace"} {
			set state "inclass"
			set level 0
			set methods 0
		} elseif {$state == "inclass" && $token == "leftparen"} {
			set state "args"
			set alevel 0
			incr methods
		} elseif {$state == "args" && $token == "leftparen"} {
			incr alevel
		} elseif {$state == "args" && $token == "rightparen"} {
			if {$alevel == 0} {
				set state "inclass"
			} else {
				decr alevel
			}
		} elseif {$state == "inclass" && $token == "rightbrace"} {
			if {$level == 0} {
				set state "class"
				if {$methods > $methodsPerClass} {
					report $f $lineNumber "Class can have max $methodsPerClass methods, but have $methods."
				}
			} else {
				decr level
			}
		} elseif {$state == "class" && $token == "semicolon"} {
			set state "global"
		}
	}
}
