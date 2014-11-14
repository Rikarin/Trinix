module Library.String;

import Library;


List!string Split(string str, char delimiter) {
	auto ret = new List!string();
	
	long a = 0;
	foreach (i, x; str) {
		if (x == delimiter) {
			ret.Add(str[a .. i]);
			a = i + 1;
		}
	}
	
	ret.Add(str[a .. $]);
	return ret;
}

string ToString(char* str) {
	int i;
	while (str[i++] != '\0') {}
	return cast(string)str[0 .. i];
}