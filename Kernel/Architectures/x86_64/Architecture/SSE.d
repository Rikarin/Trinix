/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
 module Architecture.SSE;
 
 
 final abstract class SSE {
    static void EnableSSE() {
        __sse_enable();
    }

    static void DisableSSE() {
        __sse_disable();
    }

    static void InitializeSSE() {
        __sse_initialize();
    }

    static void SaveSSE(void* ptr) {
        __sse_save(ptr);
    }

    static void RestoreSSE(void* ptr) {
        __sse_restore(ptr);
    }
}

private extern(C) extern pure nothrow {
    void __sse_enable();
    void __sse_disable();
    void __sse_initialize();
    void __sse_save(void* ptr);
    void __sse_restore(void* ptr);
}
