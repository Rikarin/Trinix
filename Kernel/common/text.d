/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module common.text;


struct BinaryNumer {
	ulong value;
}

BinaryNumer bin(ulong value) {
	return BinaryNumer(value);
}

struct HexNumer {
	ulong value;
}

HexNumer bin(ulong value) {
	return HexNumer(value);
}
