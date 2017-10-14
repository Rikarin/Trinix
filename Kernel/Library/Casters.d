/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module Library.Casters;


ref auto ToArrayA(T)(ref T value) {
    return (cast(byte *)value.ptr)[0 .. value[0].sizeof * value.length];
}

ref byte[T.sizeof] ToArray(T)(ref T value) {
    return (cast(byte *)&value)[0 .. T.sizeof];
}