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
 * 
 * TODO:
 *      o Format, Parse, Replace
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
            if (_arguments[num] is typeid(char)) { }
            else if (_arguments[num] is typeid(int)) { }
            else {}

        } while (i < format.length);

        return sb.ToString();
    }

    void Parse(string input, string format, ...) {

    }

    string[] Split(string str, char delimiter) {
        char[1] c = delimiter;
        return Split(str, c);
    }

    string[] Split(string str, string delimiter) {
        string[1] c = delimiter;
        return Split(str, c);
    }

    string[] Split(string str, char[] delimiter) {
        scope auto ret = new List!string();

        foreach (x; delimiter) {
            auto list = InternalSplit(str, x.To!string);

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

    long IndexOf(string str, string value) in {
        if (str is null)
            throw new ArgumentNullException("str");

        if (value is null)
            throw new ArgumentNullException("str");
    } body {
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
        long idx = IndexOf(str, anyOf[0].To!string);

        foreach (x; anyOf) {
            long i = IndexOf(str, x.To!string);
            if (idx == -1 || i < idx)
                idx = i;
        }

        return idx;
    }

    long LastIndexOfAny(string str, char[] anyOf) {
        long idx = IndexOf(str, anyOf[0].To!string);
        
        foreach (x; anyOf) {
            long i = IndexOf(str, x.To!string);
            if (idx == -1 || i > idx)
                idx = i;
        }
        
        return idx;
    }

    string Insert(string str, long index, string value) {
        auto ret = new char[str.length + value.length];

        ret[0 .. index]                = str[0 .. index];
        ret[index .. value.length]     = value;
        ret[index + value.length .. $] = str[index .. $];

        return cast(string)ret;
    }

 /*   string Replace(string str, string find, string replace) {
        import std.string;
        return str.replace(find, replace);
    }*/



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

    immutable(char)* ToStringC(string str) @trusted pure nothrow {
        auto ret = new char[str.length + 1];
        ret[0 .. str.length] = str;
        ret[$ - 1] = '\0';

        return ret.ptr;
    }

    inout(char)[] FromStringC(inout(char)* str) @trusted @nogc pure nothrow {
        return str[0 .. str.Length];
    }

    long Length(const(char)* str) @trusted @nogc pure nothrow {
        long ret;
        while (*str++)
            ret++;

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

alias ToStringC      = String.ToStringC;
alias FromStringC    = String.FromStringC;
alias Length         = String.Length;
//alias Replace        = String.Replace;


unittest {
  /*  auto param1 = "test|test2|test3".Split('|');
    auto param2 = String.Split("test|test2|test3", '|');

    auto param3 = "Format {0} of {1} by {2}".Format(42, "abc", 'c');
    auto param4 = String.Format("Format {0} of {1} by {2}", 42, "abc", 'c');

    string[5] test;
    string param5 = test.Join("x");

    string param6 = "test".Insert(3, "lalal");*/
}