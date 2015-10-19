﻿/**
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
 * 
 * TODO:
 *      o Format, Parse
 */

module System.String;

import System;
import System.Collections;

import core.vararg;


abstract final class String {
static:
    string Format(string format, ...) {
        scope auto sb = new StringBuilder();

        long i;
        do {
            bool first;
            long num = -1;
            for (; i < format.length; i++) {
                if (format[i] == '{')
                    first = true;

                //TODO: check for number

                if (format[i] == '}' && first && num != -1)
                    break;
            }

            if (num >= _arguments.length) 
                throw new ArgumentOutOfRangeException();

            //TODO: switch by type
            switch (_arguments[num]) {
                case typeid(char):
                    break;

                case typeid(int):
                    break;

                    //...
                default:
            }


        } while (i < format.length);

        return sb.ToString();
    }

    void Parse(string input, string format, ...) {
        return null;
    }

    string[] Split(string str, char[] delimiter) {
        scope auto ret = new List!string();

        foreach (x; delimiter) {
            auto list = InternalSplit(str, cast(string)x[0 .. 1]);
            ret.AddRange(list);
            delete list;
        }

        return ret.ToArray();
    }
    
    string[] Split(string str, string[] delimiter) {
        scope auto ret = new List!string();
        
        foreach (x; delimiter) {
            auto list = InternalSplit(str, x);
            ret.AddRange(list);
            delete list;
        }
        
        return ret.ToArray();
    }

    string Join(string[] strings, string delimiter) {
        scope auto sb = new StringBuilder(strings[0]);

        foreach (x; strings[1 .. $]) {
            sb.Append(delimiter);
            sb.Append(x);
        }

        return sb.ToString();
    }

    long IndexOf(string str, string value) {
        int k;
        foreach (i, x; str) {
            if (x == value[k]) {
                k++;

                if (k == value.length)
                    return i - k;
            }
        }

        return -1;
    }

    long LastIndexOf(string str, string value) {
        int k;
        foreach_reverse (i, x; str) {
            if (x == value[k]) {
                k++;
                
                if (k == value.length)
                    return i - k;
            }
        }
        
        return -1;
    }

    long IndexOfAny(string str, char[] anyOf) {
        long idx = IndexOf(str, anyOf[0]);

        foreach (x; anyOf) {
            long i = IndexOf(str, x);
            if (idx == -1 || i < idx)
                idx = i;
        }

        return idx;
    }

    long LastIndexOfAny(string str, char[] anyOf) {
        long idx = IndexOf(str, anyOf[0]);
        
        foreach (x; anyOf) {
            long i = IndexOf(str, x);
            if (idx == -1 || i > idx)
                idx = i;
        }
        
        return idx;
    }

    string Insert(string str, long index, string value) {
        auto ret = new string[str.length + value.length];

        ret[0 .. index]                = str[0 .. index];
        ret[index .. value.length]     = value;
        ret[index + value.length .. $] = str[index .. $];

        return ret;
    }

    private List!string InternalSplit(string str, string delimiter) {
        auto ret = new List!string();

        for (long last, cur; cur < str.length;) {
            last = cur;
            cur  = str[cur .. $].IndexOf(delimiter);
            if (cur == -1) {
                ret.Add(str[last .. $]);
                return ret;
            }

            ret.Add(str[last .. cur]);
        }

        return ret;
    }
}

// For UTFS calls
alias Join           = String.Join;
alias Split          = String.Split;
alias Parse          = String.Parse;
alias Format         = String.Format;
alias Insert         = String.Insert;
alias IndexOf        = String.IndexOf;
alias IndexOfAny     = String.IndexOfAny;
alias LastIndexOf    = String.LastIndexOf;
alias LastIndexOfAny = String.LastIndexOfAny;



unittest {
    auto param1 = "test|test2|test3".Split('|');
    auto param2 = String.Split("test|test2|test3", '|');

    auto param3 = "Format {0} of {1} by {2}".Format(42, "abc", 'c');
    auto param4 = String.Format("Format {0} of {1} by {2}", 42, "abc", 'c');

    string[5] test;
    string param5 = test.Join("x");

    string param6 = "test".Insert(3, "lalal");
}