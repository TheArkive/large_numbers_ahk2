#Requires AutoHotkey v2.0-beta ; 64-bit

#Include _large_numbers.ahk

; =============================================================
; a few notes for experimentation
; =============================================================

; #define INT128_MAX 170141183460469231731687303715884105727 i128

; 97014118346046923173168730371588 <-- Win10 calc.exe max digits (32)

; =============================================================
; utility funcs for example
; =============================================================

calc(p*) {
    static op := Map("+","{NumpadAdd}"
                    ,"-","{NumpadSub}"
                    ,"*","{NumpadMult}"
                    ,"/","{NumpadDiv}"
                    ,"**","y")
    
    A_Clipboard := ""
    delay := 200
    SetTitleMatchMode 3
    If !WinExist("Calculator") {
        Run "calc.exe"
        WinWait "Calculator"
        Sleep delay
        SendInput "!2"
        Sleep delay
    }
    
    If !WinActive("Calculator") {
        WinActivate "Calculator"
        Sleep delay
        Sleep delay
    }
    
    SendInput "{Esc}"
    
    For i, val in p {
        if RegExMatch(val,"^(\+|\-|\*|/|\*\*)$")
            SendInput op[val]
        Else {
            (neg := (InStr(val,"-")=1)) ? val := SubStr(val,2) : ""
            SendInput val
            Sleep delay
            If neg
                SendInput "{F9}"
        }
        Sleep delay
    }
    SendInput "{Enter}"
    Sleep delay
    SendInput "^c"
    Sleep delay
    return A_Clipboard
}

diff() => (A_TickCount - _t)
disp(txt,_ahk_,_calc_) => txt "`n`n"
                        . "calc ▼ ▼ ▼`n"
                        . _ahk_ "`n"
                        . _calc_ "`n"
                        . "ahk ▲ ▲ ▲`n`n"
                        . "Time (ms): " diff() "`n`n"
                        . "Equal: " ((_ahk_=_calc_)?"true":"false")

; =============================================================

m := math(30) ; 30 decimal places, set m.dec after object creation



a := "70141183460469231731687303715"                ; example 1 (large addition)
b := "51730378613713296406438114107"
_calc := calc(a,"+",b), _t := A_TickCount
ahk := m.Add(a,b)
msgbox disp("Example 1`nLarge Addition",_calc,ahk)



a := "70141183460469231731687303715"                ; example 2 (large division)
b := "517303786"
_calc := calc(a,"/",b), _t := A_TickCount
ahk := m.Div(a,b)
msgbox disp("Example 2`nLarge Division",_calc,ahk)



a := 2                                              ; example 3 (2 ** 128)
b := 128
_calc := calc(a,"**",b), _t := A_TickCount
ahk := m.Exp(a,b)
Msgbox disp("Example 3`nExponents",_calc,ahk)



x := "170141183460469231731687303715884105727"      ; example 4 -> INT128_MAX to hex and back
_t := A_TickCount
t := m.DecToHex(x) ; make hex
y := m.HexToDec(t) ; convert back to decimal
msgbox "Example 4`nDec -> Hex -> Dec Conversion`n`n"
     . "INT128_MAX`n`ninput ▼ ▼ ▼`n" x "`n" y "`noutput ▲ ▲ ▲`n`nEqual: " (x=y) "`n`nHex: " t "`n`nTime (ms): " diff()



m.dec := 32                                         ; example 5 (long decimal)
a := 1
b := 76
_calc := calc(a,"/",b), _t := A_TickCount
ahk := m.Div(a,b)
msgbox disp("Example 5`nDivision - Long Decimal Result",_calc,ahk)



a := "21.00"                                        ; example 6 (simple decimals)
b := "0.01"
_calc := calc(a,"-",b), _t := A_TickCount
ahk := m.Sub(a,b)
msgbox disp("Example 6`nSimple decimal math",_calc,ahk)



m.dec := 29                                         ; example 7 (large decimal division)
a := "701411.83460469231731687303715"
b := "1411.83460469231"
_calc := calc(a,"/",b), _t := A_TickCount
ahk := m.Div(a,b)
Msgbox disp("Example 7`nLarge Decimal Division",_calc,ahk)



a := "701411.123412341234123412341234"              ; example 8 (large decimal multiplication)
b := "1411.213421342134"
_calc := calc(a,"*",b), _t := A_TickCount
ahk := m.Mult(a,b)
Msgbox disp("Example 8`nLarge Decimal Multiplication",_calc,ahk)




