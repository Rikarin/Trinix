module Core.DeviceManager;

import System.Collections.Generic.List;
import Architectures.Core;
import Devices.DeviceProto;
import VFSManager.DirectoryNode;


enum DeviceType {
	Default,
	System,
	Keyboard,
	Mouse,
	Display
}

struct DeviceInfo {
	this(string name, DeviceType type) { Name = name; Type = type; }
	string Name;
	DeviceType Type;
}


class DeviceManager {
private:
	struct Data {
		DeviceProto dev;
		DeviceInfo info;
	}
	
	__gshared List!Data devices;
	__gshared DeviceProto IRQHandler[16];
	
	
public:
static:
	__gshared DirectoryNode DevFS;


	bool Init() {
		devices = new List!Data();
		DevFS = new DirectoryNode("dev", null);
		IRQHandler[] = null;

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


	List!DeviceProto GetDevsByType(DeviceType type) {
		List!DeviceProto ret = new List!DeviceProto();

		foreach (x; devices) {
			if (x.info.Type == type)
				ret.Add(x.dev);
		}
		return ret;
	}
}
