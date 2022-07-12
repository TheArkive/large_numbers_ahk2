

class math {
    x86 := (2 ** 31) - 1 ; 2,147,483,647 (0's = 9)                  signed
    x64 := (2 ** 63) - 1 ; 9,223,372,036,854,775,807 (0's = 18)     signed
    
    x86_Dadd := 9
    x64_Dadd := 18
    
    x86_Dmult := 4  ;      9999 * 9999      = 99980001           <--- max digits before exceeding int32 size (signed)
    x64_Dmult := 9  ; 999999999 * 999999999 = 999999998000000001 <--- max digits before exceeding int64 size (signed)
    
    dMult := ((A_PtrSize=8)?this.x64_Dmult:this.x86_Dmult)
    dAdd  := ((A_PtrSize=8)?this.x64_Dadd:this.x86_Dadd)
    
    __New(dec:=20) {
        this.dec := dec ; decimal length
    }
    
    ; =================================================================
    ; base conversion
    ; =================================================================
    
    DecToHex(x,fmt:=false) {
        Static v := "0123456789ABCDEF"
        
        str := "", t := this.DivIM(x,16)
        
        While t.i {
            str := SubStr(v,t.r+1,1) str
            t := this.DivIM(t.i,16)
        }
        str := SubStr(v,t.r+1,1) str
        result := ((Mod(StrLen(str),2)) ? "0" : "") str
        
        If fmt {
            tmp := result, result := ""
            Loop Parse tmp
                result .= ((A_Index-1 && !Mod(A_Index-1,2)) ? " " : "") A_LoopField 
        }
        
        return (fmt?"0x ":"0x") result
    }
    
    HexToDec(x) {
        Static v := {0:0, 1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, A:10, B:11, C:12, D:13, E:14, F:15}
        
        (InStr(x,"0x")=1) ? (x := SubStr(x,3)) : "" ; trim 0x from beginning
        (InStr(x," ")) ? (x := StrReplace(x," ")) : ""
        
        arr := []
        Loop (L:=StrLen(x)) {
            fac := this.Exp(16,A_Index-1)
            c := SubStr(x,L-(A_Index-1),1)
            arr.Push(this.Mult(v.%c%,fac))
        }
        
        return this.Add(arr*)
    }
    
    DecToBin(x) {
        str := "", t := this.DivIM(x,2)
        While (t.i) {
            str := t.r str
            t := this.DivIM(t.i,2)
        }
        str := t.r str
        return str
    }
    
    BinToDec(x) {
        arr := []
        Loop (L:=StrLen(x)) {
            fac := this.Exp(2,A_Index-1)
            c := SubStr(x,L-(A_Index-1),1)
            arr.Push(this.Mult(c,fac))
        }
        
        return this.Add(arr*)
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
        this._make_trail(&xD,&yD)         ; make fractional/decimal length equal (trailing zeros)
        
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
    
    Div(x,y) => this._div(x,y)
    
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
        
        arr := []
        Loop e
            arr.Push(x)
        return this.Mult(arr*)
    }
    
    Mod(x,y) {
        result := this._div(x,y,&remain)
        return remain
    }
    
    Mult(p*) {
        If p.Length < 2
            throw Error("obj.Mult() requires a minimum of 2 parameters.",-1)
        res := this._mult(p.RemoveAt(1),p.RemoveAt(1)) ; first calc
        While p.Length {
            res := this._mult(res,p.RemoveAt(1)) ; remaining calcs
            
            ; dbg("==========================================================")
            ; dbg("Mult() idx: " A_Index " / res: " res)
        }
        return res
    }
    
    ; =================================================================
    ; comparison
    ; =================================================================
    
    Compare(x,y) { ; [ x > y returns 1 ] // [ x < y returns 0 ] // [ x = y returns -1 ] // [ returns -2 (unexpected result) ]
        If (x !== y) {
            
            xN := (InStr(x,"-")=1), yN := (InStr(y,"-")=1)  ; determine which values are negative
            dN := (xN && yN)                                ; check for "double negative"
            
            If (result := (!xN && yN) ? true : (xN && !yN) ? false : "") != ""   ; check if only one param is negative
                return result
            
            xI := this._get_int(x), yI := this._get_int(y)  ; separate integers
            
            If (result := this._comp(xI,yI)) != ""          ; Compare integers ...
                return dN ? !result : result                ; ... and retun result if not equal.
            
            xD := this._get_dec(x), yD := this._get_dec(y)  ; get decimals, drop trailing 0's
            
            If (result := (xD && !yD) ? true : (!xD && yD) ? false : "") != "" ; check if only one param has a decimal
                return result
            Else If (xD == yD)
                return -1 ; inputs are equal
            
            this._make_trail(&xD,&yD)               ; "cleanup"/align decimals
            If (result := this._comp(xD,yD)) != ""  ; compare decimals
                return dN ? !result : result 
            Else
                return -2 ; inputs still equal? - unexpected result
            
        } return -1 ; inputs are equal
    }
    
    Eq(x,y) => (this.Compare(x,y)=-1) ? true : false
    
    G(x,y)  => ((r:=this.Compare(x,y))=-1) ? false : r ; greater than
    
    Ge(x,y) => ((r:=this.Compare(x,y))=1 || r=-1) ? true : false
    
    L(x,y)  => ((r:=this.Compare(x,y))=-1) ? false : !r ; less than
    
    Le(x,y) => ((r:=this.Compare(x,y))=0 || r=-1) ? true : false
    
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
    
    ; =========================================================================================================
    ; ==== internal methods ===================================================================================
    ; =========================================================================================================
    
    _abs(_i,&_neg:=0) => (_neg:=InStr(_i,"-")=1) ? SubStr(_i,2) : _i
    
    _add(x,y) {
        x := this._abs(x,&xN), y := this._abs(y,&yN)    ; get absolute value and neg status
        decLen := (!(d:=Instr(x,".")) ? 0 : StrLen(SubStr(x,d+1))) ; get decimal length
        
        x := StrReplace(x,"."), y := StrReplace(y,".")  ; strip decimal for simplicity
        
        append := (xN && yN) ? true : false
        
        _r := [], _dec := "", _d := this.dAdd
        
        x_a := SubStr(x,_d * -1), y_a := SubStr(y,_d * -1)
        While (StrLen(x_a) || StrLen(y_a)) {
            If (x="") && (y="")
                Break
            
            _r.Push(x_a + y_a) ; push values to array
            x := SubStr(x,1,_d * -1), y := SubStr(y,1,_d * -1) ; new x/y values
            
            x_a := (r:=SubStr(x,_d * -1)) ? r : 0
            y_a := (r:=SubStr(y,_d * -1)) ? r : 0
        }
        
        _res := "", _addon := 0
        For i, val in _r {
            val += _addon
            If (StrLen(val) > _d) {
                _addon := SubStr(val,1,_d * -1)
                val := SubStr(val,_d * -1)
            } Else _addon := 0
            _res := Format("{:0" _d "}",String(val)) _res
        }
        
        _res := this._drop_lead(_res)
        (_addon) ? (_res := _addon _res) : ""
        
        If decLen {
            _int := SubStr(_res,1,decLen * -1)
            _dec := this._drop_trail(SubStr(_res,decLen * -1),false)
        } Else _int := (_res!="")?_res:"0"
        
        return (append?"-":"") _int (_dec?"." _dec:"")
    }
    
    _comp(x,y) {  ; basic positive number comparison
        If (result := ( (xL:=StrLen(x)) > (yL:=StrLen(y)) ) ? true : (xL < yL) ? false : "" ) != ""
            return result
        
        Loop StrLen(x) {
            If (_x := SubStr(x,A_Index,1)) = (_y := SubStr(y,A_Index,1))
                Continue
            If (result := (_x > _y) ? true : (_x < _y) ? false : "") != ""
                Break
        }
        return result
    }
    
    _dec_move(&x,&y) { ; make y an integer, Mult x/y by power of 10, prep for _div()
        If (yD := this._get_dec(y)) {                       ; check for y decimal
            xI := this._get_int(x), yI := this._get_int(y)  ; get integers
            xD := this._get_dec(x)                          ; get x decimal
            
            yDL := StrLen(yD)
            xIA := SubStr(xD,1,yDL)             ; x Integer Append
            
            If ( (xIAL := StrLen(xIA)) < yDL )  ; x Integer Append Length
                xIA .= this._sr("0",yDL-xIAL)   ; append 0's if needed
            x  := xI xIA                        ; recreate x integer
            xD := SubStr(xD,yDL+1)              ; recreate x decimal
            x  := (xD?x "." xD:x)               ; append x decimal if exist
            y  := yI yD                         ; recreate y as integer
        } Else
            y := this._get_int(y) ; no decmal, or decimal is only 0's
    }
    
    _div(x,y,&remain:=0) { ; x = dividend, y = divisor, remain = remainder
        If (y="0")
            throw Error("Divide by zero.",-1)
        
        _remain := !IsSet(remain)
        
        xN := (InStr(x,"-")=1), yN := (InStr(y,"-")=1)
        x := StrReplace(x,"-"), y := StrReplace(y,"-") ; remove negative sign
        append := ((xN && !yN) || (!xN && yN)) ? true : false ; append negative sign
        
        If _remain && !this.Compare(x,y) {
            remain := x
            return ; divisor (y) is greator than dividend (x), therefore entire dividend (x) is remainder
        }
        
        decLy := StrLen(this._get_dec(y))
        this._dec_move(&x,&y)           ; make y an integer, Mult x/y by power of 10
        
        _d := InStr(x,".")              ; save x decimal pos
        x := StrReplace(x,".")          ; remove decimal in x
        xL := StrLen(x)                 ; Save max length of dividend integer
        
        intL := (!_d) ? xL : (_d-1)     ; set integer length for quotient
        
        st  := 0        ; start place to "take" digits from dividend
        d_p := ""       ; dividend partial with remainder (for long division)
        quotient := ""  ; final answer init
        
        int := 0, remain := 0 ; init values
        
        Loop {
            dc:=(st-intL)
            
            If (dc=this.dec) || (!dc && _remain) { ; quit on specified decimal length, or just to get remainder
                this._mod(this._drop_lead(d_p),y,&int,&remain) ; compare dividend part to divisor
                Break
            }
            
            (!dc) ? (quotient .= ".") : "" ; append decimal after passing whole integer
            
            d_p .= (_r :=SubStr(x,++st,1)) ? _r : "0" ; pull down next integer in long division
            
            this._mod(this._drop_lead(d_p),y,&int,&remain) ; compare dividend part to divisor
            
            quotient .= int
            d_p := remain ; add int to quotient, reset remainder
            
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
        
        return result
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
            _dec := this._drop_trail(SubStr(_res,decLen * -1),false)
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
            _dec := this._drop_trail(SubStr(_res,decLen * -1),false)
        } Else _int := (_res!="") ? _res : "0"
        
        return (append?"-":"") _int (_dec?"." _dec:"")
    }
    
    ; ==========================================================================================
    ; === utility methods ======================================================================
    ; ==========================================================================================
    
    _drop_trail(z,i:=0) { ; drop trailing zeros (for fractional values only)
        While (SubStr(z,-1 - i,1) = "0") && (i <= StrLen(z))
            i++
        result := SubStr(z,1,(L:=StrLen(z)) - ((i>L)?--i:i))
        return (SubStr(result,-1)=".") ? SubStr(result,1,-1) : result
    }
    
    _drop_lead(z,i:=1) { ; drop leading zeros (for integers only)
        While SubStr(z,i,1) = "0"
            i++
        _r := SubStr(z,i)
        ; result := ((_r:=SubStr(z,i))="") ? "0" : _r
        ; return (InStr(result,".")=1) ? "0" result : result
        return (_r="") ? "0" : (InStr(_r,".")=1) ? "0" _r : _r
    }
    
    _get_int(_i) => ; get integer from input
        ( SubStr( _i,1,(!(d:=InStr(_i,".")) ? StrLen(_i) : (d-1)) ) )
    
    _get_dec(_i) => ; get decimal from input (return is zero-length str if dec is all 0's)
        this._drop_trail( SubStr( _i
                                , ( (d:=InStr(_i,".")+(L:=StrLen(_i))-L) ? (d+1) : L+1 )
                                , (!d?L+1:L-d) )
                        )
    
    _make_trail(&x,&y) { ; make x/y inputs the same length, add trailing zeros (for fractional values only)
        If (x="" && y="") ; don't waste time/cpu on empty strings
            return ""
        xL := StrLen(x), yL := StrLen(y)
        (xL>yL) ? (yL:=StrLen(y:=y . this._sr("0",xL-yL)))  : (yL>xL) ? (xL:=StrLen(x:=x . this._sr("0",yL-xL))) : ""
    }
    
    _sr(a,b,result:="") { ; string repeat ... a=str, b=iterations
        Loop b
            result .= a
        return result
    }
    
    _swap(&x,&y) {
        z := x, x := y, y := z
    }
}


dbg(_in) { ; AHK v2
    Loop Parse _in, "`n", "`r"
        OutputDebug "AHK: " A_LoopField
}
