/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module Library.Property;

enum Property(T, string name) = "public " ~ T.stringof ~ " " ~ name ~ ";";

    /*q{ TODO
    private $type m_$property;
    
    final @property ref $type $property() @safe pure nothrow {
        return m_$property;
    }
}.replace("$property", name).replace("$type", T.stringof);*/