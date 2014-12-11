module VFSManager.FSNode;

import VFSManager;
import Architecture;
import ObjectManager;
import SyscallManager;


public abstract class FSNode : Resource {
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

	public ~this() {
		if (_parent !is null)
			_parent.Childrens.Remove(this);

		delete _attributes.Name;
	}

	@property public DirectoryNode Parent() {
		return _parent;
	}

	@property public FileAttributes Attributes() {
		return _attributes;
	}

	@property public void Attributes(FileAttributes value) {
		_attributes = value;
	}

	public ulong Read(long offset, byte[] data) {
		return 0;
	}
	
	public ulong Write(long offset, byte[] data) {
		return 0;
	}

	public ulong IOControl(long id, byte[] data) {
		return 0;
	}

	public bool Remove() {
		if (_parent is null || _parent.FileSystem is null)
			return false;

		if (_attributes.Type == (FileType.Directory | FileType.Mountpoint) && (cast(DirectoryNode)this).Childrens.Count)
			return false;
			
		return _parent.FileSystem.Remove(this);
	}

	public static FileAttributes NewAttributes(string name, FileType type = FileType.Directory) {
		FileAttributes ret;
		ret.Name        = name;
		ret.Type        = type;
		ret.Permissions = FilePermissions.UserRead | FilePermissions.UserWrite | FilePermissions.GroupRead | FilePermissions.OtherRead;
		ret.UID         = 123; //TODO
		ret.GID         = 456; //TODO
		ret.AccessTime  = Time.Now;
		ret.ModifyTime  = ret.AccessTime;
		ret.CreateTime  = ret.AccessTime;

		return ret;
	}
}