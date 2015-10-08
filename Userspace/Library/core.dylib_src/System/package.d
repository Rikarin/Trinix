module System;


/* Delegates  */

/* Enums      */

/* Interfaces */
public import System.IAsyncResult;

/* Structs    */

/* Classes    */
public import System.Event;
public import System.EventArgs;
public import System.AsyncCallback;


//TODO: test Event

class Environment {
    string GetResourceString(string name) { return name; }
}

class SystemException : Exception {
    this(string message) { }
}

class InvalidOperationException : SystemException { }
class ArgumentException : SystemException         { }
class ArgumentNullException : ArgumentException   { }
class IOException : SystemException { }
class UnauthorizedAccessException : SystemException { }
class NotSupportedException : SystemException { }

class ArgumentOutOfRangeException : ArgumentException {
    this(string paramName, string message) { }
}


/*
 * TODO: co treba pred v prvej verzii frameworku?
 *      o FileStream, PipeStream, NamedPipeStream, BufferedStream --- Complete: Stream, NullStream, SyncStream, MemoryStream
 *      o WaitHandle, Mutex, Semaphore, ReaderWriterLock, SpinLock
 *      o Environment
 *      o Thread, Process
 *      o TimeSpanDateTime
 * 
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