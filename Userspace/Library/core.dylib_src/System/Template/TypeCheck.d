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

module System.Template.TypeCheck;

import System.Template;


enum bool IsAggregate(T)           = is(T == class) || is (T == struct) || is(T == union) || is(T == interface);
enum bool IsBoolean(T)             = is(BooleanTypeOf!T)       && !IsAggregate!T;
enum bool IsImaginary(T)           = is(ImaginaryTypeOf!T)     && !IsAggregate!T;
enum bool IsComplex(T)             = is(ComplexTypeOf!T)       && !IsAggregate!T;
enum bool IsIntegral(T)            = is(IntegralTypeOf!T)      && !IsAggregate!T;
enum bool IsFloatingPoint(T)       = is(FloatingPointTypeOf!T) && !IsAggregate!T;
enum bool IsNumberic(T)            = is(NumericTypeOf!T)       && !IsAggregate!T;
enum bool IsUnsigned(T)            = is(UnsignedTypeOf!T)      && !IsAggregate!T;
enum bool IsSigned(T)              = is(SignedTypeOf!T)        && !IsAggregate!T;
enum bool IsSomeChar(T)            = is(CharTypeOf!T)          && !IsAggregate!T;
enum bool IsStaticArray(T)         = is(StaticArrayOf!T)       && !IsAggregate!T;
enum bool IsDynamicArray(T)        = is(DynamicArrayTypeOf!T)  && !IsAggregate!T;
enum bool IsArray(T)               = is(ArrayTypeOf!T)         && !IsAggregate!T;
enum bool IsAssocArray(T)          = is(AssocArrayTypeOf!T)    && !IsAggregate!T;
enum bool IsBuiltinType(T)         = is(BuiltinTypeOf!T)       && !IsAggregate!T;
enum bool IsPointer(T)             = is(T == U*, U)            && !IsAggregate!T;
enum bool IsSomeString(T)          = is(StringTypeOf!T)        && !IsAggregate!T         && !IsStaticArray!T;
enum bool IsMutable(T)             = !is(T == const)           && !is(T == immutable)    && !is(T == inout);
enum bool IsNarrowString(T)        = (is(T : const char[])     || is(T : const wchar[])) && !IsAggregate!T && !IsStaticArray!T;
enum bool IsConvertibleToString(T) = (IsAggregate!T            || IsStaticArray!T)       && is(StringTypeOf!T);
enum bool IsScalarType(T)          = IsNumeric!T               || IsSomeChar!T           || IsBoolean!T;
enum bool IsBasicType(T)           = IsScalarType!T            || is(T == void);
enum bool IsIterable(T)            = is(typeof({ foreach (x; T.init) { } }));
enum bool IsInstanceOf(alias S, T) = is(T == S!Args, Args...);

template IsSame(Args...) if (Args.length == 2) {
    private template ExpectType(T) { }
    private template ExpectBool(bool T) { }

    static if (__traits(compiles, ExpectType!(Args[0]), ExpectType!(Args[1])))
        enum IsSame = is (Args[0] == Args[1]);
    else static if (!__traits(compiles, ExpectType!(Args[0])) &&
                    !__traits(compiles, ExpectType!(Args[1])) &&
                     __traits(compiles, ExpectBool!(Args[0] == Args[1]))) {
        static if (!__traits(compiles, &Args[0]) ||
                   !__traits(compiles, &Args[1]))
            enum IsSame = (Args[0] == Args[1]);
        else
            enum IsSame = __traits(isSame, Args[0], Args[1]);
    }
    else
        enum IsSame = __traits(isSame, Args[0], Args[1]);
}

template IsFunctionPointer(T...) if (T.length == 1) {
    static if (is(T[0] U) || is(typeof(T[0]) U)) {
        static if (is(U F : F*) && is(F == function))
            enum bool IsFunctionPointer = true;
        else
            enum bool IsFunctionPointer = false;
    } else
        enum bool IsFunctionPointer = false;
}

template IsDelegate(T...) if (T.length == 1) {
    static if (is(typeof(&T[0]) U : U*) && is(typeof(&T[0]) U == delegate))
        enum bool isDelegate = true;
    else static if (is(T[0] W) || is(typeof(T[0]) W))
        enum bool isDelegate = is(W == delegate);
    else
        enum bool isDelegate = false;
}

template IsSomeFunction(T...) if (T.length == 1) {
    static if (is(typeof(& T[0]) U : U*) && is(U == function) || is(typeof(& T[0]) U == delegate))
        enum bool IsSomeFunction = true;
    else static if (is(T[0] W) || is(typeof(T[0]) W)) {
        static if (is(W F : F*) && is(F == function))
            enum bool IsSomeFunction = true;
        else
            enum bool IsSomeFunction = is(W == function) || is(W == delegate);
    } else
        enum bool IsSomeFunction = false;
}

template IsAbstractFunction(T...) if (T.length == 1) {
    enum bool IsAbstractFunction = __traits(isAbstractFunction, T[0]);
}

template IsFinalFunction(T...) if (T.length == 1) {
    enum bool IsFinalFunction = __traits(isFinalFunction, T[0]);
}

template IsNestedFunction(alias f) {
    enum IsNestedFunction = __traits(isNested, f);
}

template IsCallable(T...) if (T.length == 1) {
    static if (is(typeof(&T[0].opCall) == delegate))
        enum bool IsCallable = true;
    else static if (is(typeof(&T[0].opCall) V : V*) && is(V == function))
        enum bool IsCallable = true;
    else
        enum bool IsCallable = isSomeFunction!T;
}

template IsExpressions(Args...) {
    static if (Args.length >= 2)
        enum bool IsExpressions = IsExpressions!(Args[0 .. $ / 2]) && IsExpressions!(Args[$ / 2 .. $]);
    else static if (Args.length == 1)
        enum bool IsExpressions = !is(Args[0]) && __traits(compiles, { auto ex = Args[0]; });
    else
        enum bool IsExpressions = true;
}

template IsTypes(Args...) {
    static if (Args.length >= 2)
        enum bool IsTypes = IsTypes!(Args[0 .. $ / 2]) && IsTypes!(Args[$ / 2 .. $]);
    else static if (Args.length == 1)
        enum bool IsTypes = is(Args[0]);
    else
        enum bool IsTypes = true;
}

template IsAbstractClass(T...) if (T.length == 1) {
    enum bool IsAbstractClass = __traits(isAbstractClass, T[0]);
}

template IsFinalClass(T...) if (T.length == 1) {
    enum bool IsFinalClass = __traits(isFinalClass, T[0]);
}