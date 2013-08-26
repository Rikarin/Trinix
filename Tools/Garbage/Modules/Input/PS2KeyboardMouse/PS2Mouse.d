/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Modules.Input.PS2KeyboardMouse.PS2Mouse;

import ObjectManager;

import Modules.Input.Mouse;
import Modules.Input.PS2KeyboardMouse;


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
        m_mouse = new Mouse("PS2Mouse", _DriverInfo_Input_PS2Mouse.Version, NUM_AXIES, NUM_BUTTONS);
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