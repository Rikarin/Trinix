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

module Modules.Input.Keyboard.Keysyms;

enum Keysyms {
    KEYSYM_NONE,
    KEYSYM_ERRORROLLOVER,
    KEYSYM_POSTFAIL,
    KEYSYM_ERRORUNDEFINED,
    
    /* 0x04 / 4 */
    KEYSYM_A, KEYSYM_B, KEYSYM_C,
    KEYSYM_D, KEYSYM_E, KEYSYM_F,
    KEYSYM_G, KEYSYM_H, KEYSYM_I,
    KEYSYM_J, KEYSYM_K, KEYSYM_L,
    KEYSYM_M, KEYSYM_N, KEYSYM_O,
    KEYSYM_P, KEYSYM_Q, KEYSYM_R,
    KEYSYM_S, KEYSYM_T, KEYSYM_U,
    KEYSYM_V, KEYSYM_W, KEYSYM_X,
    KEYSYM_Y, KEYSYM_Z,

    /* 0x1E / 30 */
    KEYSYM_1, KEYSYM_2,
    KEYSYM_3, KEYSYM_4,
    KEYSYM_5, KEYSYM_6,
    KEYSYM_7, KEYSYM_8,
    KEYSYM_9, KEYSYM_0,

    KEYSYM_RETURN,       /* Enter */
    KEYSYM_ESC,
    KEYSYM_BACKSP,
    KEYSYM_TAB,
    KEYSYM_SPACE,
    KEYSYM_MINUS,        /* - _ */
    KEYSYM_EQUALS,	     /* = + */
    KEYSYM_SQUARE_OPEN,	 /* [ { */
    KEYSYM_SQUARE_CLOSE, /* ] } */
    KEYSYM_BACKSLASH,    /* \ | */
    KEYSYM_HASH_TILDE,   /* # ~ (Non-US) */
    KEYSYM_SEMICOLON,    /* ; : */
    KEYSYM_QUOTE,        /* ' " */
    KEYSYM_GRAVE_TILDE,  /* Grave Accent, Tilde */
    KEYSYM_COMMA,        /* , < */
    KEYSYM_PERIOD,       /* . > */
    KEYSYM_SLASH,        /* / ? */
    KEYSYM_CAPS,
    KEYSYM_F1, KEYSYM_F2,
    KEYSYM_F3, KEYSYM_F4,
    KEYSYM_F5, KEYSYM_F6,
    KEYSYM_F7, KEYSYM_F8,
    KEYSYM_F9, KEYSYM_F10,
    KEYSYM_F11, KEYSYM_F12,
    KEYSYM_PRINTSCREEN,
    KEYSYM_SCROLLLOCK,
    KEYSYM_PAUSE,
    KEYSYM_INSERT,
    KEYSYM_HOME,
    KEYSYM_PGUP,
    KEYSYM_DELETE,
    KEYSYM_END,
    KEYSYM_PGDN,
    KEYSYM_RIGHTARROW,
    KEYSYM_LEFTARROW,
    KEYSYM_DOWNARROW,
    KEYSYM_UPARROW,

    KEYSYM_NUMLOCK,
    KEYSYM_KPSLASH,
    KEYSYM_KPSTAR,
    KEYSYM_KPMINUS,
    KEYSYM_KPPLUS,
    KEYSYM_KPENTER,
    KEYSYM_KP1,
    KEYSYM_KP2,
    KEYSYM_KP3,
    KEYSYM_KP4,
    KEYSYM_KP5,
    KEYSYM_KP6,
    KEYSYM_KP7,
    KEYSYM_KP8,
    KEYSYM_KP9,
    KEYSYM_KP0,
    KEYSYM_KPPERIOD,

    KEYSYM_NONUS_BACKSLASH,
    KEYSYM_APPLICATION,	/* Menu */
    KEYSYM_POWER,
    KEYSYM_KPEQUALS,

    KEYSYM_F13, KEYSYM_F14,
    KEYSYM_F15, KEYSYM_F16,
    KEYSYM_F17, KEYSYM_F18,
    KEYSYM_F19, KEYSYM_F20,
    KEYSYM_F21, KEYSYM_F22,
    KEYSYM_F23, KEYSYM_F24,
    KEYSYM_EXECUTE,
    KEYSYM_HELP,
    KEYSYM_MENU,
    KEYSYM_SELECT,
    KEYSYM_STOP,
    KEYSYM_AGAIN,
    KEYSYM_UNDO,
    KEYSYM_CUT,
    KEYSYM_COPY,
    KEYSYM_PASTE,
    KEYSYM_FIND,
    KEYSYM_MUTE,
    KEYSYM_VOLUP,
    KEYSYM_VOLDN,
    KEYSYM_LOCKING_CAPS, /* Physically toggles */
    KEYSYM_LOGKING_NUM,
    KEYSYM_LOGKING_SCROLL,
    KEYSYM_KPCOMMA,
    KEYSYM_KPEQUAL,
    KEYSYM_KBINT1,
    KEYSYM_KBINT2,
    KEYSYM_KBINT3,
    KEYSYM_KBINT4,
    KEYSYM_KBINT5,
    KEYSYM_KBINT6,
    KEYSYM_KBINT7,
    KEYSYM_KBINT8,
    KEYSYM_KBINT9,

    KEYSYM_LANG1,
    KEYSYM_LANG2,
    KEYSYM_LANG3,
    KEYSYM_LANG4,
    KEYSYM_LANG5,
    KEYSYM_LANG6,
    KEYSYM_LANG7,
    KEYSYM_LANG8,
    KEYSYM_LANG9,

    KEYSYM_ALT_ERASE,
    KEYSYM_SYSRQ,
    KEYSYM_CANCEL,
    KEYSYM_CLEAR,
    KEYSYM_PRIOR,
    KEYSYM_RETURN_,
    KEYSYM_SEPAR,
    KEYSYM_OUT,
    KEYSYM_OPER,

    KEYSYM_LEFTCTRL = 0xE0,
    KEYSYM_LEFTSHIFT,
    KEYSYM_LEFTALT,
    KEYSYM_LEFTGUI,	/* Menu */
    KEYSYM_RIGHTCTRL,
    KEYSYM_RIGHTSHIFT,
    KEYSYM_RIGHTALT,
    KEYSYM_RIGHTGUI

    /* > 0xE7 is undefined as of revision 1.12 of the HID Usage Tables */
}