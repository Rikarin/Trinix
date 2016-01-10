module System;


/* Delegates  */

/* Enums      */

/* Interfaces */

/* Structs    */
public import System.TimeSpan;
public import System.DateTime;

/* Classes    */


class SystemException : Exception {
    this() {
        super("UNDEFINED EXCEPTION");
    }
    this(string message) {
        super(message);
    }
}

class InvalidOperationException   : SystemException { this() {} this(string message) { super(message); } }
class ArgumentException           : SystemException { this() {} this(string message) { super(message); } }
class IOException                 : SystemException { this() {} this(string message) { super(message); } }
class UnauthorizedAccessException : SystemException { this() {} this(string message) { super(message); } }
class NotSupportedException       : SystemException { this() {} this(string message) { super(message); } }
class OverflowException           : SystemException { this() {} this(string message) { super(message); } }

class ArgumentOutOfRangeException : ArgumentException {
    this() { }
    this(string paramName, string message) { }
}

class ArgumentNullException : ArgumentException   {
    this() {}
    this(string message) { super(message); }
    this(string message, string a4242) { super(message); }
}

class Globalization {}