#!/usr/bin/tclsh
# Number of methods per class

set methodsPerClass [getParameter "method-per-class" 10]

set vtype {
	public
	protected
	private
}

foreach f [getSourceFileNames] {
	set state "global"
	set visibility "none"
	set method "regular"
	foreach t [getTokens $f 1 0 -1 -1 {}] {
		set lineNumber [lindex $t 1]
		set token [lindex $t 3]
		if {$state == "global" && $token == "class"} {
			set state "class"
			set className "unknown"
		} elseif {$state == "class" && $token == "identifier"} {
			if {$className == "unknown"} {
				set className [lindex $t 0]
			}
		} elseif {$state == "class" && $token == "leftbrace"} {
			set state "inclass"
			set level 0
			set methods 0
		} elseif {$state == "inclass" && $token == "identifier" && [lindex $t 0] == $className} {
			set method "ctor"
		} elseif {$state == "inclass" && $token == "semicolon"} {
			set method "regular"
		} elseif {$state == "inclass" && $token == "leftbrace"} {
			incr level
		} elseif {$state == "inclass" && $token == "leftparen"} {
			set state "args"
			set alevel 0
			if {$visibility == "public" && $method == "regular"} {
				incr methods
			}
		} elseif {$state == "inclass" && [lsearch $vtype $token] != -1} {
			set visibility $token
		} elseif {$state == "args" && $token == "leftparen"} {
			incr alevel
		} elseif {$state == "args" && $token == "rightparen"} {
			if {$alevel == 0} {
				set state "inclass"
			} else {
				incr alevel -1
			}
		} elseif {$state == "inclass" && $token == "rightbrace"} {
			if {$level == 0} {
				set state "class"
				if {$methods > $methodsPerClass} {
					report $f $lineNumber "Class '$className' have $methods public method ($methodsPerClass max)."
				}
			} else {
				incr level -1
			}
		} elseif {$state == "class" && $token == "semicolon"} {
			set state "global"
		}
	}
}
