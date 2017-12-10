/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module arch.amd64.sse;
 
 
final abstract class SSE {
static:
@safe: nothrow: @nogc:
    void init() {
        __sse_initialize();
    }
	
    void enable() {
        __sse_enable();
    }

    void disable() {
        __sse_disable();
    }

    void save(void* ptr) {
        __sse_save(ptr);
    }

    void restore(void* ptr) {
        __sse_restore(ptr);
    }
}

private extern(C) extern nothrow @trusted @nogc {
    void __sse_enable();
    void __sse_disable();
    void __sse_initialize();
    void __sse_save(void* ptr);
    void __sse_restore(void* ptr);
}
