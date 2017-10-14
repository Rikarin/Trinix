/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Architectures.x86_64.Core.SystemSegmentType;


enum SystemSegmentType : ubyte {
    LocalDescriptorTable = 0b0010,
    AvailableTSS         = 0b1001,
    BusyTSS              = 0b1011,
    CallGate             = 0b1100,
    InterruptGate        = 0b1110,
    TrapGate             = 0b1111
}