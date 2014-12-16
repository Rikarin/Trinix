// D import file generated from 'Handle.d'
module Handle;
final class Handle
{
	private long _id;

	private long _type;

	private this(long id);

	this();
	@property long Type();

	long Call(long id, long param1 = 0, long param2 = 0, long param3 = 0, long param4 = 0, long param5 = 0);
	static Handle StaticCall(long id, long param1 = 0, long param2 = 0, long param3 = 0, long param4 = 0, long param5 = 0);

	private static ulong _Call(long resource, long id, long param1, long param2, long param3, long param4, long param5);


}

