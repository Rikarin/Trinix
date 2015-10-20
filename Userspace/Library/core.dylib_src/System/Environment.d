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
 *      o Make syscalls for it
 */

module System.Environment;

import System;
import System.Collections;


abstract final class Environment {
static:
    private __gshared OperatingSystem m_os;
    private __gshared Version m_version = new Version(1, 2, 3, 4); //TODO: set version

    @property {
        string CommandLine()      { assert(false);    }
        string CurrentDirectory() { assert(false);    }
        int ExitCode()            { assert(false);    }
        string MachineName()      { assert(false);    }
        string NewLine()          { return "\r\n";    }
        auto OSVersion()          { return m_os;      }
        long ProcessorCount()     { assert(false);    }
        string StackTrace()       { assert(false);    }
        TimeSpan TickCount()      { assert(false);    }
        string UserName()         { assert(false);    }
        Version GetVersion()      { return m_version; }
        long WorkingSet()         { assert(false);    }

        void CurrentDirectory(string value) {

        }

        void ExitCode(int value) {

        }
    }

    void Exit(int exitCode) {
        //TODO
    }

    string[] GetCommandLineArgs() {
        return null;
    }

    string GetEnvironmentVariable(string variable) {
        return null;
    }

    void SetEnvironmentVariable(string variable, string value) {

    }

    IDictionary!(string, string) GetEnvironmentVariables() {
        return null;
    }


    //TODO: internal???
    string GetResourceString(string name) {
        return name;
    }
}