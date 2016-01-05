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

module System.Math;

import std.math;

class Math {
    static T Max(T)(T a, T b) {
        return a > b ? a : b;
    }

    static T Min(T)(T a, T b) {
        return a < b ? a : b;
    }

    static double Sqrt(double num) {
        return sqrt(num);
    }

    static T Abs(T)(T num) {
        return num < 0 ? -num : num;
    }

    static T Sgn(T)(T num) {
        return (num < 0 ? -1 : (num > 0 ? 1 : 0));
    }

 /*   static T Sin(T)(T num) {
        return sin(num);
    }

    static T ACos(T)(T num) {
        return acos(num);
    }*/

    static T Floor(T)(T num) {
        return floor(num);
    }
}