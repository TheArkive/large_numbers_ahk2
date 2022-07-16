# Large(ish) Number Library

This library handles numbers of any size (theoretically).  Input numbers should generally always be passed as strings and should be in decimal format (not hex).  Output numbers are always strings, and are in decimal format, unless of course using base conversion methods.

Addition, Subtraction, and Multiplication are done in chunks according to what the sytem architecture can handle.  Division is done basically as long division.  The [dec] paramater (shown below) determines the number of digits past the decimal to return when doing division.

Currently there is no truncation of the decimal when performing addition, subtraction, and multiplication.

## Usage

`obj := math(dec:=20)`

Parameters:
* dec = Number of decimal places used to return division results.

## Properties

### x86_Dadd, x64_Dadd
              
Max number of digits to use for doing chunks of adding and subtracting for x86 and x64 architecture.  These generally should not change.

### x86_Dmult, x64_Dmult

Max number of digits to use for doing chunks of multiplication for x86 and x64 architecture.  These generally should not change.

### dMult, dAdd

On object creation, system architecture is determined and these properties are the resulting number of digits to use when doing chunks of multiplication and addition. These values should generally not change.  If they are changed, then only making these numbers smaller is suggested, otherwise the chunks of addition and multiplication will be inaccurate once the resulting "chunks" result in a value that exceeds the max value of INT64.  Naturally, if these values are made smaller, then larger computations will take longer.

### dec

This property is set on object creation (see above).  This value limits the number of digits past the decimal when performing division.  The result is not rounded.  Of course this value can be changed as desired on the fly.

## Methods

### --- Base Conversion ---

#### `DecToHex(x, bit_width := 0)`
|Param|Description|
|-------------:|--------------------------|
|            x | Input number (decimal).                                                                 |
|    bit_width | Only needed when using negative numbers, or when a specific length of number is desired.|
|       return | A hex string.                                                                           |

#### `HexToDec(x, bit_width := 0, signed := false)`
|Param|Description|
|------------:|--------------------------|
|           x | Input number (hex).                                                                     |
|   bit_width | Only needed when using negative numbers, or when a specific length of number is desired.|
|      signed | If desired output should be negative, then set this to TRUE.                            |
|      return | A decimal number (string).                                                              |

#### `DecToBin(x, bit_width := 0)`

* Functionally the same as `DecToHex()` but returns a binary string.

#### `BinToDec(x, bit_width := 0, signed := false)`

* Functionally the same as `HexToDec()` but accepts a binary string.

### --- Addition / Subtraction ---

#### `Add(p*)`

Input is variadic and a minimum of 2 numbers.  Minimum 2 paramaters, otherwise an error is thrown.  The result is returned.

#### `Combine(x, y)`

Input is any 2 numbers.  The result is returned.  This is technically an internal method, and is used by Add() and Sub().

#### `Sub(p*)`

Input is variadic and a minimum of 2 numbers.  For subtraction, all input items in the array, starting from the second item, are inverted.  Then subtraction is performed, and the result is returned.

### --- Division / Multiplication / Exponents ---

#### `Div(p*)`

Input is variadic and a minimum of 2 numbers.  All numbers are divided in sequence, and the result is returned.  Decimal length is limited by the dec property, which is set on object creation.  The returned result is not rounded.

#### `DivI(x, y)`

Input is any 2 numbers.  Only the whole integer is returned.

#### `DivIM(x, y)`

Input is any 2 numbers.  An object is returned:

* `obj.i` = Integer
* `obj.r` = Remainder

#### `Exp(x, e)`

Input is the base number (x) and the exponent (e).  The result is returned.

#### `Mod(x, y)`

Just like AHK's Mod().  Returns only the remainder.

* `x` = Dividend
* `y` = Divisor

#### `Mult(p*)`

Input is variadic and a minimum of 2 numbers.  The result is returned.

### --- Comparisons ---

#### `Compare(x, y)`

Input is any 2 numbers.  Return values are:

* ` 1` = x is greater than y
* ` 0` = x is less than y
* `-1` = x is equal to y

#### `Eq(x, y)   Equal To`

Input is any 2 numbers.  If x = y then TRUE is returned.

#### `G(x, y)   Greater than`

Input is any 2 numbers.  If x > y then TRUE is returned.

#### `Ge(x, y)   Greater than or equal to`

Input is any 2 numbers.  If x >= y then TRUE is returned.

#### `L(x, y)   Less than`

Input is any 2 numbers.  If x < y then TRUE is returned.

#### `Le(x, y)   Less than or equal to`

Input is any 2 numbers.  If x <= y then TRUE is returned.

### --- Other ---

#### `Round(x, L)`

Input is the number to round (x) and the length to round to (L).
When L is positive, then x is rounded to L digits past the decimal.
When L is 0, then the decimal is rounded and an integer is returned.
When L is negative, then x is rounded accordingly:

* `-1` = round to the 10's place
* `-2` = round to the 100's place
* etc...
