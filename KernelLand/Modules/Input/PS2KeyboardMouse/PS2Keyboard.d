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

module Modules.Input.PS2KeyboardMouse.PS2Keyboard;

import Diagnostics;
import ObjectManager;

import Modules.Input.Keyboard;
import Modules.Input.PS2KeyboardMouse;


static class PS2Keyboard {
    private __gshared bool m_up;
    private __gshared int m_layer;
    private __gshared Keyboard m_kb;

    static ModuleResult Initialize(string[] args) {
        m_kb = new Keyboard("PS2Keyboard", _DriverInfo_Input_PS2Keyboard.Version, Keysyms.KEYSYM_RIGHTGUI);

        return ModuleResult.Successful;
    }

    static ModuleResult Finalize() {
        delete m_kb;

        return ModuleResult.Successful;
    }

    package static void Handler(byte code) {
        if (code == 0xFA)
            return;

        if (code == 0xE0) {
            m_layer = 1;
            return;
        }

        if (code == 0xE1) {
            m_layer = 2;
            return;
        }

        if (code & 0x80) {
            code &= 0x7F;
            m_up = true;
        }

        int hidCode = GP101ToHID[m_layer][code];
        if (!hidCode) {
            Debugger.Log(LogLevel.Error, "PS2Keyboard", "Unknown code %d at layer %d", code, m_layer);
        } else if (hidCode == -1) {
            /* Fake shift (ignored) */
        } else {
            if (m_up)
                m_kb.HandleEvent((1 << 31) | hidCode);
            else
                m_kb.HandleEvent((0 << 31) | hidCode);
        }

        m_up    = 0;
        m_layer = 0;
    }

    package static void UpdateLED() {
        Debugger.Log(LogLevel.Notice, "PS2Keyboard", "LED is not implemented yet!");
    }
}