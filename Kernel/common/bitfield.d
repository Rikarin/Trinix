/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module common.bitfield;


template bitfield(alias data, args...) {
    const char[] bitfield = bitfieldShim!((typeof(data)).stringof, data, args).ret;
}

template bitfieldShim(const char[] typeStr, alias data, args...) {
    const char[] name = data.stringof;
    const char[] ret  = bitfieldImpl!(typeStr, name, 0, args).ret;
}

template bitfieldImpl(const char[] typeStr, const char[] nameStr, int offset, args...) {
    static if (!args.length) {
        const char[] ret = "";
    } else {
        const name = args[0];
        const size = args[1];
        const mask = bitmask!size;
        
        const char[] getter = typeStr ~ " " ~ name ~ "() { return (" ~ nameStr ~ " >> " ~ itoh!(offset) ~ ") & " ~ itoh!(mask) ~ "; }\n";
        
        const char[] setter = "void " ~ name ~ "(" ~ typeStr ~ " val) { " ~ nameStr ~ " = (" ~ nameStr ~ " & " ~ itoh!(~(mask << offset))
            ~ ") | ((val & " ~ itoh!(mask) ~ ") << " ~ itoh!(offset) ~ "); }\n";
        
        const char[] ret = getter ~ setter ~ bitfieldImpl!(typeStr, nameStr, offset + size, args[2 .. $]).ret;
    }
}

template bitmask(long size) {
    const long bitmask = (1UL << size) - 1;
}

template itoh(long i) {
    const char[] itoh =  "0x" ~ intToStr!(i, 16);
}

template digits(long i) {
    const char[] digits = "0123456789abcdefghijklmnopqrstuvwxyz"[0 .. i];
}

template intToStr(ulong i, int base) {
    static if(i >= base) {
        const char[] intToStr = intToStr!(i / base, base) ~ digits!base[i % base];
    } else {
        const char[] intToStr = "" ~ digits!base[i % base];
	}
}