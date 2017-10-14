/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Library.String;

import System.Collections;


List!string Split(string str, char delimiter) {
    auto ret = new List!string();

    long a = 0;
    foreach (i, x; str) {
        if (x == delimiter) {
            ret.Add(str[a .. i]);
            a = i + 1;
        }
    }

    ret.Add(str[a .. $]);
    return ret;
}

string ToString(const char* str) {
    int i;
    while (str[i++] != '\0') {}
    return cast(string)str[0 .. i - 1];
}
