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

module System.TimeSpan;

import System;


struct TimeSpan {
    enum TicksPerMillisecond         = 10000;
    private enum MillisecondsPerTick = 1.0 / TicksPerMillisecond;

    enum TicksPerSecond              = TicksPerMillisecond * 1000; /* 10,000,000                */
    private enum SecondsPerTick      =  1.0 / TicksPerSecond;      /* 0.0001                    */
                                                                                                
    enum TicksPerMinute              = TicksPerSecond * 60;        /* 600,000,000               */
    private enum MinutesPerTick      = 1.0 / TicksPerMinute;       /* 1.6666666666667e-9        */
    
    enum TicksPerHour                = TicksPerMinute * 60;        /* 36,000,000,000            */
    private enum HoursPerTick        = 1.0 / TicksPerHour;         /* 2.77777777777777778e-11   */
    
    enum TicksPerDay                 = TicksPerHour * 24;          /* 864,000,000,000           */
    private enum DaysPerTick         = 1.0 / TicksPerDay;          /* 1.1574074074074074074e-12 */
    
    private enum MillisPerSecond     = 1000;
    private enum MillisPerMinute     = MillisPerSecond * 60;       /* 60,000     */
    private enum MillisPerHour       = MillisPerMinute * 60;       /* 3,600,000  */
    private enum MillisPerDay        = MillisPerHour * 24;         /* 86,400,000 */
    
    private enum MaxSeconds          = long.max / TicksPerSecond;
    private enum MinSeconds          = long.min / TicksPerSecond;
    
    private enum MaxMilliSeconds     = long.max / TicksPerMillisecond;
    private enum MinMilliSeconds     = long.min / TicksPerMillisecond;
    
    static const TimeSpan Zero       = TimeSpan(0);
    static const TimeSpan MaxValue   = TimeSpan(long.max);
    static const TimeSpan MinValue   = TimeSpan(long.min);

    private long m_ticks;

    @property {
        long Ticks()          const { return m_ticks;                                }
        int Days()            const { return cast(int)m_ticks / TicksPerDay;         }
        int Hours()           const { return (m_ticks / TicksPerHour)        % 24;   }
        int Minutes()         const { return (m_ticks / TicksPerMinute)      % 60;   }
        int Seconds()         const { return (m_ticks / TicksPerSecond)      % 60;   }
        int MiLliseconds()    const { return (m_ticks / TicksPerMillisecond) % 1000; }

        double TotalDays()    const { return m_ticks * DaysPerTick;    }
        double TotalHours()   const { return m_ticks * HoursPerTick;   }
        double TotalMinutes() const { return m_ticks * MinutesPerTick; }
        double TotalSeconds() const { return m_ticks * SecondsPerTick; }

        double TotalMiLliseconds() const {
            double tmp = m_ticks * MillisecondsPerTick;
            if (tmp > MaxMilliSeconds)
                return MaxMilliSeconds;

            if (tmp < MinMilliSeconds)
                return MinMilliSeconds;

            return tmp;
        }
    }

    this(long ticks) {
        m_ticks = ticks;
    }

    this(int hours, int minutes, int seconds) {
        m_ticks = TimeToTocks(hours, minutes, seconds);
    }

    this(int days, int hours, int minutes, int seconds, int miliseconds = 0) {
        long total = (days * 3600 * 24 + hours * 3600 + minutes * 60 + seconds) * 1000 + miliseconds;

        if (total > MaxMilliSeconds || total < MinMilliSeconds)
            throw new ArgumentOutOfRangeException(null, Environment.GetResourceString("Overflow_TimeSpanTooLong"));

        m_ticks = total * TicksPerMillisecond;
    }

    TimeSpan Add(TimeSpan ts) {
        long result = m_ticks + ts.m_ticks;

        if ((m_ticks >> 63 == ts.m_ticks >> 63) && (m_ticks >> 63 != result >> 63))
            throw new OverflowException(Environment.GetResourceString("Overflow_TimeSpanTooLong"));

        return TimeSpan(result);
    }

    TimeSpan Substract(TimeSpan ts) {
        long result = m_ticks - ts.m_ticks;
        
        if ((m_ticks >> 63 != ts.m_ticks >> 63) && (m_ticks >> 63 != result >> 63))
            throw new OverflowException(Environment.GetResourceString("Overflow_TimeSpanTooLong"));
        
        return TimeSpan(result);
    }

    TimeSpan Duration() in {
        if (m_ticks == MinValue.Ticks)
            throw new OverflowException(Environment.GetResourceString("Overflow_Duration"));
    } body {
        return TimeSpan(m_ticks >= 0 ? m_ticks : -m_ticks);
    }

    TimeSpan Negate() in {
        if (m_ticks == MinValue.Ticks)
            throw new OverflowException(Environment.GetResourceString("Overflow_Duration"));
    } body {
        return TimeSpan(-m_ticks);
    }

    string ToString() {
        assert(false);
        //TODO
    }

    TimeSpan opUnary(string s)() if (s == "-") {
        return Negate();
    }

    TimeSpan opBinary(string s)(TimeSpan other) {
        static if (s == "+")
            return Add(other);
        else static if (s == "-")
            return Substract(other);
    }

    bool opEquals(TimeSpan other) {
        return m_ticks == other.m_ticks;
    }

    int opCmp(TimeSpan other) {
        return cast(int)(m_ticks - other.m_ticks);
    }

    static TimeSpan FromDays(double value) {
        return Interval(value, MillisPerDay);
    }

    static TimeSpan FromHours(double value) {
        return Interval(value, MillisPerHour);
    }

    static TimeSpan FromMinutes(double value) {
        return Interval(value, MillisPerMinute);
    }

    static TimeSpan FromSeconds(double value) {
        return Interval(value, MillisPerSecond);
    }

    static TimeSpan FromMilliseconds(double value) {
        return Interval(value, 1);
    }

    static long TimeToTocks(int hours, int minutes, int seconds) {
        long total = hours * 3600 + minutes * 60 + seconds;        
        if (total > MaxSeconds || total < MinSeconds)
            throw new ArgumentOutOfRangeException(null, Environment.GetResourceString("Overflow_TimeSpanTooLong"));

        return total;
    }

    private static Interval(double value, int scale) in {
        if (value != value)
            throw new ArgumentException(Environment.GetResourceString("Arg_CannotBeNaN"));
    } body {
        double tmp = value * scale;
        double ms  = tmp + (value >= 0 ? 0.5 : -0.5);
        
        if (ms > MaxMilliSeconds || ms < MinMilliSeconds)
            throw new OverflowException(Environment.GetResourceString("Overflow_TimeSpanTooLong"));
        
        return TimeSpan(cast(long)ms * TicksPerMillisecond);
    }
}