/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 module common.number;
 
 
T min(T)(T a, T b) {
	return a < b ? a : b;
}

T max(T)(T a, T b) {
	return a > b ? a : b;
}
