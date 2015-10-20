module System.IO;


/* Delegates  */

/* Enums      */
public import System.IO.SeekOrigin;

/* Interfaces */

/* Structs    */

/* Classes    */
public import System.IO.Stream;


/*
TODO:
    SyncStream
    MemoryStream
    FileStream
    PipeStream
    NetworkStream
    BufferedStream
    SyncStream

    Task
    CancellationToken
    WaitHandle
    Exceptions

*/


//T = object ??
class Task(T = Object) {

}


class CancellationToken {
    enum CancellationToken None = null;
//@property CancellationToken None() { return null; }
}