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

module System.Threading.WaitHandle;

import System;
import System.Threading;


abstract class WaitHandle {
    enum WaitTimeout = 0x102;

    protected this() {

    }

    bool WaitOne(TimeSpan timeout);

    bool WaitOne() {
        WaitOne(Timeout.Infinite);
    }

    static bool WaitAll(WaitHandle[] handles) {
        return WaitAll(handles, Timeout.Infinite);
    }

    static bool WaitAll(WaitHandle[] handles, TimeSpan timeout) in {
        if (handles is null)
            throw new ArgumentNullException(Environment.GetResourceString("ArgumentNull_Waithandles"));

        if (!handles.length)
            throw new ArgumentNullException(Environment.GetResourceString("Argument_EmptyWaithandleArray"));
    } body {
        assert(false);
        //TODO
    }

    static int WaitAny(WaitHandle[] handles) {
        return WaitAny(handles, Timeout.Infinite);
    }
    
    static int WaitAny(WaitHandle[] handles, TimeSpan timeout) in {
        if (handles is null)
            throw new ArgumentNullException(Environment.GetResourceString("ArgumentNull_Waithandles"));
        
        if (!handles.length)
            throw new ArgumentNullException(Environment.GetResourceString("Argument_EmptyWaithandleArray"));
    } body {
        assert(false);
        //TODO
    }

    static bool SignalAndWait(WaitHandle toSignal, WaitHandle toWait) {
        return SignalAndWait(toSignal, toWait, Timeout.Infinite);
    }

    static bool SignalAndWait(WaitHandle toSignal, WaitHandle toWaitOn, TimeSpan timeout) in {
        if (toSignal is null)
            throw new ArgumentNullException("toSignal");

        if (toWaitOn is null)
            throw new ArgumentNullException("toWaitOn");
    } body {
        assert(false);
        //TODO
    }
}