module DeviceManager.Device;

import System.Collections.Generic.All;
import Architectures.Core : InterruptStack;
import Devices.DeviceProto;


enum DeviceType {
	Default,
	System,
	Keyboard,
	Display
}

struct DeviceInfo {
	this(string name, DeviceType type) { Name = name; Type = type; }
	string Name;
	DeviceType Type;
}
	

class Device {
private:
	struct Data {
		DeviceProto dev;
		DeviceInfo info;
	}
	
	__gshared List!(Data) devices;
	__gshared DeviceProto IRQHandler[16]; 
	
	
public:
static:
	bool Init() {
		devices = new List!(Data)();
		foreach (i, d; IRQHandler)
			IRQHandler[i] = null;

		return true;
	}

	void UnregisterDevice(DeviceProto dev) {
		foreach(x; devices) {
			if (x.dev == dev)
				devices.Remove(x);
		}
	}

	void RegisterDevice(DeviceProto dev, DeviceInfo info) {
		UnregisterDevice(dev);
		devices.Add(Data(dev, info));
	}

	bool RequestIRQ(DeviceProto dev, uint irq) {
		if (!IRQHandler[irq]) {
			IRQHandler[irq] = dev;
			return true;
		} else 
			return false;
	}

	void Handler(ref InterruptStack r) {
		if (IRQHandler[r.IntNumber - 32]) {
			IRQHandler[r.IntNumber - 32].IRQHandler(r);
		}
	}
	
	DeviceInfo GetInfo(DeviceProto dev) {
		foreach (x; devices) {
			if (x.dev == dev)
				return x.info;
		}

		return DeviceInfo();
	}

	DeviceProto GetDevice(DeviceInfo info) {
		foreach (x; devices) {
			if (x.info == info)
				return x.dev;
		}
		return null;
	}


	List!(DeviceProto) GetDevsByType(DeviceType type) {
		List!(DeviceProto) ret = new List!(DeviceProto)();

		foreach (x; devices) {
			if (x.info.Type == type)
				ret.Add(x.dev);
		}
		return ret;
	}
}
