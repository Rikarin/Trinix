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

module System.Template.Traits;


/* Modify qualifiers */
template MutableOf(T)          { alias MutableOf          = (T);                     }
template InoutOf(T)            { alias InoutOf            = inout(T);                }
template ConstOf(T)            { alias ConstOf            = const(T);                }
template InoutConstOf(T)       { alias InoutConstOf       = inout(const(T));         }
template SharedOf(T)           { alias SharedOf           = shared(T);               }
template SharedInoutOf(T)      { alias SharedInoutOf      = shared(inout(T));        }
template SharedConstOf(T)      { alias SharedConstOf      = shared(const(T));        }
template SharedInoutConstOf(T) { alias SharedInoutConstOf = shared(inout(const(T))); }
template ImmutableOf(T)        { alias Immutable          = immutable(T);            }

/* Get the qualifier */
template QualifierOf(T) {
         static if (is(T == shared(inout(const(T))), U)) alias QualifierOf = SharedInoutConstOf;
    else static if (is(T == shared(const(U)), U))        alias QualifierOf = SharedConstOf;
    else static if (is(T == shared(inout(U)), U))        alias QualifierOf = SharedInoutOf;
    else static if (is(T == inout(const(U)), U))         alias QualifierOf = InoutConstOf;
    else static if (is(T == immutable(U), U))            alias QualifierOf = ImmutableOf;
    else static if (is(T == shared(U), U))               alias QualifierOf = SharedOf;
    else static if (is(T == const(U), U))                alias QualifierOf = ConstOf;
    else static if (is(T == inout(U), U))                alias QualifierOf = InoutOf;
    else                                                 alias QualifierOf = MutableOf;
}

/* Remove qualifiers */
template Unqualify(T) {
         static if (is(T U ==          immutable U)) alias Unqualify = U;
    else static if (is(T U == shared inout const U)) alias Unqualify = U;
    else static if (is(T U == shared inout       U)) alias Unqualify = U;
    else static if (is(T U == shared       const U)) alias Unqualify = U;
    else static if (is(T U == shared             U)) alias Unqualify = U;
    else static if (is(T U ==        inout const U)) alias Unqualify = U;
    else static if (is(T U ==        inout       U)) alias Unqualify = U;
    else static if (is(T U ==              const U)) alias Unqualify = U;
    else                                             alias Unqualify = T;
}

/* Return type of enum */
template OriginalType(T) {
    template Impl(T) {
        static if (is(T U == enum))
            alias Impl = OriginalType!U;
        else
            alias Impl = T;
    }

    alias OriginalType = ModifyTypePreservingTQ!(Impl, T);
}

/* Modify type */
package template ModifyTypePreservingTQ(alias Modifier, T) {
         static if (is(T U ==          immutable U)) alias ModifyTypePreservingTQ =          immutable Modifier!U;
    else static if (is(T U == shared inout const U)) alias ModifyTypePreservingTQ = shared inout const Modifier!U;
    else static if (is(T U == shared inout       U)) alias ModifyTypePreservingTQ = shared inout       Modifier!U;
    else static if (is(T U == shared       const U)) alias ModifyTypePreservingTQ = shared       const Modifier!U;
    else static if (is(T U == shared             U)) alias ModifyTypePreservingTQ = shared             Modifier!U;
    else static if (is(T U ==        inout const U)) alias ModifyTypePreservingTQ =        inout const Modifier!U;
    else static if (is(T U ==        inout       U)) alias ModifyTypePreservingTQ =              inout Modifier!U;
    else static if (is(T U ==              const U)) alias ModifyTypePreservingTQ =              const Modifier!U;
    else                                             alias ModifyTypePreservingTQ =                    Modifier!T;
}



//ReturnType