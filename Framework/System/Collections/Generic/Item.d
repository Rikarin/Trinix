module System.Collections.Generic.Item;

class Item(T, D) {
	T Name;
	D Property;
	
	this() { }
	
	this(T name, D property) {
		Name = name;
		Property = property;
	}
	
	void Set(T name, D property) {
		Name = name;
		Property = property;
	}
}
