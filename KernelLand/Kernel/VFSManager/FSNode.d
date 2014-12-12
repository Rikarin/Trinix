module VFSManager.FSNode;

import VFSManager;
import TaskManager;
import Architecture;
import ObjectManager;
import SyscallManager;


abstract class FSNode : Resource {
	package DirectoryNode _parent;
	protected FileAttributes _attributes;

	protected this(DirectoryNode parent) {
		static const CallTable[] callTable = [
			{0, ".Attributes", 0, null}
		];

		if (parent !is null) {
			_parent = parent;
			parent.Childrens.Add(this);
		}

		super(DeviceType.Disk, "com.trinix.VFSManager.FSNode", 0x1, callTable);
	}

	~this() {
		if (_parent !is null)
			_parent.Childrens.Remove(this);

		delete _attributes.Name;
	}

	@property DirectoryNode Parent() {
		return _parent;
	}

	@property FileAttributes Attributes() {
		return _attributes;
	}

	@property void Attributes(FileAttributes value) {
		_attributes = value;
	}

	ulong Read(long offset, byte[] data) {
		return 0;
	}
	
	ulong Write(long offset, byte[] data) {
		return 0;
	}

	ulong IOControl(long id, byte[] data) {
		return 0;
	}

	bool Remove() {
		if (_parent is null || _parent.FileSystem is null)
			return false;

		if (_attributes.Type == (FileType.Directory | FileType.Mountpoint) && (cast(DirectoryNode)this).Childrens.Count)
			return false;
			
		return _parent.FileSystem.Remove(this);
	}

	static FileAttributes NewAttributes(string name, FileType type = FileType.Directory) {
		FileAttributes ret;
		ret.Name        = name;
		ret.Type        = type;
		ret.Permissions = FilePermissions.UserRead | FilePermissions.UserWrite | FilePermissions.GroupRead | FilePermissions.OtherRead;
		ret.UID         = Task.CurrentProcess.UID;
		ret.GID         = Task.CurrentProcess.GID;
		ret.AccessTime  = Time.Now;
		ret.ModifyTime  = ret.AccessTime;
		ret.CreateTime  = ret.AccessTime;

		return ret;
	}
}