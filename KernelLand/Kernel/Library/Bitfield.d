/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Library.Bitfield;


template Bitfield(alias data, Args...) {
	const char[] Bitfield = BitfieldShim!((typeof(data)).stringof, data, Args).Ret;
}

template BitfieldShim(const char[] typeStr, alias data, Args...) {
	const char[] Name = data.stringof;
	const char[] Ret = BitfieldImpl!(typeStr, Name, 0, Args).Ret;
}

template BitfieldImpl(const char[] typeStr, const char[] nameStr, int offset, Args...) {
	static if (!Args.length)
		const char[] Ret = "";
	else {
		const Name = Args[0];
		const Size = Args[1];
		const Mask = Bitmask!Size;
		
		const char[] Getter = "@property " ~ typeStr ~ " " ~ Name ~ "() { return (" ~ nameStr ~ " >> " ~ Itoh!(offset) ~ ") & " ~ Itoh!(Mask) ~ "; } \n";
		
		const char[] Setter = "@property void " ~ Name ~ "(" ~ typeStr ~ " val) { " ~ nameStr ~ " = (" ~ nameStr ~ " & " ~ Itoh!(~(Mask << offset))
			~ ") | ((val & " ~ Itoh!(Mask) ~ ") << " ~ Itoh!(offset) ~ "); } \n";
		
		const char[] Ret = Getter ~ Setter ~ BitfieldImpl!(typeStr, nameStr, offset + Size, Args[2 .. $]).Ret;
	}
}

template Bitmask(long size) {
	const long Bitmask = (1UL << size) - 1;
}

template Itoh(long i) {
	const char[] Itoh =  "0x" ~ IntToStr!(i, 16);
}

template Digits(long i) {
	const char[] Digits = "0123456789abcdefghijklmnopqrstuvwxyz"[0 .. i];
}

template IntToStr(ulong i, int base) {
	static if(i >= base)
		const char[] IntToStr = IntToStr!(i / base, base) ~ Digits!base[i % base];
	else
		const char[] IntToStr = "" ~ Digits!base[i % base];
}