#!/usr/bin/tclsh
# Number of methods per class

set linesPerMethod [getParameter "lines-per-method" 50]

foreach f [getSourceFileNames] {
	set state "global"
	set glevel 0
	foreach t [getTokens $f 1 0 -1 -1 {}] {
		set lineNumber [lindex $t 1]
		set token [lindex $t 3]
		if {$state == "global" && $token == "leftbrace"} {
			incr glevel
		} elseif {$state == "global" && $token == "rightbrace"} {
			incr glevel -1
		} elseif {$state == "global" && $token == "identifier"} {
			set methodName [lindex $t 0]
		} elseif {$state == "global" && $token == "leftparen"} {
			# Обработка списка аргументов
			set alevel 0
			set state "args"
		} elseif {$state == "args" && $token == "leftparen"} {
			incr alevel
		} elseif {$state == "args" && $token == "rightparen" && $alevel == 0} {
			set state "method"
		} elseif {$state == "args" && $token == "rightparen"} {
			incr alevel -1
		} elseif {$state == "method" && $token == "semicolon"} {
			# Обработка начала тела функции
			set state "global"
		} elseif {$state == "method" && $token == "leftbrace"} {
			set lineStart $lineNumber
			set mlevel 0
			set state "inmethod"
		} elseif {$state == "inmethod" && $token == "leftbrace"} {
			# Обработка тела функции
			incr mlevel
		} elseif {$state == "inmethod" && $token == "rightbrace" && $mlevel == 0} {
			# выход из тела функции
			set lineBody [expr $lineNumber - $lineStart]
			if {$lineBody > $linesPerMethod} {
				report $f $lineNumber "Method '$methodName' have $lineBody lines in the body ($linesPerMethod max)."
			}
			set state "global"
		} elseif {$state == "inmethod" && $token == "rightbrace"} {
			incr mlevel -1
		}
	}
}
