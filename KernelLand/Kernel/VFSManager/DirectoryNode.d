module VFSManager.DirectoryNode;

import Library;
import VFSManager;


public class DirectoryNode : FSNode {
	package IFileSystem _fileSystem;
	private LinkedList!FSNode _childrens;
	private DirectoryNode _mounted;
	private bool _isLoaded;

	@property public ref bool IsLoaded() {
		if (_mounted)
			return _mounted.IsLoaded;

		return _isLoaded;
	}

	@property public ref IFileSystem FileSystem() {
		if (_mounted)
			return _mounted.FileSystem;

		return _fileSystem;
	}

	@property public override FileAttributes Attributes() {
		if (_attributes.Name == "/" && _parent)
			return _parent.Attributes;

		return _attributes;
	}

	@property public override void Attributes(FileAttributes value) {
		if (_attributes.Name == "/" && _parent)
			return _parent.Attributes = value;
		else
			_attributes = value;
	}

	@property public override DirectoryNode Parent() {
		if (_attributes.Name == "/" && _parent)
			return _parent.Parent;
		
		return _parent;
	}

	@property public LinkedList!FSNode Childrens() {
		if (_mounted)
			return _mounted.Childrens;

		LoadContent();
		return _childrens;
	}

	@property public bool IsMountpointable() {
		if (!LoadContent())
			return false;

		return !_childrens.Count;
	}

	public this(DirectoryNode parent, FileAttributes fileAttributes) {
		_childrens  = new LinkedList!FSNode();
		_attributes = fileAttributes;
		_attributes.Type = FileType.Directory;

		if (parent)
			_fileSystem = parent._fileSystem;

		super(parent);
	}

	public ~this() {
		if (_attributes.Name == "/" && _parent)
			(cast(DirectoryNode)_parent).Unmount();

		foreach (x; _childrens)
			delete x;

		delete _childrens;
	}

	public void Unmount() {
		_attributes.Type = FileType.Directory;
		_mounted._parent = null;

		delete _mounted;
		_mounted = null;
	}

	public bool Mount(DirectoryNode childRoot) {
		if (IsMountpointable && childRoot._parent is null) {
			_mounted = childRoot;
			_attributes.Type = FileType.Mountpoint;
			childRoot._parent = this;

			return true;
		}

		return false;
	}

	public FSNode opIndex(string name) {
		if (_mounted)
			return _mounted[name];

		if (!LoadContent())
			return null;

		foreach (x; _childrens)
			if (x.Value.Attributes.Name == name)
				return x.Value;

		return null;
	}

	public FSNode Create(FileAttributes attributes) {
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

		FSNode n;
		int i = 1;
		do
			n = _fileSystem.Find(this, i++);
		while (n);

		return _isLoaded;
	}
}