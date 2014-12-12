module VFSManager.DirectoryNode;

import Library;
import VFSManager;


class DirectoryNode : FSNode {
	package IFileSystem _fileSystem;
	private LinkedList!FSNode _childrens;
	private DirectoryNode _mounted;
	private bool _isLoaded;

	@property ref bool IsLoaded() {
		if (_mounted)
			return _mounted.IsLoaded;

		return _isLoaded;
	}

	@property ref IFileSystem FileSystem() {
		if (_mounted)
			return _mounted.FileSystem;

		return _fileSystem;
	}

	@property override FileAttributes Attributes() {
		if (_attributes.Name == "/" && _parent)
			return _parent.Attributes;

		return _attributes;
	}

	@property override void Attributes(FileAttributes value) {
		if (_attributes.Name == "/" && _parent)
			return _parent.Attributes = value;
		else
			_attributes = value;
	}

	@property override DirectoryNode Parent() {
		if (_attributes.Name == "/" && _parent)
			return _parent.Parent;
		
		return _parent;
	}

	@property LinkedList!FSNode Childrens() {
		if (_mounted)
			return _mounted.Childrens;

		LoadContent();
		return _childrens;
	}

	@property bool IsMountpointable() {
		if (!LoadContent())
			return false;

		return !_childrens.Count;
	}

	this(DirectoryNode parent, FileAttributes fileAttributes) {
		_childrens  = new LinkedList!FSNode();
		_attributes = fileAttributes;
		_attributes.Type = FileType.Directory;

		if (parent)
			_fileSystem = parent._fileSystem;

		super(parent);
	}

	~this() {
		if (_attributes.Name == "/" && _parent)
			(cast(DirectoryNode)_parent).Unmount();

		foreach (x; _childrens)
			delete x;

		delete _childrens;
	}

	void Unmount() {
		_attributes.Type = FileType.Directory;
		_mounted._parent = null;

		delete _mounted;
		_mounted = null;
	}

	bool Mount(DirectoryNode childRoot) {
		if (IsMountpointable && childRoot._parent is null) {
			_mounted = childRoot;
			_attributes.Type = FileType.Mountpoint;
			childRoot._parent = this;

			return true;
		}

		return false;
	}

	FSNode opIndex(string name) {
		if (_mounted)
			return _mounted[name];

		if (!LoadContent())
			return null;

		foreach (x; _childrens)
			if (x.Value.Attributes.Name == name)
				return x.Value;

		return null;
	}

	FSNode Create(FileAttributes attributes) {
		if (_mounted)
			return _mounted.Create(attributes);

		if (_fileSystem is null)
			return null;
			
		return _fileSystem.Create(this, attributes);
	}

	private bool LoadContent() {
		if (_mounted)
			return _mounted.LoadContent();

		if (IsLoaded || _fileSystem is null)
			return true;

		_isLoaded = _fileSystem.LoadContent(this);
		return _isLoaded;
	}
}