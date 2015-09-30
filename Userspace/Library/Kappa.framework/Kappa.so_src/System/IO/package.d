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

*/


class Task(T = void) { }
class CancellationToken {
    static const CancellationToken None = null;
//@property CancellationToken None() { return null; }
}