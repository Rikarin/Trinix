// D import file generated from 'src/core/sync/exception.d'
module core.sync.exception;
class SyncException : Exception
{
	nothrow pure @safe this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null);

	nothrow pure @safe this(string msg, Throwable next, string file = __FILE__, size_t line = __LINE__);

}
