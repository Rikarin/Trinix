module Library.BitArray;

final class BitArray {
	private ulong[] _bits;
	private long _minimal;
	
	private long IndexFromBit(long bit) { return bit / 64; }
	private long OffsetFromBit(long bit) { return bit % 64; }
	private long IndexFromByte(long b) { return b / 8; }
	private long OffsetFromByte(long b) { return b % 8; }
	private long IndexFromInt(long i) { return i / 2; }
	private long OffsetFromInt(long i) { return i % 2; }

	@property long Count() {
		return _bits.length * 64;
	}
	
	void opIndexAssign(bool value, long index) {
		Set(index, value);
	}
	
	bool opIndex(long index) {
		return Get(index);
	}

	this(BitArray bits) in {
		assert(bits);
	} body {
		_bits = new ulong[bits._bits.length];
		foreach (long i, x; bits._bits)
			_bits[i] = x;
	}
	
	this(bool[] bits) in {
		assert (bits);
	} body {
		_bits = new ulong[IndexFromBit(bits.length) + 1];
		
		foreach (i; 0 .. bits.length)
			_bits[IndexFromBit(i)] = bits[i];
	}

	this(long count) in {
		assert(count);
	} body {		
		_bits = new ulong[IndexFromBit(count) + 1];
	}
	
	this(long count, bool value) in {
		assert(count);
	} body {
		_bits = new ulong[IndexFromBit(count) + 1];
		SetAll(value);
	}
		
	~this() {
		delete _bits;
	}
	
	
	BitArray Not() {
		foreach (i; 0 .. _bits.length)
			_bits[i] = ~_bits[i];

		_minimal = 0;
		return this;
	}
	
	BitArray Or(BitArray value) in {
		assert(value);
		assert(Count == value.Count);
	} body {
		foreach (i; 0 .. _bits.length)
			_bits[i] |= value._bits[i];

		_minimal = 0;
		return this;
	}
	
	BitArray Xor(BitArray value) in {
		assert(value);
		assert(Count == value.Count);
	} body {
		foreach (i; 0 .. _bits.length)
			_bits[i] ^= value._bits[i];

		_minimal = 0;
		return this;
	}
	
	BitArray And(BitArray value) in {
		assert(value);
		assert(Count == value.Count);
	} body {
		foreach (i; 0 .. _bits.length)
			_bits[i] &= value._bits[i];

		_minimal = 0;
		return this;
	}
	
	void Set(long index, bool value) in {
		assert(index > 0 && index < Count);
	} body {
		if (value)
			_bits[IndexFromBit(index)] |= (1UL << OffsetFromBit(index));
		else {
			_bits[IndexFromBit(index)] &= ~(1UL << OffsetFromBit(index));
			_minimal = IndexFromBit(index);
		}
	}
	
	void SetAll(bool value) {
		foreach (i; 0 .. _bits.length)
			_bits[i] = value ? 0xFFFF_FFFF_FFFF_FFFF : 0;

		_minimal = 0;
	}
	
	bool Get(long index) in {
		assert(index > 0 && index < Count);
	} body {
		return (_bits[IndexFromBit(index)] & (1UL << OffsetFromBit(index))) != 0;
	}
	
	long FirstFreeBit() {
		foreach (i; _minimal .. _bits.length) {
			if (_bits[i] != 0xFFFF_FFFF_FFFF_FFFF) {
				foreach(j; 0 .. 64) {
					if (!(_bits[i] & (1UL << j)))
						return i * 64 + j;
				}
			} else
				_minimal = i;
		}

		return -1;
	}
}