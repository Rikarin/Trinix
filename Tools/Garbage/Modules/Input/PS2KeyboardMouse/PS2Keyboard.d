/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
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