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

module Modules.Input.PS2KeyboardMouse.KeyboardTransTab;

import Modules.Input.Keyboard;


__gshared const int[] GD101ToHID1 = [
	0,
	/* First row (0x01 - 0x0e) */
	Keysyms.KEYSYM_ESC,          Keysyms.KEYSYM_1,         Keysyms.KEYSYM_2,
    Keysyms.KEYSYM_3,            Keysyms.KEYSYM_4,         Keysyms.KEYSYM_5,
    Keysyms.KEYSYM_6,            Keysyms.KEYSYM_7,         Keysyms.KEYSYM_8,
    Keysyms.KEYSYM_9,            Keysyms.KEYSYM_0,         Keysyms.KEYSYM_MINUS,
    Keysyms.KEYSYM_EQUALS,       Keysyms.KEYSYM_BACKSP,

	/* Second Row (0x0f - 0x1c) */
	Keysyms.KEYSYM_TAB,          Keysyms.KEYSYM_Q,         Keysyms.KEYSYM_W,
    Keysyms.KEYSYM_E,            Keysyms.KEYSYM_R,         Keysyms.KEYSYM_T,
    Keysyms.KEYSYM_Y,            Keysyms.KEYSYM_U,         Keysyms.KEYSYM_I,
    Keysyms.KEYSYM_O,            Keysyms.KEYSYM_P,         Keysyms.KEYSYM_SQUARE_OPEN,
    Keysyms.KEYSYM_SQUARE_CLOSE, Keysyms.KEYSYM_RETURN,

	/* Third Row (0x1d - 0x28) */
	Keysyms.KEYSYM_LEFTCTRL,     Keysyms.KEYSYM_A,         Keysyms.KEYSYM_S,
    Keysyms.KEYSYM_D,            Keysyms.KEYSYM_F,         Keysyms.KEYSYM_G,
    Keysyms.KEYSYM_H,            Keysyms.KEYSYM_J,         Keysyms.KEYSYM_K,
    Keysyms.KEYSYM_L,            Keysyms.KEYSYM_SEMICOLON, Keysyms.KEYSYM_QUOTE,
	
    /* Fourth Row (0x20 - 0x3e) */
	Keysyms.KEYSYM_GRAVE_TILDE,  Keysyms.KEYSYM_LEFTSHIFT, Keysyms.KEYSYM_BACKSLASH,
    Keysyms.KEYSYM_Z,            Keysyms.KEYSYM_X,         Keysyms.KEYSYM_C,
    Keysyms.KEYSYM_V,            Keysyms.KEYSYM_B,         Keysyms.KEYSYM_N,
    Keysyms.KEYSYM_M,            Keysyms.KEYSYM_COMMA,     Keysyms.KEYSYM_PERIOD,
	Keysyms.KEYSYM_SLASH,        Keysyms.KEYSYM_RIGHTSHIFT,
	
    /* Bottom row (0x3f - 0x42) */
	Keysyms.KEYSYM_KPSTAR,       Keysyms.KEYSYM_LEFTALT,   Keysyms.KEYSYM_SPACE,
    Keysyms.KEYSYM_CAPS,
	
    /* F Keys (0x43 - 0x4d) */
	Keysyms.KEYSYM_F1,           Keysyms.KEYSYM_F2,        Keysyms.KEYSYM_F3,
    Keysyms.KEYSYM_F4,           Keysyms.KEYSYM_F5,        Keysyms.KEYSYM_F6,
    Keysyms.KEYSYM_F7,           Keysyms.KEYSYM_F8,        Keysyms.KEYSYM_F9,
    Keysyms.KEYSYM_F10,
	
    /* Keypad */
	Keysyms.KEYSYM_NUMLOCK, Keysyms.KEYSYM_SCROLLLOCK,
	Keysyms.KEYSYM_KP7, Keysyms.KEYSYM_KP8,	Keysyms.KEYSYM_KP9, Keysyms.KEYSYM_KPMINUS,
	Keysyms.KEYSYM_KP4, Keysyms.KEYSYM_KP5,	Keysyms.KEYSYM_KP6, Keysyms.KEYSYM_KPPLUS,
	Keysyms.KEYSYM_KP1, Keysyms.KEYSYM_KP2, Keysyms.KEYSYM_KP3,
	Keysyms.KEYSYM_KP0, Keysyms.KEYSYM_KPPERIOD,
	0, 0, 0, Keysyms.KEYSYM_F11, Keysyms.KEYSYM_F12, 0, 0, 0, 0, 0, 0, 0,
    
    /* 60 */	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* 70 */	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

__gshared const int[] GP101ToHID2 = [
    /*   	 0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F */
    /* 00 */ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* 10 */ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Keysyms.KEYSYM_KPENTER, Keysyms.KEYSYM_RIGHTCTRL, 0, 0,
    /* 20 */ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1/* Fake LShift */, 0, 0, 0, 0, 0,
    /* 30 */ 0, 0, 0, 0, 0, Keysyms.KEYSYM_KPSLASH, 0, Keysyms.KEYSYM_PRINTSCREEN, Keysyms.KEYSYM_RIGHTALT, 0, 0, 0, 0, 0, 0, 0,
    /* 40 */ 0, 0, 0, 0, 0, 0, 0/* Break */, Keysyms.KEYSYM_HOME, Keysyms.KEYSYM_UPARROW, Keysyms.KEYSYM_PGUP, 0, Keysyms.KEYSYM_LEFTARROW, 0, Keysyms.KEYSYM_RIGHTARROW, 0, Keysyms.KEYSYM_END,
    /* 50 */ Keysyms.KEYSYM_DOWNARROW, Keysyms.KEYSYM_PGDN, Keysyms.KEYSYM_INSERT, Keysyms.KEYSYM_DELETE, 0, 0, 0, 0, 0, 0, 0, Keysyms.KEYSYM_LEFTGUI, Keysyms.KEYSYM_RIGHTGUI, Keysyms.KEYSYM_APPLICATION, Keysyms.KEYSYM_POWER/* Power */, 0/* Sleep */,
    /* 60 */ 0, 0, 0/* Wake */, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* 70 */ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

__gshared const int[] GP101ToHID3 = [
    //      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
    /* 00 */ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* 10 */ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Keysyms.KEYSYM_PAUSE, 0, 0,
    /* 20 */ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* 30 */ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* 40 */ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* 50 */ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* 60 */ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    /* 70 */ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
];

__gshared const int[][3] GP101ToHID = [
    GD101ToHID1,
    GP101ToHID2,
    GP101ToHID3
];