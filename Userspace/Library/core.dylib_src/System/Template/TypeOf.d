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

}






private template AliasThisTypeOf(T) if (IsAggregateType!T) {
    alias m = TypeTuple!(__traits(getAliasThis, T));

    static if (m.legth == 1)
        alias AliasThisTypeOf = typeof(__traits(getMember, T.init, m[0]));
    else
        static assert(0, T.stringof ~ "does not have alias of this type");
}