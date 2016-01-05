/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix
 * Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * https://github.com/Bloodmanovski/Trinix and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module System.ResourceManager;

import std.file;
import std.path;

static import win32;
import derelict.sdl2.sdl;


abstract final class ResourceManager {
    private static immutable(ubyte[][string]) s_resources;
    private static immutable(ubyte[][string]) s_dependencyFiles;

    shared static this() {
        s_dependencyFiles = [
            "SDL2.dll"               : cast(immutable ubyte[])import("SDL2.dll"),
            "SDL2_ttf.dll"           : cast(immutable ubyte[])import("SDL2_ttf.dll"),
            "SDL2_image.dll"         : cast(immutable ubyte[])import("SDL2_image.dll"),
            "zlib1.dll"              : cast(immutable ubyte[])import("zlib1.dll"),
            "libfreetype-6.dll"      : cast(immutable ubyte[])import("libfreetype-6.dll"),
            "libjpeg-9.dll"          : cast(immutable ubyte[])import("libjpeg-9.dll"),
            "libpng16-16.dll"        : cast(immutable ubyte[])import("libpng16-16.dll"),
            "libtiff-5.dll"          : cast(immutable ubyte[])import("libtiff-5.dll"),
            "libwebp-4.dll"          : cast(immutable ubyte[])import("libwebp-4.dll")
        ];

        s_resources = [
            "//Fonts/sfdb.ttf"       : cast(immutable ubyte[])import("sfdb.ttf"),
            "//Fonts/sfdr.ttf"       : cast(immutable ubyte[])import("sfdr.ttf"),
            "//Image/test.jpg"       : cast(immutable ubyte[])import("test.jpg")
        ];
    }

    static auto Get(string value) {
        return value in s_resources;
    }

    static bool Contains(string fileName) {
        if (fileName[0 .. 2] != "//")
            return false;

        return (fileName in s_resources) is null ? false : true;
    }

    static void LoadDependencies() {
        foreach (k, v; s_dependencyFiles) {
            auto d = buildPath(tempDir(), k);
            std.file.write(d, v);
        }
        
        win32.SetDllDirectory(tempDir().ptr);
    }

    package(System) static SDL_RWops* GetRW(string value) {
        auto r = value in s_resources;
        return SDL_RWFromConstMem(cast(const void *)r.ptr, cast(int)r.length);
    }
}