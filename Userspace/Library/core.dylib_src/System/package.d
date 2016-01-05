module System;


/* Delegates  */

/* Enums      */
public import System.PlatformID;

/* Interfaces */
public import System.IEquatable;
public import System.IComparable;
public import System.IAsyncResult;

/* Structs    */
public import System.Event;
public import System.TimeSpan;
public import System.DateTime;

/* Classes    */
public import System.Math;
public import System.String;
public import System.Convert;
public import System.Version;
public import System.EventArgs;
public import System.Environment;
public import System.AsyncCallback;
public import System.StringBuilder;
public import System.StringBuilder;
public import System.OperatingSystem;
public import System.ResourceManager;


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

/*
 * TODO: co treba v prvej verzii frameworku?
 *      o FileStream, PipeStream, NamedPipeStream, BufferedStream
 *      o Mutex, Semaphore, ReaderWriterLock, SpinLock, Barrier
 *      o EventWaitHandle, AutoResetEvent, ManualResetEvent, CountdownEvent 
 *      o Exceptions
 *      o Thread, Process, ProcessStartInfo, Timer
 *      o DateTime, String
 *      o LinkedList, BitArray
 *      o File, Directory, DirectoryInfo, FileInfo
 *      o MouseDevice
 *
 * Dalsia Verzia:
 *      o HashSet, SortedDictionary, SortedSet
 *      o IConvertible, ISerializable, ISet
 * */


enum SDL = "SDL";