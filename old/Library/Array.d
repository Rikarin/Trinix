/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Library.Array;


static class Array {
    static T Find(T, U)(U array, bool delegate(T obj) predicate) {
        foreach (x; array)
            if (predicate(x))
                return x;

        return null;
    }
}