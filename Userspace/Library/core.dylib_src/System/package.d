module System;


/* Delegates  */

/* Enums      */
public import System.PlatformID;

/* Interfaces */
public import System.IEquatable;
public import System.IComparable;
public import System.IAsyncResult;

/* Structs    */
public import System.TimeSpan;
public import System.DateTime;

/* Classes    */
public import System.Event;
public import System.Version;
public import System.EventArgs;
public import System.AsyncCallback;
public import System.OperatingSystem;


//TODO: test Event

class SystemException : Exception {
    this(string message) { }
}

class InvalidOperationException : SystemException { }
class ArgumentException : SystemException         { }
class ArgumentNullException : ArgumentException   { }
class IOException : SystemException { }
class UnauthorizedAccessException : SystemException { }
class NotSupportedException : SystemException { }
class OverflowException : SystemException { }

class ArgumentOutOfRangeException : ArgumentException {
    this(string paramName, string message) { }
}

interface IDictionary { }

/*
 * TODO: co treba v prvej verzii frameworku?
 *      o FileStream, PipeStream, NamedPipeStream, BufferedStream
 *      o Mutex, Semaphore, ReaderWriterLock, SpinLock, Basrrier
 *      o EventWaitHandle, AutoResetEvent, ManualResetEvent, CountdownEvent 
 *      o Exceptions
 *      o Thread, Process, ProcessStartInfo
 *      o DateTime, String
 *      o List, LinkedList, Dictionary, Queue, Stack, BitArray
 *      o File, Directory, DirectoryInfo, FileInfo
 *
 * Dalsia Verzia:
 *      o HashSet, SortedDictionary, SortedSet
 *      o IConvertible, ISerializable, ISet
 * */





/* Partial classes

//In file Test.part.d
mixin template PartialTest() {
    void InitializeComponents() {
        new View();
        new Button();
    }
}

//In file Test.d
import Application1.PartialTest;

class Test {
    mixin PartialTest;
}
*/