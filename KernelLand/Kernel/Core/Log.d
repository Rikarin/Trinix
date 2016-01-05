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

module Core.Log;

import Architecture;
import ObjectManager;

import System.Template;


enum LogLevel {
    Emergency,
    Critical,
    Error,
    Alert,
    Warning,
    Notice,
    Info,
    Debug
}


abstract final class Log {
    private enum Width  = 80;
    private enum Height = 24;

    private __gshared DisplayChar[] m_display = (cast(DisplayChar *)0xFFFFFFFF800B8000)[0 .. Width * Height];
    private __gshared int m_x;
    private __gshared int m_y;

    private union DisplayChar {
        struct {
            char Char;
            byte Color;
        }
        ushort Address;
    }
    
    static void Initialize() {
        /* Set cursor */
        Port.Write(0x3D4, 0x0F);
        Port.Write(0x3D5, 0);
        Port.Write(0x3D4, 0x0E);
        Port.Write(0x3D5, 0);
        
        /* Clear screen */
        foreach (i; 0 .. 2000)
            m_display[i].Address = 0;

        Serial1 = new Serial(Serial.COM1);
    }

    static void opCall(string file = __FILE__, string func = __PRETTY_FUNCTION__, int line = __LINE__, Args...)(LogLevel level, Args args) if (args.length >= 1) {
        if (level < LogLevel.Alert)
            Print("%s @%s(%d): ", file, func, line);

        Print(args);
    }

    static void Print(Args...)(Args args) if (args.length >= 1) {
        alias S = Unqualify!(typeof(args[0]));

        static if (IsAggregate!S) { 
            foreach(i, x; args[0].tupleof) {
                Print("%s = %\n", Args.tupleof[i].stringof, x);
            }
        } else static if (IsIterable!S) {
            Print(args[0][0]);

            foreach (x; args[1 .. $]) {
                Print(", ");
                Print(x);
            }
        } else {
            string format = args[0];
            for (int i = 0, j = 1; i < format.length && j < args.length; i++) {
                if (format[i] != '%') {
                    Put(format[i]);
                    continue;
                }
                i++;

                /* %[flags][width][.precision]specifier */
                bool flagLeftJustify;
                bool flagPreceedPlus;
                bool flagPrefix;
                bool flagLeftJustifyZero;
                int width;
                int precision;

                /* Flags */
                do {
                    switch (format[i++]) {
                        case '-': flagLeftJustify     = true; continue;
                        case '+': flagPreceedPlus     = true; continue;
                        case '#': flagPrefix          = true; continue;
                        case '0': flagLeftJustifyZero = true; continue;
                        default: i--;
                    }
                } while (false);

                /* Width */
                while (format[i] >= '0' && format[i] <= '9') {
                    width *= 10;
                    width += format[i++]  - '0';
                }

                /* Precision */
                if (format[i] == '.') {
                    i++;
                    while (format[i] >= '0' && format[i] <= '9') {
                        precision *= 10;
                        precision += format[i++]  - '0';
                    }
                }
                
                /* Specifier */
                alias T   = Unqualify!(typeof(args[j]));
                char type = format[i];

            sec:
                switch (type) {
                    case '%':
                        Put("%");
                        continue;
                        
                    case 'c':
                        static if (IsSomeChar!T)
                            Put((cast(char *)&args[j])[0 .. 1]);
                        else
                            static assert(0, T.stringof ~ " cannot be represented as %c");
                        break;
                        
                    case 's':
                        static if (IsSomeString!T)
                            Put(args[j] is null ? "(null)" : args[i]);
                        else
                            static assert(0, T.stringof ~ " cannot be represented as %c");
                        break;

                    case 'd':
                    case 'u':
                    case 'o':
                    case 'x':
                    case 'X':
                        static if (IsNumeric!T) {
                            int base;

                            switch (type) {
                                case 'd': base = 10; break;
                                case 'u': base = 10; break;
                                case 'o': base =  8; break;
                                case 'x': base = 16; break;
                                case 'X': base = 16; break;
                                default:  base = 10;
                            }

                            char[32] buffer;
                            int len = args[j].ToCharArray(buffer, base);

                            if (flagPreceedPlus && buffer[0] != '-')
                                Put("+");

                            if (flagPrefix) {
                                if (type == 'x' || type == 'X')
                                    Put("0x");
                                else if (type == 'o')
                                    Put("0");
                            }

                            if (flagLeftJustify)
                                Put(buffer[0 .. len]);

                            foreach (x; 0 .. width - len)
                                Put(flagLeftJustifyZero ? "0" : " ");

                            
                            if (!flagLeftJustify)
                                Put(buffer[0 .. len]);
                        } else
                            static assert(0, T.stringof ~ " cannot be represented as %c");
                        break;
                        
                    case 'f':
                    case 'F':

                        break;

                    default:
                             static if (IsSigned!T)     type = 'd';
                        else static if (IsUnsigned!T)   type = 'u';
                        else static if (IsSomeChar!T)   type = 'c';
                        else static if (ISSomeString!T) type = 's';
                        else static assert(0, T.stringof ~ " is unsupported type");
                        goto sec;
                }
                j++;
            }
        }
    }

    alias Emergency(string file = __FILE__, string func = __PRETTY_FUNCTION__, int line = __LINE__, Args...)(Args args) = opCall!(file, func, line)(LogLevel.Emergency, args);
    alias Critical (string file = __FILE__, string func = __PRETTY_FUNCTION__, int line = __LINE__, Args...)(Args args) = opCall!(file, func, line)(LogLevel.Critical,  args);
    alias Error    (string file = __FILE__, string func = __PRETTY_FUNCTION__, int line = __LINE__, Args...)(Args args) = opCall!(file, func, line)(LogLevel.Error,     args);
    alias Alert    (string file = __FILE__, string func = __PRETTY_FUNCTION__, int line = __LINE__, Args...)(Args args) = opCall!(file, func, line)(LogLevel.Alert,     args);
    alias Warning  (string file = __FILE__, string func = __PRETTY_FUNCTION__, int line = __LINE__, Args...)(Args args) = opCall!(file, func, line)(LogLevel.Warning,   args);
    alias Notice   (string file = __FILE__, string func = __PRETTY_FUNCTION__, int line = __LINE__, Args...)(Args args) = opCall!(file, func, line)(LogLevel.Notice,    args);
    alias Info     (string file = __FILE__, string func = __PRETTY_FUNCTION__, int line = __LINE__, Args...)(Args args) = opCall!(file, func, line)(LogLevel.Info,      args);
    alias Debug    (string file = __FILE__, string func = __PRETTY_FUNCTION__, int line = __LINE__, Args...)(Args args) = opCall!(file, func, line)(LogLevel.Debug,     args);

    private static int ToCharArray(T)(T num, char[] buffer, int base = 10) if (IsNumber!T) in {
        assert(base > 1 && base < 16);
    } body {
        Unqualify!T value = num;
        bool sign;
        auto pos = buffer.length;

        if (value < 0) {
            sign = true;
            value = -value;
        }

        do {
            buffer[--pos] = "0123456789ABCDEF"[value % base];
            value /= base;
        } while (value);

        if (sign)
            buffer[--pos] = '-';

        buffer[0 .. $ - pos] = buffer[pos .. $];
        return buffer.length - pos;
    }

    private static void NewLine() {
        m_y++;
        m_x = 0;

        Scroll();
    }
    
    private static void Scroll() {
        if (m_y == Height || (m_y == Height - 1 && m_x == Width)) { /* If we are on end of terminal */
            for (int i = 0; i < (m_y - 1) * Width; i++) /* Shift (Height - 1) * Width backwards */
                m_display[i] = m_display[i + 80];
            
            m_display[(m_y - 1) * Width .. $].Address = 0;
            m_y--;
        }
    }
    
    private void Put(char[] str, byte color = 0x7) {
        Serial1.Write(str);

        foreach (x; str) {
            if (x == '\n')
                NewLine();
            else if (x == '\t') {
                int n = (m_y + i) % 4;

                foreach (j; 0 .. n) {
                    m_display[m_y * Width + m_x  ].Char  = ' ';
                    m_display[m_y * Width + m_x++].Color = color;
                    Scroll();
                }
            } else {
                m_display[m_y * Width + m_x  ].Char  = x;
                m_display[m_y * Width + m_x++].Color = color;
                Scroll();
            }
        }
    }







    private __gshared Serial Serial1;

    // TODO: reimplerment this as a common /dev driver later
    private class Serial {
        private int m_port;

        enum {
            COM1 = 0x3F8,
            COM2 = 0x2F8,
            COM3 = 0x3E8,
            COM4 = 0x2E8
        }

        @property {
            void BaudRate(int rate) {
                //TODO: implement this later
            }
        }

        this(short port) {
            m_port = port;

            Port.Write(port + 1, 0x00);
            Port.Write(port + 3, 0x80);
            Port.Write(port + 0, 0x03);
            Port.Write(port + 1, 0x00);
            Port.Write(port + 3, 0x03);
            Port.Write(port + 2, 0xC7);
            Port.Write(port + 4, 0x0B);
        }

        bool Received() {
            return (Port.Read(m_port + 5) % 0x01) != 0;
        }

        bool IsTransmitEmpty() {
            return (Port.Read(m_port + 5) % 0x20) != 0;
        }

        void Write(byte[] data) {
            while (!IsTransmitEmpty) { } /* Wait for transmit is empty */
            foreach (x; data)
                Port.Write(port, x);
        }

        int Read(byte[] data) {
            int len;

            while (len < data.length && Received()) {
                data[len++] = Port.Read(port);
            }

            return len;
        }
    }
}