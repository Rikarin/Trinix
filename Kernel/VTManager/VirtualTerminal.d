module VTManager.VirtualTerminal;

import System.Threading.All;
import Devices.Keyboard.KeyCodes;
import SyscallManager.Resource;
import DeviceManager.Keyboard;


abstract class VirtualTerminal /* : Resource */ {
protected:
	Mutex kbLock;
	bool capsed = false;


	void UpdateCursor();
	void Put(char c, bool updateSCR = true);


public:
	this() {
		kbLock = new Mutex();
	}

	~this() {
		delete kbLock;
	}
	
	bool IsBoxed();
	void Redraw();
	@property ushort Width();
	@property ushort Height();
	

    void WriteLine(string str, bool updateSCR = true) { 
        Write(str, updateSCR); 
        Put('\n', false); 
    }

	void Write(string str, bool updateSCR = true) {
		foreach (x; str) {
			//TODO
			Put(x, false);
		}


		if (updateSCR)
			UpdateCursor();
	}

	string Read() {
        string ret;
        bool big = capsed;

        while (true) {
        	Key k = Keyboard.GetKey();

            switch (k) {
            	case Key.Null:
            		continue;
            	case Key.LeftControl:
            	case Key.RightControl:
            		ret ~= '^';
            		break;
            	case Key.LeftAlt:
            	case Key.RightAlt:
            		ret ~= "&";
            		break;
            	case Key.LeftShift:
            	case Key.RightShift:
            		big = !big;
            		break;
            	case Key.Capslock:
            		capsed = !capsed;
            		big = !big;
            		break;
            	case Key.Return:
            		ret ~= '\n';
            		break;
            	case Key.Space:
            		ret ~= ' ';
            		break;
            	case Key.Tab:
            		ret ~= '\t';

            	default:
            }

            if (k >= Key.A && k <= Key.Z) {
            	ret ~= cast(char)(cast(ubyte)k + (big ? 'A' : 'a'));
            	return ret;
            }
        }
    }

	string ReadLine() {
		string ret;
		string r;

		do {
			r = Read();
			ret = ret ~ r;
		} while (r[0] != '\n');

		return ret;
	}
}