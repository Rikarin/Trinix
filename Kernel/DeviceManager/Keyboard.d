module DeviceManager.Keyboard;

import Resources.Keymaps.EN;
import Devices.Keyboard.KeyCodes;

import System.Collections.Generic.All;
import System.Threading.All;


class Keyboard {
public:
static:
	__gshared private List!(Key) buffer;


	bool Init() {
        buffer = new List!(Key)();
        return true;
	}

	void UpdateLeds(KeyLedStatus status) {
		//TODO
	}

    void KeyHandler(Key key, bool released) {
        if (!released) {
            if (key == Key.Capslock)
                UpdateLeds(KeyLedStatus.CapsLock);
            else if (key == Key.NumLock)
                UpdateLeds(KeyLedStatus.NumLock);
            else if (key == Key.ScrollLock)
                UpdateLeds(KeyLedStatus.ScrLock);
        }

       // buffer.Add(released ? -key : key);
        //import Core.Log; Log.Print("!");
    }

    Key GetKey() {
        if (!buffer.Count)
            return Key.Null;

        Key ret = buffer[0];
        buffer.RemoveAt(0);
        return ret;
    }

	/*void KeyPress(ubyte code) {
		KeyStatus ks;
        ks.Clear();
		ks.Pressed = true;
		ks.Modifiers = status & 0x0F;

		ubyte cmd = ControllKeys[code];
		code &= 0x7F;

		if (!cmd) {
			cmd = ControllKeys[code];

			ks.HasChar = true;
			ks.Character = 0;

			if((status & STATUS_ALT) || (status & STATUS_CTRL))
				ks.HasCmd = true;

			if ((status & STATUS_SHIFT) ^ (status & STATUS_CAPS)) {
	            if (status & STATUS_ALTGR)
	                ks.Character = KeymapShiftAltGr[code];
	            else {
	                if (status & STATUS_CAPS)
	                    ks.Character = KeymapCaps[code];
	                else
	                    ks.Character = KeymapShift[code];
	            }
       		} else {
	            if (status & STATUS_ALTGR)
	                ks.Character = KeymapAltGr[code];
	            else
	                ks.Character = KeymapNormal[code];
	        }
		} else if (cmd >= KBDC_KPINSERT && cmd <= KBDC_KPDEL && (status & STATUS_NUM)) {
        	ks.HasChar = true;
        	if ((status & STATUS_ALT) || (status & STATUS_CTRL))
            	ks.HasCmd = true;
        
        	if (cmd == KBDC_KPDEL)
            	ks.Character = '.';
        	else
            	ks.Character = '0' + (cmd - KBDC_KPINSERT);
    	} else if (cmd == KBDC_KPSLASH) {
        	ks.HasChar = true;
        	if ((status & STATUS_ALT) || (status & STATUS_CTRL))
            	ks.HasCmd = true;
        	ks.HasCmd = true;
    	} else if (cmd == KBDC_ALT)
        	status |= STATUS_ALT;
    	else if (cmd == KBDC_ALTGR)
        	status |= STATUS_ALTGR;
    	else if (cmd == KBDC_LEFTCTRL || cmd == KBDC_RIGHTCTRL)
	        status |= STATUS_CTRL;
    	else if (cmd == KBDC_LEFTSHIFT || cmd == KBDC_RIGHTSHIFT)
        	status |= STATUS_SHIFT;
    	else if (cmd == KBDC_CAPSLOCK) {
        	status ^= STATUS_CAPS;
        	UpdateLeds();
    	} else if (cmd == KBDC_NUMLOCK) {
        	status ^= STATUS_NUM;
        	UpdateLeds();
    	} else if (cmd == KBDC_SCRLLOCK) {
        	status ^= STATUS_SCRL;
        	UpdateLeds();
    	}
     
    	if (!ks.HasChar) {
        	ks.HasCmd = true;
        	ks.Command = cmd;
    	}
        
    	Process(ks);
	}*/
}