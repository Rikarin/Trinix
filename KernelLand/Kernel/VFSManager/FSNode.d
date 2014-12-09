module VFSManager.FSNode;

import VFSManager;
import Architecture;
import SyscallManager;


public abstract class FSNode : Resource {
	package DirectoryNode _parent;
	protected FileAttributes _attributes;

	protected this(DirectoryNode parent) {
		const CallTable[] callTable = [
		];

		if (parent !is null) {
			_parent = parent;
			parent.Childrens.Add(this);
		}

		super(SyscallTypes.FSNode, callTable);
	}

	public ~this() {
		if (_parent !is null) {
			if (_parent._fileSystem !is null)
				_parent._fileSystem.Remove(this);

			_parent.Childrens.Remove(this);
		}
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