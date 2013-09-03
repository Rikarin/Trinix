module Devices.Keyboard.KeyCodes;


enum Key : byte {
	Null = -1,

	A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,

	Num0, Num1, Num2, Num3, Num4, Num5, Num6, Num7, Num8, Num9,

	Quote, Minus, Equals, Slash, Backspace, Space, Tab, Capslock, 
	LeftShift, LeftControl, LeftAlt, RightShift, Return, Escape,
	
	F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, 

	ScrollLock, LeftBracket, NumLock, KeypadAsterisk, KeypadMinus, KeypadPlus, KeypadPeriod, 
	Keypad0, Keypad1, Keypad2, Keypad3, Keypad4, Keypad5, Keypad6, Keypad7, Keypad8, Keypad9, 
	RightBracket, Semicolon, Apostrophe, Comma, Period, Backslash,

	LeftMeta, RightControl, RightMeta, RightAlt, Application, Insert, Home, PageUp, PageDown,
	Delete, End, Up, Left, Right, Down, KeypadSlash, KeypadReturn,

	Next, Previous, Stop, Play, Mute, VolumeUp, VolumeDown, Media, EMail, Calculator, Computer,

	WebSearch, WebHome, WebBack, WebForward, WebStop, WebRefresh, WebFavorites
}

enum KeyLedStatus : short {
	ScrLock  = 1,
	NumLock  = 2,
	CapsLock = 4
}