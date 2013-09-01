module System.Collections.BitArray;

import System.SystemException;

class BitArray {
private:
	ulong[] bits;

	long IndexFromBit(long bit) { return bit / 64; }
	long OffsetFromBit(long bit) { return bit % 64; }

	long IndexFromByte(long b) { return b / 8; }
	long OffsetFromByte(long b) { return b % 8; }

	long IndexFromInt(long i) { return i / 2; }
	long OffsetFromInt(long i) { return i % 2; }

public:
	@property long Count() { return bits.length * 64; }
	void opIndexAssign(bool value, long index) { Set(index, value); }
	bool opIndex(long index) { return Get(index); }

	~this() { delete bits; }
	
	this(BitArray bits) {
		if (bits is null)
			throw new ArgumentNullException();

		this.bits = new ulong[bits.bits.length];
		foreach (long i, x; bits.bits)
			this.bits[i] = x;
	}

	this(bool[] bits) {
		if (bits == null)
			throw new ArgumentNullException();

		this.bits = new ulong[IndexFromBit(bits.length) + 1];

		foreach (i; 0 .. bits.length)
			this.bits[IndexFromBit(i)] |= (1UL << OffsetFromBit(i));
	}

	this(byte[] bytes) {
		if (bytes == null)
			throw new ArgumentNullException();

		bits = new ulong[IndexFromByte(bytes.length) + 1];

		foreach (i; 0 .. bits.length)
			bits[IndexFromByte(i)] |= (1UL << OffsetFromByte(i));
	}
	
	this(long count) {
		if (count < 0)
			throw new ArgumentOutOfRangeException();

		bits = new ulong[IndexFromBit(count) + 1];
	}

	this(int[] values) {
		if (values == null)
			throw new ArgumentNullException();

		bits = new ulong[IndexFromInt(values.length) + 1];

		foreach (i; 0 .. bits.length)
			bits[IndexFromInt(i)] |= (1UL << OffsetFromInt(i));
	}

	this(long count, bool value) {
		if (count < 0)
			throw new ArgumentOutOfRangeException();

		bits = new ulong[IndexFromBit(count) + 1];
		SetAll(value);
	}

	this(BitArray bits, long size) {
		if (bits is null)
			throw new ArgumentNullException();

		if (size <= 0)
			throw new ArgumentOutOfRangeException();

		this.bits = new ulong[IndexFromBit(size) + 1];
		foreach (i; 0 .. this.bits.length)
			this.bits[i] = bits.bits[i];
	}

	BitArray Not() {
		foreach (i; 0 .. bits.length)
			bits[i] = ~bits[i];
		return this;
	}

	BitArray Or(BitArray value) {
		if (value is null)
			throw new ArgumentNullException();

		if (Count != value.Count)
			throw new ArgumentException();

		foreach (i; 0 .. bits.length)
			bits[i] |= value.bits[i];
		return this;
	}

	BitArray Xor(BitArray value) {
		if (value is null)
			throw new ArgumentNullException();

		if (Count != value.Count)
			throw new ArgumentException();

		foreach (i; 0 .. bits.length)
			bits[i] ^= value.bits[i];
		return this;
	}

	BitArray And(BitArray value) {
		if (value is null)
			throw new ArgumentNullException();

		if (Count != value.Count)
			throw new ArgumentException();

		foreach (i; 0 .. bits.length)
			bits[i] &= value.bits[i];
		return this;
	}

	void Set(long index, bool value) {
		if (index < 0 || index > Count)
			throw new ArgumentOutOfRangeException();

		if (value)
			bits[IndexFromBit(index)] |= (1UL << OffsetFromBit(index));
		else
			bits[IndexFromBit(index)] &= ~(1UL << OffsetFromBit(index));
	}

	void SetAll(bool value) {
		foreach (i; 0 .. bits.length)
			bits[i] = value ? 0xFFFF_FFFF_FFFF_FFFF : 0;
	}

	bool Get(long index) {
		if (index < 0 || index > Count)
			throw new ArgumentOutOfRangeException();

		return (bits[IndexFromBit(index)] & (1UL << OffsetFromBit(index))) != 0;
	}

	long FirstFreeBit() {
		foreach (i; 0 .. bits.length) {
			if (bits[i] != 0xFFFF_FFFF_FFFF_FFFF) {
				foreach(j; 0 .. 64) {
					if (!(bits[i] & (1UL << j)))
						return i * 64 + j;
				}
			}

		}
		throw new SystemException();
	}
}
