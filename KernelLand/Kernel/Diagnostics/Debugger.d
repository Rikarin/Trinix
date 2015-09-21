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

module Diagnostics.Debugger;

static import Core.Logger;


enum LogLevel {
    Emergency = 1,    /* System is unusable */
    Alert     = 2,    /* Should be corrected immediately */
    Critical  = 4,    /* Critical conditions */
    Error     = 8,    /* Error conditions */
    Warning   = 16,   /* May indicate that an error will occur if action is not taken. */
    Notice    = 32,   /* Events that are unusual, but not error conditions. */
    Info      = 64,   /* Normal operational messages that require no action. */
    Debug     = 128   /* Information useful to developers for debugging the application. */
}

static abstract class Debugger {
    private __gshared string[] m_logLevelNames = [
        "EMERGENCY",
        "ALERT",
        "CRITICAL",
        "ERROR",
        "WARNING",
        "NOTICE",
        "INFO",
        "DEBUG"
    ];

    private __gshared LogLevel m_logLevel = cast(LogLevel)0xFF;

    static void Log(int level, lazy string category, lazy string message, ...) {
        if (level & m_logLevel) {
            int l = -1;

            do {
                l++;
                level /= 2;
            } while (level);

            Core.Logger.Log("[ %s ] - %s: %s", m_logLevelNames[l], category, message);
            //TODO: do something useful
            //TODO: move ParseString here and let the Log take varargs
            //TODO: send messages via COM port to the debugger
        }
    }
}