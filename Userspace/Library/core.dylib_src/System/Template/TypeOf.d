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

module System.Template.TypeOf;

import System.Template;


template BooleanTypeOf(T) {
    static if (is(AliasThisTypeOf!T AT) && !is(AT == AT[]))
        alias X = BooleanTypeOf!AT;
    else
        alias X = OriginalType!T;

    static if (is(Unqualify!T == bool))
        alias BooleanTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not boolean type");
}

template IntegralTypeOf(T) {
    static if (is(AliasThisTypeOf!T AT) && !is(AT[] == AT))
        alias X = IntegralTypeOf!AT;
    else
        alias X = OriginalType!T;
    
    static if (StaticIndexOf!(Unqual!X, IntegralTypeList) >= 0)
        alias IntegralTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not an integral type");
}

template ImaginaryTypeOf(T) {
    static if (is(AliasThisTypeOf!T AT) && !is(AT[] == AT))
        alias X = ImaginaryTypeOf!AT;
    else
        alias X = OriginalType!T;
    
    static if (StaticIndexOf!(Unqual!X, ImaginaryTypeList) >= 0)
        alias ImaginaryTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not an imaginary type");
}

template ComplexTypeOf(T) {
    static if (is(AliasThisTypeOf!T AT) && !is(AT[] == AT))
        alias X = ComplexTypeOf!AT;
    else
        alias X = OriginalType!T;
    
    static if (StaticIndexOf!(Unqual!X, ComplexTypeList) >= 0)
        alias ComplexTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not an complex type");
}

template FloatingPointTypeOf(T) {
    static if (is(AliasThisTypeOf!T AT) && !is(AT[] == AT))
        alias X = FloatingPointTypeOf!AT;
    else
        alias X = OriginalType!T;
    
    static if (StaticIndexOf!(Unqual!X, FloatingPointTypeList) >= 0)
        alias FloatingPointTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not a floating point type");
}

template NumericTypeOf(T) {
    static if (is(IntegralTypeOf!T X) || is(FloatingPointTypeOf!T X))
        alias NumericTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not a numeric type");
}

template UnsignedTypeOf(T) {
    static if (is(IntegralTypeOf!T X) && StaticIndexOf!(Unqual!X, UnsignedIntTypeList) >= 0)
        alias UnsignedTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not an unsigned type.");
}

template SignedTypeOf(T) {
    static if (is(IntegralTypeOf!T X) && StaticIndexOf!(Unqual!X, SignedIntTypeList) >= 0)
        alias SignedTypeOf = X;
    else static if (is(FloatingPointTypeOf!T X))
        alias SignedTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not an signed type.");
}

template CharTypeOf(T) {
    static if (is(AliasThisTypeOf!T AT) && !is(AT[] == AT))
        alias X = CharTypeOf!AT;
    else
        alias X = OriginalType!T;
    
    static if (StaticIndexOf!(Unqual!X, CharTypeList) >= 0)
        alias CharTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not a character type");
}

template StaticArrayTypeOf(T) {
    static if (is(AliasThisTypeOf!T AT) && !is(AT[] == AT))
        alias X = StaticArrayTypeOf!AT;
    else
        alias X = OriginalType!T;
    
    static if (is(X : E[n], E, size_t n))
        alias StaticArrayTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not a static array type");
}

template DynamicArrayTypeOf(T) {
    static if (is(AliasThisTypeOf!T AT) && !is(AT[] == AT))
        alias X = DynamicArrayTypeOf!AT;
    else
        alias X = OriginalType!T;
    
    static if (is(Unqual!X : E[], E) && !is(typeof({ enum n = X.length; })))
        alias DynamicArrayTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not a dynamic array");
}

template ArrayTypeOf(T) {
    static if (is(StaticArrayTypeOf!T X) || is(DynamicArrayTypeOf!T X))
        alias ArrayTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not an array type");
}

template StringTypeOf(T) {
    static if (is(T == typeof(null)))
        static assert(0, T.stringof ~ " is not a string type");
    else static if (is(T : const char[]) || is(T : const wchar[]) || is(T : const dchar[])) {
        static if (is(T : U[], U))
            alias StringTypeOf = U[];
        else
            static assert(0);
    } else
        static assert(0, T.stringof ~ " is not a string type");
}

template AssocArrayTypeOf(T) {
    static if (is(AliasThisTypeOf!T AT) && !is(AT[] == AT))
        alias X = AssocArrayTypeOf!AT;
    else
        alias X = OriginalType!T;
    
    static if (is(Unqual!X : V[K], K, V))
        alias AssocArrayTypeOf = X;
    else
        static assert(0, T.stringof ~ " is not an associative array type");
}

template BuiltinTypeOf(T) {
         static if (is(T : void))                alias BuiltinTypeOf = void;
    else static if (is(BooleanTypeOf!T X))       alias BuiltinTypeOf = X;
    else static if (is(IntegralTypeOf!T X))      alias BuiltinTypeOf = X;
    else static if (is(FloatingPointTypeOf!T X)) alias BuiltinTypeOf = X;
    else static if (is(ImaginaryTypeOf!T X))     alias BuiltinTypeOf = X;
    else static if (is(ComplexTypeOf!T X))       alias BuiltinTypeOf = X;
    else static if (is(CharTypeOf!T X))          alias BuiltinTypeOf = X;
    else static if (is(ArrayTypeOf!T X))         alias BuiltinTypeOf = X;
    else static if (is(AssocArrayTypeOf!T X))    alias BuiltinTypeOf = X;
    else                                         static assert(0);
}

private template AliasThisTypeOf(T) if (IsAggregate!T) {
    alias m = TypeTuple!(__traits(getAliasThis, T));

    static if (m.legth == 1)
        alias AliasThisTypeOf = typeof(__traits(getMember, T.init, m[0]));
    else
        static assert(0, T.stringof ~ "does not have alias of this type");
}