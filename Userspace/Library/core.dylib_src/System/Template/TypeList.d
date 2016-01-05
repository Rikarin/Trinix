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

module System.Template.TypeList;

import System.Template;


/* Cent is enabled */
static if (is(ucent)) {
    alias SignedCentTypeList   = TypeTuple!(cent);
    alias UnsignedCentTypeList = TypeTuple!(ucent);
} else {
    alias SignedCentTypeList   = TypeTuple!();
    alias UnsignedCentTypeList = TypeTuple!();
}

alias SignedIntTypeList     = TypeTuple!(byte,   short,    int,   long,  SignedCentTypeList);
alias UnsignedIntTypeList   = TypeTuple!(ubyte,  ushort,   uint,  ulong, UnsignedCentTypeList);
alias FloatingPointTypeList = TypeTuple!(float,  double,   real);
alias ImaginaryTypeList     = TypeTuple!(ifloat, idouble,  ireal);
alias ComplexTypeList       = TypeTuple!(cfloat, cdouble,  creal);
alias CharTypeList          = TypeTuple!(char,   wchar,    dchar);
alias IntegralTypeList      = TypeTuple!(SignedIntTypeList, UnsignedIntTypeList);
alias NumericTypeList       = TypeTuple!(IntegralTypeList,  FloatingPointTypeList);