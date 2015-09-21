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

module Modules.Input.PS2KeyboardMouse.PS2Mouse;

import ObjectManager;

import Modules.Input.Mouse;


static class PS2Mouse {
    private enum {
        SENSITIVITY = 1,
        NUM_AXIES   = 2,
        NUM_BUTTONS = 5
    }

    package __gshared void function() EnableMouse;

    private __gshared byte[4] m_bytes;
    private __gshared int m_cycle;
    private __gshared Mouse m_mouse;

    static ModuleResult Initialize(string[] args) {
        m_mouse = Mouse.CreateInstance("PS2Mouse", NUM_AXIES, NUM_BUTTONS);
        EnableMouse();

        return ModuleResult.Successful;
    }

    static ModuleResult Finalize() {
        delete m_mouse;

        return ModuleResult.Successful;
    }

    package static void Handler(byte code) {
        m_bytes[m_cycle] = code;

        if (!m_cycle && !(m_bytes[0] & 0x08))
            return;

        if (++m_cycle < 3)
            return;

        m_cycle = 0;
        if (m_bytes[0] & 0xC0)
            return;
            
        if (m_bytes[0] & 0x10)
            m_bytes[1] = cast(byte)-(256 - m_bytes[1]);
            
        if (m_bytes[0] & 0x10)
            m_bytes[2] = cast(byte)-(256 - m_bytes[2]);
        m_bytes[2] = -m_bytes[2];

        int[2] b;
        b[0] = m_bytes[1] * SENSITIVITY;
        b[1] = m_bytes[2] * SENSITIVITY;

        // Apply scaling
        // TODO: Apply a form of curve to the mouse movement (dx*log(dx), dx^k?)
        // TODO: Independent sensitivities?
        // TODO: Disable acceleration via a flag?

        // TODO: Scroll wheel?
        m_mouse.HandleEvent(m_bytes[0] & 7, b);
    }
}