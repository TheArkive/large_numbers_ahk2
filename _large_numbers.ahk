; by TheArkive
; forum link: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=106325
; ==========================================================================
;
; This library handles numbers of any size (theoretically).  Input numbers
; should generally always be passed as strings and should be in decimal
; format (not hex).  Output numbers are always strings, and are in decimal
; format, unless of course using base conversion methods.
;
; Addition, Subtraction, and Multiplication are done in chunks according
; to what the sytem architecture can handle.  Division is done basically
; as long division.  The [dec] paramater (shown below) determines the number
; of digits past the decimal to return when doing division.
;
; Currently there is no truncation of the decimal when performing addition,
; subtraction, and multiplication.
;
; ==========================================================================
;
; Usage:
;
;       obj := math(dec:=20)
;
;           dec  = Number of decimal places used to return division results.
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Properties
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;
;   x86_Dadd    = Max number of digits to use for doing chunks of adding and
;   x64_Dadd      subtracting for x86 and x64 architecture.  These generally
;                 should not change.
;
;   x86_Dmult   = Max number of digits to use for doing chunks of multiplication
;   x64_Dmult     for x86 and x64 architecture.  These generally should not change.
;
;   dMult       = On object creation, system architecture is determined and
;   dAdd          these properties are the resulting number of digits to
;                 use when doing chunks of multiplication and addition.
;                 These values should generally not change.  If they are
;                 changed, then only making these numbers smaller is suggested,
;                 otherwise the chunks of addition and multiplication will
;                 be inaccurate once the resulting "chunks" result in a value
;                 that exceeds the max value of INT64.  Naturally, if these
;                 values are made smaller, then larger computations will take
;                 longer.
;
;   dec         = This property is set on object creation (see above).  This
;                 value limits the number of digits past the decimal when
;                 performing division.  The result is not rounded.  Of course
;                 this value can be changed as desired on the fly.
;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Methods
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;
; - - - - - - - - - - - - - - - -
;   Base Conversion
; - - - - - - - - - - - - - - - -
;
;   DecToHex(x,bit_width:=0)
;
;               x   = Input number (decimal).
;       bit_width   = Only needed when using negative numbers, or when a specific
;                     length of number is desired.
;          return   = A hex string.
;
;   HexToDec(x,bit_width:=0,signed:=false)
;
;               x   = Input number (hex).
;       bit_width   = Only needed when using negative numbers, or when a specific
;                     length of number is desired.
;          signed   = If desired output should be negative, then set this to TRUE.
;          return   = A decimal number (string).
;
;   DecToBin(x,bit_width:=0)
;
;       * Functionally the same as DecToHex() but returns a binary string.
;
;   BinToDec(x,bit_width:=0,signed:=false)
;
;       * Functionally the same as HexToDec() but accepts a binary string.
;
; - - - - - - - - - - - - - - - - - - -
; Addition / Subtraction
; - - - - - - - - - - - - - - - - - - -
;
;   Add(p*)
;
;       Input is variadic and a minimum of 2 numbers.  Minimum 2 paramaters,
;       otherwise an error is thrown.  The result is returned.
;
;   Combine(x,y)
;
;       Input is variadic and a minimum of 2 numbers.  The result is returned.
;       This is technically an internal method, and is used by Add() and Sub().
;
;   Sub(p*)
;
;       Input is variadic and a minimum of 2 numbers.  For subtraction, all
;       input items in the array, starting from the second item, are inverted.
;       Then subtraction is performed, and the result is returned.
;
; - - - - - - - - - - - - - - - - - - -
; Division / Multiplication / Exponents
; - - - - - - - - - - - - - - - - - - -
;
;   Div(p*)
;
;       Input is variadic and a minimum of 2 numbers.  All numbers are divided in
;       sequence, and the result is returned.  Decimal length is limited
;       by the dec property, which is set on object creation.  The returned
;       result is not rounded.
;
;   DivI(x,y)
;
;       Input is any 2 numbers.  Only the whole integer is returned.
;
;   DivIM(x,y)
;
;       Input is any 2 numbers.  An object is returned:
;
;           obj.i = Integer    /    obj.r = Remainder
;
;   Exp(x,e)        Exponents
;
;       Input is the base number (x) and the exponent (e).  The result is returned.
;
;   Mod(x,y)
;
;       Just like AHK's Mod().  Returns only the remainder.
;
;           x = Dividend    /    y = Divisor
;
;   Mult(p*)
;
;       Input is variadic and a minimum of 2 numbers.  The result is returned.
;
; - - - - - - - - - - - - - - - - - - -
; Comparisons
; - - - - - - - - - - - - - - - - - - -
;
;   Compare(x,y)
;
;       Input is any 2 numbers.  Return values are:
;
;           1 = x is greater than y
;           0 = x is less than y
;          -1 = x is equal to y
;
;   Eq(x,y)     Equal to
;
;       Input is any 2 numbers.  If x = y then TRUE is returned.
;
;   G(x,y)      Greater than
;
;       Input is any 2 numbers.  If x > y then TRUE is returned.
;
;   Ge(x,y)     Greater than or equal to
;
;       Input is any 2 numbers.  If x >= y then TRUE is returned.
;
;   L(x,y)      Less than
;
;       Input is any 2 numbers.  If x < y then TRUE is returned.
;
;   Le(x,y)     Less than or equal to
;
;       Input is any 2 numbers.  If x <= y then TRUE is returned.
;
; - - - - - - - - - - - - - - - - - - -
; Other
; - - - - - - - - - - - - - - - - - - -
;
;   Round(x,L)
;
;       Input is the number to round (x) and the length to round to (L).
;       When L is positive, then x is rounded to L digits past the decimal.
;       When L is 0, then the decimal is rounded and an integer is returned.
;       When L is negative, then x is rounded accordingly:
;
;           -1 = round to the 10's place
;           -2 = round to the 100's place
;           etc...
;
; ==========================================================================
class math {
    ; x86 := (2 ** 31) - 1 ; 2,147,483,647 (0's = 9)                  signed
    ; x64 := (2 ** 63) - 1 ; 9,223,372,036,854,775,807 (0's = 18)     signed
    
    x86_Dadd := 9
    x64_Dadd := 18
    
    x86_Dmult := 4  ;      9999 * 9999      = 99980001           <--- max digits before exceeding int32 size (signed)
    x64_Dmult := 9  ; 999999999 * 999999999 = 999999998000000001 <--- max digits before exceeding int64 size (signed)
    
    dMult := ((A_PtrSize=8)?this.x64_Dmult:this.x86_Dmult)
    dAdd  := ((A_PtrSize=8)?this.x64_Dadd:this.x86_Dadd)
    
    __New(dec:=20) {
        this.dec := dec ; decimal length
    }
    
    Validate(x) {
        dec := "\-?\d+(\.\d+)?"
        hex := "0x[\da-f]+"
        ; sci := "" ; scientific notation - not yet supported
        
        result := (RegExMatch(x,  "^" dec "$")
                || RegExMatch(x,"i)^" hex "$"))
        
        return result
    }
    
    ; =================================================================
    ; other
    ; =================================================================
    
    Round(x,L) {
        x := this._abs(x,&xN)   ; abs of x and negative check (xN)
        d := InStr(x,".")       ; pos of decimal
        
        If ( (dLen := (!d) ? 0 : (StrLen(x) - d)) = L )
            return (xN?"-":"") x ; return if [ decLen = L ]
        
        final := (xN?"-":"") ( (L>=0) ? SubStr(x,1,d+(!L?-1:L)) ; extract final number if rounding down
                             : SubStr(x,1,d+L-1) this._sr("0",this._abs(L)) )
        d_c := (L>=0) ? (d+L+1) : Abs(L)                        ; digit check offset
        dg  := (L>=0) ? SubStr(x,d_c,1) : SubStr(x,d+L,1)       ; digit to check
        
        If (dg >= 5)    ; perform rounding, determine what to add ...
            addon := (L<=0) ? ("1" this._sr("0",Abs(L))) : ("0." this._sr("0",L-1) "1")
        Else addon := 0 ; ... or add nothing
        
        return (!addon) ? final : this.Add(final,addon*(xN?-1:1))
    }
    
    Type(x) {
        dec := "\-?\d+(\.\d+)?"
        hex := "0x[\da-f]+"
        
        If RegExMatch(x,  "^" dec "$")
            return "dec"
        Else If RegExMatch(x,"i)^" hex "$")
            return "hex"
        Else
            return "unk"
    }
    
    ; =================================================================
    ; base conversion
    ; =================================================================
    
    DecToHex(x,bit_width:=0) {
        If (!bit_width && (InStr(x,"-")=1))
            throw Error("When using a negative number as input, bit_width must be specified.",-1,"math.DecToHex()")
        
        x := this._abs(x,&N) ; get abs() and record neg status
        
        If (bit_width) && !(Len := 0) {
            Len := Ceil(bit_width/4) ; length (bit_width) of number for hex
            max_num := this.Exp(2,bit_width)
            x := (!N) ? ((this.L(max_num,x)) ? max_num : x) : this.Sub(max_num,x)
        }
        
        Static v := "0123456789ABCDEF"
        
        str := "", t := this.DivIM(x,16)
        While t.i {
            str := SubStr(v,t.r+1,1) str
            If this.Compare(t.i,16)
                t := this.DivIM(t.i,16)
            Else Break
        }
        
        str := SubStr(v,t.i+1,1) str
        result := ((Mod(StrLen(str),2)) ? "0" : "") str
        (bit_width) ? (result := this._sr("0",Len-StrLen(result)) result) : ""
        
        return "0x" result
    }
    
    HexToDec(x,bit_width:=0,signed:=false) {
        Static v := {0:0, 1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, A:10, B:11, C:12, D:13, E:14, F:15}
        
        (InStr(x,"0x")=1) ? (x := SubStr(x,3)) : "" ; trim 0x from beginning
        
        If bit_width && StrLen(x) != Ceil(bit_width/4) ; length (bit_width) of number for hex
            throw Error("Input bit width does not match specified bit width.",-1)
        
        arr := [], x := this._drop_lead(x)
        Loop (L:=StrLen(x)) {
            fac := this.Exp(16,A_Index-1)
            c := SubStr(x,L-(A_Index-1),1)
            arr.Push(this.Mult(v.%c%,fac))
        }
        
        result := !(arr.Length = 1 && arr[1] = "0") ? this.Add(arr*) : "0"
        
        If signed && (result!="0") {
            max_num := this.Exp(2,bit_width)
            result := "-" this.Sub(max_num,result)
        }
        
        return result
    }
    
    DecToBin(x,bit_width:=0) {
        If (!bit_width && (InStr(x,"-")=1))
            throw Error("When using a negative number as input, bit_width must be specified.",-1,"math.DecToHex()")
        
        x := this._abs(x,&N) ; get abs() and record neg status
        
        If (bit_width) {
            max_num := this.Exp(2,bit_width)
            x := (!N) ? ((this.L(max_num,x)) ? max_num : x) : this.Sub(max_num,x)
        }
        
        str := "", t := this.DivIM(x,2)
        While (t.i) {
            str := t.r str
            If this.Compare(t.i,2)
                t := this.DivIM(t.i,2)
            Else Break
        }
        
        str := t.i str
        (bit_width) ? (str := this._sr("0",bit_width-StrLen(str)) str) : ""
        return str
    }
    
    BinToDec(x,bit_width:=0,signed:=false) {
        If bit_width && StrLen(x) != bit_width ; length (bit_width) of number for hex
            throw Error("Input bit width does not match specified bit width.",-1)
        
        arr := [], x := this._drop_lead(x)
        Loop (L:=StrLen(x)) {
            fac := this.Exp(2,A_Index-1)
            c := SubStr(x,L-(A_Index-1),1)
            arr.Push(this.Mult(c,fac))
        }
        
        result := !(arr.Length = 1 && arr[1] = "0") ? this.Add(arr*) : "0"
        
        If signed && !(result="0") {
            max_num := this.Exp(2,bit_width)
            result := "-" this.Sub(max_num,result)
        }
        
        return result
    }
    
    ; =================================================================
    ; addition / subtraction
    ; =================================================================
    
    Add(p*) {
        If p.Length < 2
            throw Error("obj.Add() requires a minimum of 2 parameters.",-1)
        res := this.Combine(p.RemoveAt(1),p.RemoveAt(1)) ; first calc
        While p.Length
            res := this.Combine(res,p.RemoveAt(1)) ; remaining calcs
        return res
    }
    
    Combine(x,y) { ; performs addition/subtraction, properly combining positive/negative numbers
        xI := this._get_int(x), yI := this._get_int(y) ; get integers
        xD := this._get_dec(x), yD := this._get_dec(y) ; get decimals
        this._make_trail(&xD,&yD) ; make fractional/decimal length equal (trailing zeros)
        
        x := xI ((xD!="")?"." xD:""), y := yI ((yD!="")?"." yD:"") ; use "cleaned" inputs
        
        xN := this._IsNeg(x), yN := this._IsNeg(y) ; get neg status
        
        _res := ((xN && yN) || (!xN && !yN)) ? this._add(x,y) : this._sub(x,y) ; calc result
        
        _int := this._get_int(_res), _dec := this._get_dec(_res) ; get int and fractional
        
        return (!_dec) ? _int : (_int "." _dec) ; prune fractional if zero
    }
    
    Sub(p*) {
        For i, val in p {
            If i > 1
                p[i] := this._invert(p[i])
        }
        return this.Add(p*)
    }
    
    ; =================================================================
    ; multiplication / division
    ; =================================================================
    
    Div(p*) {
        If p.Length < 2
            throw Error("obj.Div() requires a minimum of 2 parameters.",-1)
        res := this._div(p.RemoveAt(1),p.RemoveAt(1)) ; first calc
        While p.Length
            res := this._div(res,p.RemoveAt(1)) ; remaining calcs
        return res
    }
    
    DivI(x,y) => ((r:=this._div(x,y,&remain))="") ? "0" : r
    
    DivIM(x,y) {
        result := this._div(x,y,&remain)
        return {i:result, r:remain} ; i = int, r = remainder
    }
    
    Exp(x,e) {
        If (e=0)
            return "1"
        Else If (e=1)
            return x
        
        e := this._abs(e,&eN), arr := []
        Loop e
            arr.Push(x)
        
        If this.Ge(e,2) && !eN { ; positive exponents where (e >= 2)
            return this.Mult(arr*)
        } Else If eN { ; exponent is negative
            arr.InsertAt(1,"1")
            return this.Div(arr*)
        } Else throw Error("Unhandled exeption, obj.Exp()",-1) ; this should never happen
    }
    
    Mod(x,y) {
        result := this._div(x,y,&remain)
        return remain
    }
    
    Mult(p*) {
        If p.Length < 2
            throw Error("obj.Mult() requires a minimum of 2 parameters.",-1)
        res := this._mult(p.RemoveAt(1),p.RemoveAt(1)) ; first calc
        While p.Length
            res := this._mult(res,p.RemoveAt(1)) ; remaining calcs
        return res
    }
    
    ; =================================================================
    ; comparison
    ; =================================================================
    
    Compare(x,y) { ; [ x > y returns 1 ] // [ x < y returns 0 ] // [ x = y returns -1 ]
        If (x !== y) {
            x := this._drop_trail(x), y := this._drop_trail(y) ; drop null decimals
            xN := (InStr(x,"-")=1), yN := (InStr(y,"-")=1), dN := (xN && yN)
            If (result := (!xN && yN) ? true : (xN && !yN) ? false : "") != ""   ; check if only one param is negative
                return result
            
            If (result := _comp(this._get_int(x),this._get_int(y))) != ""          ; Compare integers ...
                return dN ? !result : result                ; ... and retun result if not equal.
            
            xD := this._get_dec(x), yD := this._get_dec(y)  ; get decimals, drop trailing 0's
            If (result := (xD && !yD) ? true : (!xD && yD) ? false : (xD == yD) ? -1 : "") != "" ; check if only one param has a decimal
                return result
            
            this._make_trail(&xD,&yD)               ; "cleanup"/align decimals
            If (result := _comp(xD,yD)) != ""  ; compare decimals
                return dN ? !result : result
        } return -1 ; inputs are equal
        
        _comp(x_,y_) {  ; basic positive number comparison
            If (result := ( (xL:=StrLen(x_)) > (yL:=StrLen(y_)) ) ? true : (xL < yL) ? false : "" ) != ""
                return result
            Loop StrLen(x_) {
                If (_x := SubStr(x_,A_Index,1)) = (_y := SubStr(y_,A_Index,1))
                    Continue
                If (result := (_x > _y) ? true : (_x < _y) ? false : "") != ""
                    Break
            } return result
        }
    }
    
    Eq(x,y) => (this.Compare(x,y)=-1) ? true : false
    
    G(x,y)  => ((r:=this.Compare(x,y))=-1) ? false : r ; greater than
    
    Ge(x,y) => ((r:=this.Compare(x,y))=1 || r=-1) ? true : false ; greater than or equal to
    
    L(x,y)  => ((r:=this.Compare(x,y))=-1) ? false : !r ; less than
    
    Le(x,y) => ((r:=this.Compare(x,y))=0 || r=-1) ? true : false ; less than or equal to
    
    ; =========================================================================================================
    ; ==== internal methods ===================================================================================
    ; =========================================================================================================
    
    _abs(_i,&_neg:=0) => (_neg:=InStr(_i,"-")=1) ? SubStr(_i,2) : _i
    
    _add(x,y) {
        x := this._abs(x,&xN), y := this._abs(y,&yN), append := ((xN && yN) ? true : false) ; get absolute value and neg status
        decLen := (!(d:=Instr(x,".")) ? 0 : StrLen(SubStr(x,d+1))) ; get decimal length
        x := StrReplace(x,"."), y := StrReplace(y,".")  ; strip decimal for simplicity
        
        _r := [], _dec := "", _res := "", _addon := 0, _d := this.dAdd
        x_a := SubStr(x,_d * -1), y_a := SubStr(y,_d * -1)
        
        While (StrLen(x_a) || StrLen(y_a)) {
            If (x="") && (y="")
                Break
            
            _r.Push(x_a + y_a) ; push values to array
            x := SubStr(x,1,_d * -1), y := SubStr(y,1,_d * -1) ; new x/y values
            
            (x_a := (r:=SubStr(x,_d * -1)) ? r : 0), (y_a := (r:=SubStr(y,_d * -1)) ? r : 0)
        }
        
        For i, val in _r {
            If (StrLen(val += _addon) > _d)
                _addon := SubStr(val,1,_d * -1), val := SubStr(val,_d * -1)
            Else _addon := 0
            _res := Format("{:0" _d "}",String(val)) _res
        }
        
        result := (_addon?_addon:"") this._drop_lead(_res)
        
        decLen ? (result := this._drop_trail(SubStr(result,1,decLen * -1) "." SubStr(result,decLen * -1))) : ""
        
        return (append?"-":"") result
    }
    
    _dec_move(&x,&y) { ; make y an integer, Mult x/y by power of 10, prep for _div()
        If (yD := this._get_dec(y)) {                       ; check for y decimal
            xI := this._get_int(x), yI := this._get_int(y), xD := this._get_dec(x) ; get integers and decimals
            yDL := StrLen(yD), xIA := SubStr(xD,1,yDL) ; x Integer Append
            
            If ( (xIAL := StrLen(xIA)) < yDL )  ; x Integer Append Length
                xIA .= this._sr("0",yDL-xIAL)   ; append 0's if needed
            x  := xI xIA, xD := SubStr(xD,yDL+1), x  := (xD?x "." xD:x) ; recreate x
            y  := yI yD  ; recreate y
        } Else y := this._get_int(y) ; no decmal, or decimal is only 0's
    }
    
    _div(x,y,&remain:=0) { ; x = dividend, y = divisor, remain = remainder
        If (y="0")
            throw Error("Divide by zero.",-1)
        
        _remain := !IsSet(remain)
        
        x := this._abs(x,&xN), y := this._abs(y,&yN)    ; get absolute value and neg status
        append := ((xN && !yN) || (!xN && yN)) ? true : false ; append negative sign
        
        If _remain && !this.Compare(x,y) {
            remain := x
            return "0" ; divisor (y) is greator than dividend (x), therefore entire dividend (x) is remainder
        }
        
        decLy := StrLen(this._get_dec(y))
        this._dec_move(&x,&y) ; make y an integer, Mult x/y by power of 10
        _d := InStr(x,"."), x := StrReplace(x,"."), xL := StrLen(x) ; Save max length of dividend integer
        
        intL := (!_d) ? xL : (_d-1)     ; set integer length for quotient
        st  := 0, d_p := "", quotient := "", int := 0, remain := 0 ; start place, dividend partial, final answer init
        
        Loop {
            If ((dc:=(st-intL))=this.dec) || (!dc && _remain) { ; quit on specified decimal length, or just to get remainder
                this._mod(_d_p,y,&int,&remain) ; compare dividend part to divisor
                Break
            }
            
            (!dc) ? (quotient .= ".") : "" ; append decimal after passing whole integer
            
            d_p .= (_r :=SubStr(x,++st,1)) ? _r : "0" ; pull down next integer in long division
            this._mod(_d_p,y,&int,&remain) ; compare dividend part to divisor
            quotient .= int, d_p := remain, _d_p := this._drop_lead(d_p) ; add int to quotient, reset remainder
            
            If (d_p="") && (st >= xL) ; !Integer(d_p) ..... end of division?
                Break
        }
        
        If (_remain && decLy && !dc) {
            rInt := ( (_r:=SubStr(remain,1,decLy * -1)) ? _r : "0" )
            rDec := this._drop_trail(SubStr(remain,decLy * -1))
            remain := (xN?"-":"") rInt (rDec?"." rDec:"")
        }
        
        result := (append?"-":"") this._drop_lead(quotient)
        (InStr(result,".")) ? (result := this._drop_trail(result)) : ""
        
        return (result="") ? "0" : result
    }
    
    _invert(_i) => (InStr(_i,"-")=1) ? SubStr(_i,2) : ("-" _i)
    
    _IsNeg(_i) => (InStr(_i,"-")=1)
    
    _mod(x,y,&int:=0,&remain:=0) { ; x/y must be positive integers, y must NOT be zero ... sets int and remainder, used in _div()
        If (x=y) {                      ; don't waste cpu when x=y
            int := 1, remain := 0
            return
        } Else If !this.Compare(x,y) {  ; if y > x, then remainder = x
            int := 0, remain := x
            return ; divisor (y) is greator than dividend (x), therefore entire dividend (x) is remainder
        } Else {
            mult := y, int := 1, remain := 0, _r := "" ; _r = compare result
            Loop { ; if x is still larger, continue
                prev_mult := mult, mult := this.Mult(y,++int)
                If (_r := this.Compare(x,mult)) != 1 ; if x is smaller, break
                    Break
            }
            If !_r ; if _r = 0 (or ""), adjust int and calc remainder
                int--, remain := this.Sub(x,prev_mult)
        }
    }
    
    _mult(x,y) {
        x := this._abs(x,&xN), y := this._abs(y,&yN)    ; get absolute value and neg status
        xDL := StrLen(this._get_dec(x)) ; get decimal length - drop trailing 0's
        yDL := StrLen(this._get_dec(y)) 
        decLen := xDL + yDL
        x := StrReplace(x,"."), y := StrReplace(y,".")  ; strip decimal for simplicity
        
        append := ((xN && !yN) || (!xN && yN)) ? true : false
        
        _r1 := [], _r2:=[], _r3:=[], _dec := "", _d := this.dMult, _append := 0
        
        x_a := SubStr(x,_d * -1)
        
        While (StrLen(x_a)) { ; factor list 1
            If (x="")
                Break
            
            _r1.Push(x_a)
            x := SubStr(x,1,_d * -1)
            x_a := (r:=SubStr(x,_d * -1)) ? r : 0
        }
        
        y_a := SubStr(y,_d * -1)
        While (StrLen(y_a)) { ; factor list 2
            If (y="")
                Break
            _r2.Push(y_a)
            y := SubStr(y,1,_d * -1)
            y_a := (r:=SubStr(y,_d * -1)) ? r : 0
        }
        
        For i1, val1 in _r1 { ; combine factor lists into addition list
            For i2, val2 in _r2 {
                factor := ( ( (i1+i2)-1 ) * _d ) - _d
                _r3.Push(String(val1 * val2) . this._sr("0",factor))
            }
        }
        
        _res := (_r3.Length = 1) ? _r3[1] : this.Add(_r3*)
        
        If decLen {
            _int := SubStr(_res,1,decLen * -1)
            _dec := this._drop_trail(SubStr(_res,decLen * -1))
        } Else _int := _res
        
        _result := (append?"-":"") _int (_dec?"." _dec:"")
        
        return _result
    }
    
    _sub(x,y) {
        x := this._abs(x,&xN), y := this._abs(y,&yN)    ; get absolute value and neg status
        decLen := (!(d:=Instr(x,".")) ? 0 : StrLen(SubStr(x,d+1))) ; get decimal length
        x := StrReplace(x,"."), y := StrReplace(y,".")  ; strip decimal points for simplicity
        
        If !this.Compare(x,y)
            this._swap(&x,&y), this._swap(&xN,&yN)  ; swap values so that abs(x) is larger
        
        append := xN ? true : false                 ; if x is negative then append negative sign
        
        _r := [], _dec := "", _deficit := 0, _d := this.dAdd ; _d = digits, and other values for the loop
        
        x_a := SubStr(x,this.dAdd * -1), y_a := SubStr(y,this.dAdd * -1) ; initial values for loop
        
        While (StrLen(x_a) || StrLen(y_a)) {
            If (x="") && (y="")
                Break
            
            x_a += _deficit, _deficit := 0 ; add and reset deficit
            
            (x_a < y_a) ? (x_a := (10 ** _d) + x_a, _deficit--) : "" ; borrow 10 if too small
            
            _r.Push(Format("{:0" _d "}",Integer(x_a) - Integer(y_a))) ; push values to array
            x := SubStr(x,1,_d * -1), y := SubStr(y,1,_d * -1) ; new x/y values
            
            x_a := (r:=SubStr(x,_d * -1)) ? r : 0
            y_a := (r:=SubStr(y,_d * -1)) ? r : 0
        }
        
        _res := ""
        For i, val in _r
            _res := (val _res) ; concat results
        _res := this._drop_lead(_res)
        
        If decLen {
            _int := SubStr(_res,1,decLen * -1)
            _dec := this._drop_trail(SubStr(_res,decLen * -1))
        } Else _int := (_res!="") ? _res : "0"
        
        return (append?"-":"") _int (_dec?"." _dec:"")
    }
    
    ; ==========================================================================================
    ; === utility methods ======================================================================
    ; ==========================================================================================
    
    _drop_trail(z) => (Instr(z,".")) ? RTrim(z,"0.") : z

    _drop_lead(z) => (InStr(_z:=LTrim(z,"0"),".")=1) ? "0" _z : (_z!="") ? _z : "0"
    
    _get_int(_i) => ; get integer from input
        (__d:=InStr(_i,".")) ? SubStr(_i,1,__d-1) : _i
    
    _get_dec(_i) => ; get decimal from input (return is zero-length str if dec is all 0's)
        (__d:=InStr(_i,".")) ? RTrim(SubStr(_i,__d+1),"0") : ""
    
    _make_trail(&x,&y) { ; make x/y inputs the same length, add trailing zeros (for fractional values only)
        (((StrLen(x)) > (StrLen(y))) ? (L:="x",O:="y") : (L:="y", O:="x")), oL:=StrLen(%O%), LL := StrLen(%L%) ; Longest and Other
        %O% .= Format("{:0" (LL-oL) "}","")
    }
    
    _sr(a,b) => ; string repeat ... a=str, b=iterations
        StrReplace(Format("{:-" b "}","")," ",a)
    
    _swap(&x,&y) {
        z := x, x := y, y := z
    }
}

