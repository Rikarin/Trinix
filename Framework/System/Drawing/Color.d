module System.Drawing.Color;

import System.Convert;


//ARGB = Alpha Red Green Blue
enum KnownColor : int {
	AliceBlue            = 0xFFF0F8FF,
	AntiqueWhite         = 0xFFFAEBD7,
	Aqua                 = 0xFF00FFFF,
	Aquamarine           = 0xFF7FFFD4,
	Azure                = 0xFFF0FFFF,
	Beige                = 0xFFF5F5DC,
	Bisque               = 0xFFFFE4C4,
	Black                = 0xFF000000,
	BlanchedAlmond       = 0xFFFFEBCD,
	Blue                 = 0xFF0000FF,
	BlueViolet           = 0xFF8A2BE2,
	Brown                = 0xFFA52A2A,
	BurlyWood            = 0xFFDEB887,
	CadetBlue            = 0xFF5F9EA0,
	Chartreuse           = 0xFF7FFF00,
	Chocolate            = 0xFFD2691E,
	Coral                = 0xFFFF7F50,
	CornflowerBlue       = 0xFF6495ED,
	Cornsilk             = 0xFFFFF8DC,
	Crimson              = 0xFFDC143C,
	Cyan                 = 0xFF00FFFF,
	DarkBlue             = 0xFF00008B,
	DarkCyan             = 0xFF008B8B,
	DarkGoldenrod        = 0xFFB8860B,
	DarkGray             = 0xFFA9A9A9,
	DarkGreen            = 0xFF006400,
	DarkKhaki            = 0xFFBDB76B,
	DarkMagenta          = 0xFF8B008B,
	DarkOliveGreen       = 0xFF556B2F,
	DarkOrange           = 0xFFFF8C00,
	DarkOrchid           = 0xFF9932CC,
	DarkRed              = 0xFF8B0000,
	DarkSalmon           = 0xFFE9967A,
	DarkSeaGreen         = 0xFF8FBC8F,
	DarkSlateBlue        = 0xFF483D8B,
	DarkSlateGray        = 0xFF2F4F4F,
	DarkTurquoise        = 0xFF00CED1,
	DarkViolet           = 0xFF9400D3,
	DeepPink             = 0xFFFF1493,
	DeepSkyBlue          = 0xFF00BFFF,
	DimGray              = 0xFF696969,
	DodgerBlue           = 0xFF1E90FF,
	Firebrick            = 0xFFB22222,
	FloralWhite          = 0xFFFFFAF0,
	ForestGreen          = 0xFF228B22,
	Fuchsia              = 0xFFFF00FF,
	Gainsboro            = 0xFFDCDCDC,
	GhostWhite           = 0xFFF8F8FF,
	Gold                 = 0xFFFFD700,
	Goldenrod            = 0xFFDAA520,
	Gray                 = 0xFF808080,
	Green                = 0xFF008000,
	GreenYellow          = 0xFFADFF2F,
	Honeydew             = 0xFFF0FFF0,
	HotPink              = 0xFFFF69B4,
	IndianRed            = 0xFFCD5C5C,
	Indigo               = 0xFF4B0082,
	Ivory                = 0xFFFFFFF0,
	Khaki                = 0xFFF0E68C,
	Lavender             = 0xFFE6E6FA,
	LavenderBlush        = 0xFFFFF0F5,
	LawnGreen            = 0xFF7CFC00,
	LemonChiffon         = 0xFFFFFACD,
	LightBlue            = 0xFFADD8E6,
	LightCoral           = 0xFFF08080,
	LightCyan            = 0xFFE0FFFF,
	LightGoldenrodYellow = 0xFFFAFAD2,
	LightGreen           = 0xFF90EE90,
	LightGray            = 0xFFD3D3D3,
	LightPink            = 0xFFFFB6C1,
	LightSalmon          = 0xFFFFA07A,
	LightSeaGreen        = 0xFF20B2AA,
	LightSkyBlue         = 0xFF87CEFA,
	LightSlateGray       = 0xFF778899,
	LightSteelBlue       = 0xFFB0C4DE,
	LightYellow          = 0xFFFFFFE0,
	Lime                 = 0xFF00FF00,
	LimeGreen            = 0xFF32CD32,
	Linen                = 0xFFFAF0E6,
	Magenta              = 0xFFFF00FF,
	Maroon               = 0xFF800000,
	MediumAquamarine     = 0xFF66CDAA,
	MediumBlue           = 0xFF0000CD,
	MediumOrchid         = 0xFFBA55D3,
	MediumPurple         = 0xFF9370DB,
	MediumSeaGreen       = 0xFF3CB371,
	MediumSlateBlue      = 0xFF7B68EE,
	MediumSpringGreen    = 0xFF00FA9A,
	MediumTurquoise      = 0xFF48D1CC,
	MediumVioletRed      = 0xFFC71585,
	MidnightBlue         = 0xFF191970,
	MintCream            = 0xFFF5FFFA,
	MistyRose            = 0xFFFFE4E1,
	Moccasin             = 0xFFFFE4B5,
	NavajoWhite          = 0xFFFFDEAD,
	Navy                 = 0xFF000080,
	OldLace              = 0xFFFDF5E6,
	Olive                = 0xFF808000,
	OliveDrab            = 0xFF6B8E23,
	Orange               = 0xFFFFA500,
	OrangeRed            = 0xFFFF4500,
	Orchid               = 0xFFDA70D6,
	PaleGoldenrod        = 0xFFEEE8AA,
	PaleGreen            = 0xFF98FB98,
	PaleTurquoise        = 0xFFAFEEEE,
	PaleVioletRed        = 0xFFDB7093,
	PapayaWhip           = 0xFFFFEFD5,
	PeachPuff            = 0xFFFFDAB9,
	Peru                 = 0xFFCD853F,
	Pink                 = 0xFFFFC0CB,
	Plum                 = 0xFFDDA0DD,
	PowderBlue           = 0xFFB0E0E6,
	Purple               = 0xFF800080,
	Red                  = 0xFFFF0000,
	RosyBrown            = 0xFFBC8F8F,
	RoyalBlue            = 0xFF4169E1,
	SaddleBrown          = 0xFF8B4513,
	Salmon               = 0xFFFA8072,
	SandyBrown           = 0xFFF4A460,
	SeaGreen             = 0xFF2E8B57,
	SeaShell             = 0xFFFFF5EE,
	Sienna               = 0xFFA0522D,
	Silver               = 0xFFC0C0C0,
	SkyBlue              = 0xFF87CEEB,
	SlateBlue            = 0xFF6A5ACD,
	SlateGray            = 0xFF708090,
	Snow                 = 0xFFFFFAFA,
	SpringGreen          = 0xFF00FF7F,
	SteelBlue            = 0xFF4682B4,
	Tan                  = 0xFFD2B48C,
	Teal                 = 0xFF008080,
	Thistle              = 0xFFD8BFD8,
	Tomato               = 0xFFFF6347,
	Transparent          = 0x00FFFFFF,
	Turquoise            = 0xFF40E0D0,
	Violet               = 0xFFEE82EE,
	Wheat                = 0xFFF5DEB3,
	White                = 0xFFFFFFFF,
	WhiteSmoke           = 0xFFF5F5F5,
	Yellow               = 0xFFFFFF00,
	YellowGreen          = 0xFF9ACD32,
	UnknownColor         = 0x00000001
}


class Color {
private:
	int color;
	bool init = false;
	bool system = false;
	string name = "null";


	float[] GetHSB() {
		float hue, saturation, brightness;

		float cmax = (R > G) ? R : G;
		if (B > cmax)
			cmax = B;

		float cmin = (R < G) ? R : G;
		if (B < cmin)
			cmin = B;

		brightness = cmax / 255.0f;

		if (cmax != 0)
			saturation = (cmax - cmin) / cmax;
		else
			saturation = 0;

		if (!saturation)
			hue = 0;
		else {
			float redc   = (cmax - R) / (cmax - cmin);
			float greenc = (cmax - G) / (cmax - cmin);
			float bluec  = (cmax - B) / (cmax - cmin);

			if (R == cmax)
				hue = bluec - greenc;
			else if (G == cmax)
				hue = 2.0f + redc - bluec;
			else
				hue = 4.0f + greenc - redc;

			hue /= 6.0f;
			if (hue < 0)
				hue += 1.0f;
		}

		return [hue, saturation, brightness];
	}


public:
	@property byte A() { return (color >> 24) & 0xFF; }
	@property byte R() { return (color >> 16) & 0xFF; }
	@property byte G() { return (color >> 8) & 0xFF; }
	@property byte B() { return color & 0xFF; }

	@property bool IsEmpty() { return init == false; }
	@property string Name() { return name; }

	@property bool IsSystemColor() { return system; }
	@property bool IsNamedColor() { return system; }
	@property bool IsKnownColor() { return system; }

	float GetHue() { return GetHSB()[0]; }
	float GetSaturation() { return GetHSB()[1]; }
	float GetBrightness() { return GetHSB()[2]; }
	int ToArgb() { return color; }


	bool opEquals(const Color other) {
		if (this is other)
			return true;

		if (other is null)
			return false;

		return color == other.color;
	}


static:
	Color FromKnownColor(KnownColor color) { //TODO
		Color ret = new Color();
		ret.init = true;
		ret.color = color;
		ret.system = true;
		//ret.name

		return ret;
	}

	Color FromName(string name) {
		Color ret = new Color();
		ret.init = true;
		ret.color = ColorStringToKnownColor(name);
		ret.system = true;
		ret.name = name;

		return ret;
	}

	Color FromArgb(int argb) {
		Color ret = new Color();
		ret.init = true;
		ret.color = argb;
		ret.name = Convert.ToString(argb, 16);

		return ret;
	}

	Color FromArgb(byte alpha, Color baseColor) {
		Color ret = new Color();
		ret.init = true;
		ret.color = (alpha << 24) | (baseColor.color & 0xFFFFFF);
		ret.name = Convert.ToString(ret.color, 16);

		return ret;
	}

	Color FromArgb(byte red, byte green, byte blue) {
		Color ret = new Color();
		ret.init = true;
		ret.color = (0xFF << 24) | (red << 16) | (green << 8) | blue;
		ret.name = Convert.ToString(ret.color, 16);

		return ret;
	}

	Color FromArgb(byte alpha, byte red, byte green, byte blue) {
		Color ret = new Color();
		ret.init = true;
		ret.color = (alpha << 24) | (red << 16) | (green << 8) | blue;
		ret.name = Convert.ToString(ret.color, 16);

		return ret;
	}


	@property Color Empty()                { return FromKnownColor(KnownColor.UnknownColor); }
	@property Color AliceBlue()            { return FromKnownColor(KnownColor.AliceBlue); }
	@property Color AntiqueWhite()         { return FromKnownColor(KnownColor.AntiqueWhite); }
	@property Color Aqua()                 { return FromKnownColor(KnownColor.Aqua); }
	@property Color Aquamarine()           { return FromKnownColor(KnownColor.Aquamarine); }
	@property Color Azure()                { return FromKnownColor(KnownColor.Azure); }
	@property Color Beige()                { return FromKnownColor(KnownColor.Beige); }
	@property Color Bisque()               { return FromKnownColor(KnownColor.Bisque); }
	@property Color Black()                { return FromKnownColor(KnownColor.Black); }
	@property Color BlanchedAlmond()       { return FromKnownColor(KnownColor.BlanchedAlmond); }
	@property Color Blue()                 { return FromKnownColor(KnownColor.Blue); }
	@property Color BlueViolet()           { return FromKnownColor(KnownColor.BlueViolet); }
	@property Color Brown()                { return FromKnownColor(KnownColor.Brown); }
	@property Color BurlyWood()            { return FromKnownColor(KnownColor.BurlyWood); }
	@property Color CadetBlue()            { return FromKnownColor(KnownColor.CadetBlue); }
	@property Color Chartreuse()           { return FromKnownColor(KnownColor.Chartreuse); }
	@property Color Chocolate()            { return FromKnownColor(KnownColor.Chocolate); }
	@property Color Coral()                { return FromKnownColor(KnownColor.Coral); }
	@property Color CornflowerBlue()       { return FromKnownColor(KnownColor.CornflowerBlue); }
	@property Color Cornsilk()             { return FromKnownColor(KnownColor.Cornsilk); }
	@property Color Crimson()              { return FromKnownColor(KnownColor.Crimson); }
	@property Color Cyan()                 { return FromKnownColor(KnownColor.Cyan); }
	@property Color DarkBlue()             { return FromKnownColor(KnownColor.DarkBlue); }
	@property Color DarkCyan()             { return FromKnownColor(KnownColor.DarkCyan); }
	@property Color DarkGoldenrod()        { return FromKnownColor(KnownColor.DarkGoldenrod); }
	@property Color DarkGray()             { return FromKnownColor(KnownColor.DarkGray); }
	@property Color DarkGreen()            { return FromKnownColor(KnownColor.DarkGreen); }
	@property Color DarkKhaki()            { return FromKnownColor(KnownColor.DarkKhaki); }
	@property Color DarkMagenta()          { return FromKnownColor(KnownColor.DarkMagenta); }
	@property Color DarkOliveGreen()       { return FromKnownColor(KnownColor.DarkOliveGreen); }
	@property Color DarkOrange()           { return FromKnownColor(KnownColor.DarkOrange); }
	@property Color DarkOrchid()           { return FromKnownColor(KnownColor.DarkOrchid); }
	@property Color DarkRed()              { return FromKnownColor(KnownColor.DarkRed); }
	@property Color DarkSalmon()           { return FromKnownColor(KnownColor.DarkSalmon); }
	@property Color DarkSeaGreen()         { return FromKnownColor(KnownColor.DarkSeaGreen); }
	@property Color DarkSlateBlue()        { return FromKnownColor(KnownColor.DarkSlateBlue); }
	@property Color DarkSlateGray()        { return FromKnownColor(KnownColor.DarkSlateGray); }
	@property Color DarkTurquoise()        { return FromKnownColor(KnownColor.DarkTurquoise); }
	@property Color DarkViolet()           { return FromKnownColor(KnownColor.DarkViolet); }
	@property Color DeepPink()             { return FromKnownColor(KnownColor.DeepPink); }
	@property Color DeepSkyBlue()          { return FromKnownColor(KnownColor.DeepSkyBlue); }
	@property Color DimGray()              { return FromKnownColor(KnownColor.DimGray); }
	@property Color DodgerBlue()           { return FromKnownColor(KnownColor.DodgerBlue); }
	@property Color Firebrick()            { return FromKnownColor(KnownColor.Firebrick); }
	@property Color FloralWhite()          { return FromKnownColor(KnownColor.FloralWhite); }
	@property Color ForestGreen()          { return FromKnownColor(KnownColor.ForestGreen); }
	@property Color Fuchsia()              { return FromKnownColor(KnownColor.Fuchsia); }
	@property Color Gainsboro()            { return FromKnownColor(KnownColor.Gainsboro); }
	@property Color GhostWhite()           { return FromKnownColor(KnownColor.GhostWhite); }
	@property Color Gold()                 { return FromKnownColor(KnownColor.Gold); }
	@property Color Goldenrod()            { return FromKnownColor(KnownColor.Goldenrod); }
	@property Color Gray()                 { return FromKnownColor(KnownColor.Gray); }
	@property Color Green()                { return FromKnownColor(KnownColor.Green); }
	@property Color GreenYellow()          { return FromKnownColor(KnownColor.GreenYellow); }
	@property Color Honeydew()             { return FromKnownColor(KnownColor.Honeydew); }
	@property Color HotPink()              { return FromKnownColor(KnownColor.HotPink); }
	@property Color IndianRed()            { return FromKnownColor(KnownColor.IndianRed); }
	@property Color Indigo()               { return FromKnownColor(KnownColor.Indigo); }
	@property Color Ivory()                { return FromKnownColor(KnownColor.Ivory); }
	@property Color Khaki()                { return FromKnownColor(KnownColor.Khaki); }
	@property Color Lavender()             { return FromKnownColor(KnownColor.Lavender); }
	@property Color LavenderBlush()        { return FromKnownColor(KnownColor.LavenderBlush); }
	@property Color LawnGreen()            { return FromKnownColor(KnownColor.LawnGreen); }
	@property Color LemonChiffon()         { return FromKnownColor(KnownColor.LemonChiffon); }
	@property Color LightBlue()            { return FromKnownColor(KnownColor.LightBlue); }
	@property Color LightCoral()           { return FromKnownColor(KnownColor.LightCoral); }
	@property Color LightCyan()            { return FromKnownColor(KnownColor.LightCyan); }
	@property Color LightGoldenrodYellow() { return FromKnownColor(KnownColor.LightGoldenrodYellow); }
	@property Color LightGray()            { return FromKnownColor(KnownColor.LightGray); }
	@property Color LightGreen()           { return FromKnownColor(KnownColor.LightGreen); }
	@property Color LightPink()            { return FromKnownColor(KnownColor.LightPink); }
	@property Color LightSalmon()          { return FromKnownColor(KnownColor.LightSalmon); }
	@property Color LightSeaGreen()        { return FromKnownColor(KnownColor.LightSeaGreen); }
	@property Color LightSkyBlue()         { return FromKnownColor(KnownColor.LightSkyBlue); }
	@property Color LightSlateGray()       { return FromKnownColor(KnownColor.LightSlateGray); }
	@property Color LightSteelBlue()       { return FromKnownColor(KnownColor.LightSteelBlue); }
	@property Color LightYellow()          { return FromKnownColor(KnownColor.LightYellow); }
	@property Color Lime()                 { return FromKnownColor(KnownColor.Lime); }
	@property Color LimeGreen()            { return FromKnownColor(KnownColor.LimeGreen); }
	@property Color Linen()                { return FromKnownColor(KnownColor.Linen); }
	@property Color Magenta()              { return FromKnownColor(KnownColor.Magenta); }
	@property Color Maroon()               { return FromKnownColor(KnownColor.Maroon); }
	@property Color MediumAquamarine()     { return FromKnownColor(KnownColor.MediumAquamarine); }
	@property Color MediumBlue()           { return FromKnownColor(KnownColor.MediumBlue); }
	@property Color MediumOrchid()         { return FromKnownColor(KnownColor.MediumOrchid); }
	@property Color MediumPurple()         { return FromKnownColor(KnownColor.MediumPurple); }
	@property Color MediumSeaGreen()       { return FromKnownColor(KnownColor.MediumSeaGreen); }
	@property Color MediumSlateBlue()      { return FromKnownColor(KnownColor.MediumSlateBlue); }
	@property Color MediumSpringGreen()    { return FromKnownColor(KnownColor.MediumSpringGreen); }
	@property Color MediumTurquoise()      { return FromKnownColor(KnownColor.MediumTurquoise); }
	@property Color MediumVioletRed()      { return FromKnownColor(KnownColor.MediumVioletRed); }
	@property Color MidnightBlue()         { return FromKnownColor(KnownColor.MidnightBlue); }
	@property Color MintCream()            { return FromKnownColor(KnownColor.MintCream); }
	@property Color MistyRose()            { return FromKnownColor(KnownColor.MistyRose); }
	@property Color Moccasin()             { return FromKnownColor(KnownColor.Moccasin); }
	@property Color NavajoWhite()          { return FromKnownColor(KnownColor.NavajoWhite); }
	@property Color Navy()                 { return FromKnownColor(KnownColor.Navy); }
	@property Color OldLace()              { return FromKnownColor(KnownColor.OldLace); }
	@property Color Olive()                { return FromKnownColor(KnownColor.Olive); }
	@property Color OliveDrab()            { return FromKnownColor(KnownColor.OliveDrab); }
	@property Color Orange()               { return FromKnownColor(KnownColor.Orange); }
	@property Color OrangeRed()            { return FromKnownColor(KnownColor.OrangeRed); }
	@property Color Orchid()               { return FromKnownColor(KnownColor.Orchid); }
	@property Color PaleGoldenrod()        { return FromKnownColor(KnownColor.PaleGoldenrod); }
	@property Color PaleGreen()            { return FromKnownColor(KnownColor.PaleGreen); }
	@property Color PaleTurquoise()        { return FromKnownColor(KnownColor.PaleTurquoise); }
	@property Color PaleVioletRed()        { return FromKnownColor(KnownColor.PaleVioletRed); }
	@property Color PapayaWhip()           { return FromKnownColor(KnownColor.PapayaWhip); }
	@property Color PeachPuff()            { return FromKnownColor(KnownColor.PeachPuff); }
	@property Color Peru()                 { return FromKnownColor(KnownColor.Peru); }
	@property Color Pink()                 { return FromKnownColor(KnownColor.Pink); }
	@property Color Plum()                 { return FromKnownColor(KnownColor.Plum); }
	@property Color PowderBlue()           { return FromKnownColor(KnownColor.PowderBlue); }
	@property Color Purple()               { return FromKnownColor(KnownColor.Purple); }
	@property Color Red()                  { return FromKnownColor(KnownColor.Red); }
	@property Color RosyBrown()            { return FromKnownColor(KnownColor.RosyBrown); }
	@property Color RoyalBlue()            { return FromKnownColor(KnownColor.RoyalBlue); }
	@property Color SaddleBrown()          { return FromKnownColor(KnownColor.SaddleBrown); }
	@property Color Salmon()               { return FromKnownColor(KnownColor.Salmon); }
	@property Color SandyBrown()           { return FromKnownColor(KnownColor.SandyBrown); }
	@property Color SeaGreen()             { return FromKnownColor(KnownColor.SeaGreen); }
	@property Color SeaShell()             { return FromKnownColor(KnownColor.SeaShell); }
	@property Color Sienna()               { return FromKnownColor(KnownColor.Sienna); }
	@property Color Silver()               { return FromKnownColor(KnownColor.Silver); }
	@property Color SkyBlue()              { return FromKnownColor(KnownColor.SkyBlue); }
	@property Color SlateBlue()            { return FromKnownColor(KnownColor.SlateBlue); }
	@property Color SlateGray()            { return FromKnownColor(KnownColor.SlateGray); }
	@property Color Snow()                 { return FromKnownColor(KnownColor.Snow); }
	@property Color SpringGreen()          { return FromKnownColor(KnownColor.SpringGreen); }
	@property Color SteelBlue()            { return FromKnownColor(KnownColor.SteelBlue); }
	@property Color Tan()                  { return FromKnownColor(KnownColor.Tan); }
	@property Color Teal()                 { return FromKnownColor(KnownColor.Teal); }
	@property Color Thistle()              { return FromKnownColor(KnownColor.Thistle); }
	@property Color Tomato()               { return FromKnownColor(KnownColor.Tomato); }
	@property Color Transparent()          { return FromKnownColor(KnownColor.Transparent); }
	@property Color Turquoise()            { return FromKnownColor(KnownColor.Turquoise); }
	@property Color Violet()               { return FromKnownColor(KnownColor.Violet); }
	@property Color Wheat()                { return FromKnownColor(KnownColor.Wheat); }
	@property Color White()                { return FromKnownColor(KnownColor.White); }
	@property Color WhiteSmoke()           { return FromKnownColor(KnownColor.WhiteSmoke); }
	@property Color Yellow()               { return FromKnownColor(KnownColor.Yellow); }
	@property Color YellowGreen()          { return FromKnownColor(KnownColor.YellowGreen); }


	private KnownColor ColorStringToKnownColor(string colorString) {
		string colorUpper = colorString; //TODO ToUpper...

		switch (colorUpper.length) {
			case 3:
				if (colorUpper == "RED") return KnownColor.Red;
				if (colorUpper == "TAN") return KnownColor.Tan;
				break;
			case 4:
				switch(colorUpper[0]) {
					case 'A':
						if (colorUpper == "AQUA") return KnownColor.Aqua;
						break;
					case 'B':
						if (colorUpper == "BLUE") return KnownColor.Blue;
						break;
					case 'C':
						if (colorUpper == "CYAN") return KnownColor.Cyan;
						break;
					case 'G':
						if (colorUpper == "GOLD") return KnownColor.Gold;
						if (colorUpper == "GRAY") return KnownColor.Gray;
						break;
					case 'L':
						if (colorUpper == "LIME") return KnownColor.Lime;
						break;
					case 'N':
						if (colorUpper == "NAVY") return KnownColor.Navy;
						break;
					case 'P':
						if (colorUpper == "PERU") return KnownColor.Peru;
						if (colorUpper == "PINK") return KnownColor.Pink;
						if (colorUpper == "PLUM") return KnownColor.Plum;
						break;
					case 'S':
						if (colorUpper == "SNOW") return KnownColor.Snow;
						break;
					case 'T':
						if (colorUpper == "TEAL") return KnownColor.Teal;
						break;
					default:
						return KnownColor.UnknownColor;
						break;
				}
				break;
			case 5:
				switch(colorUpper[0]) {
					case 'A':
						if (colorUpper == "AZURE") return KnownColor.Azure;
						break;
					case 'B':
						if (colorUpper == "BEIGE") return KnownColor.Beige;
						if (colorUpper == "BLACK") return KnownColor.Black;
						if (colorUpper == "BROWN") return KnownColor.Brown;
						break;
					case 'C':
						if (colorUpper == "CORAL") return KnownColor.Coral;
						break;
					case 'G':
						if (colorUpper == "GREEN") return KnownColor.Green;
						break;
					case 'I':
						if (colorUpper == "IVORY") return KnownColor.Ivory;
						break;
					case 'K':
						if (colorUpper == "KHAKI") return KnownColor.Khaki;
						break;
					case 'L':
						if (colorUpper == "LINEN") return KnownColor.Linen;
						break;
					case 'O':
						if (colorUpper == "OLIVE") return KnownColor.Olive;
						break;
					case 'W':
						if (colorUpper == "WHEAT") return KnownColor.Wheat;
						if (colorUpper == "WHITE") return KnownColor.White;
						break;
					default:
						return KnownColor.UnknownColor;
						break;
				}
				break;
			case 6:
				switch(colorUpper[0]) {
					case 'B':
						if (colorUpper == "BISQUE") return KnownColor.Bisque;
						break;
					case 'I':
						if (colorUpper == "INDIGO") return KnownColor.Indigo;
						break;
					case 'M':
						if (colorUpper == "MAROON") return KnownColor.Maroon;
						break;
					case 'O':
						if (colorUpper == "ORANGE") return KnownColor.Orange;
						if (colorUpper == "ORCHID") return KnownColor.Orchid;
						break;
					case 'P':
						if (colorUpper == "PURPLE") return KnownColor.Purple;
						break;
					case 'S':
						if (colorUpper == "SALMON") return KnownColor.Salmon;
						if (colorUpper == "SIENNA") return KnownColor.Sienna;
						if (colorUpper == "SILVER") return KnownColor.Silver;
						break;
					case 'T':
						if (colorUpper == "TOMATO") return KnownColor.Tomato;
						break;
					case 'V':
						if (colorUpper == "VIOLET") return KnownColor.Violet;
						break;
					case 'Y':
						if (colorUpper == "YELLOW") return KnownColor.Yellow;
						break;
					default:
						return KnownColor.UnknownColor;
						break;
				}
				break;
			case 7:
				switch(colorUpper[0]) {
					case 'C':
						if (colorUpper == "CRIMSON") return KnownColor.Crimson;
						break;
					case 'D':
						if (colorUpper == "DARKRED") return KnownColor.DarkRed;
						if (colorUpper == "DIMGRAY") return KnownColor.DimGray;
						break;
					case 'F':
						if (colorUpper == "FUCHSIA") return KnownColor.Fuchsia;
						break;
					case 'H':
						if (colorUpper == "HOTPINK") return KnownColor.HotPink;
						break;
					case 'M':
						if (colorUpper == "MAGENTA") return KnownColor.Magenta;
						break;
					case 'O':
						if (colorUpper == "OLDLACE") return KnownColor.OldLace;
						break;
					case 'S':
						if (colorUpper == "SKYBLUE") return KnownColor.SkyBlue;
						break;
					case 'T':
						if (colorUpper == "THISTLE") return KnownColor.Thistle;
						break;
					default:
						return KnownColor.UnknownColor;
						break;
				}
				break;
			case 8:
				switch(colorUpper[0]) {
					case 'C':
						if (colorUpper == "CORNSILK") return KnownColor.Cornsilk;
						break;
					case 'D':
						if (colorUpper == "DARKBLUE") return KnownColor.DarkBlue;
						if (colorUpper == "DARKCYAN") return KnownColor.DarkCyan;
						if (colorUpper == "DARKGRAY") return KnownColor.DarkGray;
						if (colorUpper == "DEEPPINK") return KnownColor.DeepPink;
						break;
					case 'H':
						if (colorUpper == "HONEYDEW") return KnownColor.Honeydew;
						break;
					case 'L':
						if (colorUpper == "LAVENDER") return KnownColor.Lavender;
						break;
					case 'M':
						if (colorUpper == "MOCCASIN") return KnownColor.Moccasin;
						break;
					case 'S':
						if (colorUpper == "SEAGREEN") return KnownColor.SeaGreen;
						if (colorUpper == "SEASHELL") return KnownColor.SeaShell;
						break;
					default:
						return KnownColor.UnknownColor;
						break;
				}
				break;
			case 9:
				switch(colorUpper[0]) {
					case 'A':
						if (colorUpper == "ALICEBLUE") return KnownColor.AliceBlue;
						break;
					case 'B':
						if (colorUpper == "BURLYWOOD") return KnownColor.BurlyWood;
						break;
					case 'C':
						if (colorUpper == "CADETBLUE") return KnownColor.CadetBlue;
						if (colorUpper == "CHOCOLATE") return KnownColor.Chocolate;
						break;
					case 'D':
						if (colorUpper == "DARKGREEN") return KnownColor.DarkGreen;
						if (colorUpper == "DARKKHAKI") return KnownColor.DarkKhaki;
						break;
					case 'F':
						if (colorUpper == "FIREBRICK") return KnownColor.Firebrick;
						break;
					case 'G':
						if (colorUpper == "GAINSBORO") return KnownColor.Gainsboro;
						if (colorUpper == "GOLDENROD") return KnownColor.Goldenrod;
						break;
					case 'I':
						if (colorUpper == "INDIANRED") return KnownColor.IndianRed;
						break;
					case 'L':
						if (colorUpper == "LAWNGREEN") return KnownColor.LawnGreen;
						if (colorUpper == "LIGHTBLUE") return KnownColor.LightBlue;
						if (colorUpper == "LIGHTCYAN") return KnownColor.LightCyan;
						if (colorUpper == "LIGHTGRAY") return KnownColor.LightGray;
						if (colorUpper == "LIGHTPINK") return KnownColor.LightPink;
						if (colorUpper == "LIMEGREEN") return KnownColor.LimeGreen;
						break;
					case 'M':
						if (colorUpper == "MINTCREAM") return KnownColor.MintCream;
						if (colorUpper == "MISTYROSE") return KnownColor.MistyRose;
						break;
					case 'O':
						if (colorUpper == "OLIVEDRAB") return KnownColor.OliveDrab;
						if (colorUpper == "ORANGERED") return KnownColor.OrangeRed;
						break;
					case 'P':
						if (colorUpper == "PALEGREEN") return KnownColor.PaleGreen;
						if (colorUpper == "PEACHPUFF") return KnownColor.PeachPuff;
						break;
					case 'R':
						if (colorUpper == "ROSYBROWN") return KnownColor.RosyBrown;
						if (colorUpper == "ROYALBLUE") return KnownColor.RoyalBlue;
						break;
					case 'S':
						if (colorUpper == "SLATEBLUE") return KnownColor.SlateBlue;
						if (colorUpper == "SLATEGRAY") return KnownColor.SlateGray;
						if (colorUpper == "STEELBLUE") return KnownColor.SteelBlue;
						break;
					case 'T':
						if (colorUpper == "TURQUOISE") return KnownColor.Turquoise;
						break;
					default:
						return KnownColor.UnknownColor;
						break;
				}
				break;
			case 10:
				switch(colorUpper[0]) {
					case 'A':
						if (colorUpper == "AQUAMARINE") return KnownColor.Aquamarine;
						break;
					case 'B':
						if (colorUpper == "BLUEVIOLET") return KnownColor.BlueViolet;
						break;
					case 'C':
						if (colorUpper == "CHARTREUSE") return KnownColor.Chartreuse;
						break;
					case 'D':
						if (colorUpper == "DARKORANGE") return KnownColor.DarkOrange;
						if (colorUpper == "DARKORCHID") return KnownColor.DarkOrchid;
						if (colorUpper == "DARKSALMON") return KnownColor.DarkSalmon;
						if (colorUpper == "DARKVIOLET") return KnownColor.DarkViolet;
						if (colorUpper == "DODGERBLUE") return KnownColor.DodgerBlue;
						break;
					case 'G':
						if (colorUpper == "GHOSTWHITE") return KnownColor.GhostWhite;
						break;
					case 'L':
						if (colorUpper == "LIGHTCORAL") return KnownColor.LightCoral;
						if (colorUpper == "LIGHTGREEN") return KnownColor.LightGreen;
						break;
					case 'M':
						if (colorUpper == "MEDIUMBLUE") return KnownColor.MediumBlue;
						break;
					case 'P':
						if (colorUpper == "PAPAYAWHIP") return KnownColor.PapayaWhip;
						if (colorUpper == "POWDERBLUE") return KnownColor.PowderBlue;
						break;
					case 'S':
						if (colorUpper == "SANDYBROWN") return KnownColor.SandyBrown;
						break;
						case 'W':
						if (colorUpper == "WHITESMOKE") return KnownColor.WhiteSmoke;
						break;
					default:
						return KnownColor.UnknownColor;
						break;
				}
				break;
			case 11:
				switch(colorUpper[0]) {
					case 'D':
						if (colorUpper == "DARKMAGENTA") return KnownColor.DarkMagenta;
						if (colorUpper == "DEEPSKYBLUE") return KnownColor.DeepSkyBlue;
						break;
					case 'F':
						if (colorUpper == "FLORALWHITE") return KnownColor.FloralWhite;
						if (colorUpper == "FORESTGREEN") return KnownColor.ForestGreen;
						break;
					case 'G':
						if (colorUpper == "GREENYELLOW") return KnownColor.GreenYellow;
						break;
					case 'L':
						if (colorUpper == "LIGHTSALMON") return KnownColor.LightSalmon;
						if (colorUpper == "LIGHTYELLOW") return KnownColor.LightYellow;
						break;
					case 'N':
						if (colorUpper == "NAVAJOWHITE") return KnownColor.NavajoWhite;
						break;
					case 'S':
						if (colorUpper == "SADDLEBROWN") return KnownColor.SaddleBrown;
						if (colorUpper == "SPRINGGREEN") return KnownColor.SpringGreen;
						break;
					case 'T':
						if (colorUpper == "TRANSPARENT") return KnownColor.Transparent;
						break;
					case 'Y':
						if (colorUpper == "YELLOWGREEN") return KnownColor.YellowGreen;
						break;
					default:
						return KnownColor.UnknownColor;
						break;
				}
				break;
			case 12:
				switch(colorUpper[0]) {
					case 'A':
						if (colorUpper == "ANTIQUEWHITE") return KnownColor.AntiqueWhite;
						break;
					case 'D':
						if (colorUpper == "DARKSEAGREEN") return KnownColor.DarkSeaGreen;
						break;
					case 'L':
						if (colorUpper == "LIGHTSKYBLUE") return KnownColor.LightSkyBlue;
						if (colorUpper == "LEMONCHIFFON") return KnownColor.LemonChiffon;
						break;
					case 'M':
						if (colorUpper == "MEDIUMORCHID") return KnownColor.MediumOrchid;
						if (colorUpper == "MEDIUMPURPLE") return KnownColor.MediumPurple;
						if (colorUpper == "MIDNIGHTBLUE") return KnownColor.MidnightBlue;
						break;
					default:
						return KnownColor.UnknownColor;
						break;
				}
				break;
			case 13:
				switch(colorUpper[0]) {
					case 'D':
						if (colorUpper == "DARKSLATEBLUE") return KnownColor.DarkSlateBlue;
						if (colorUpper == "DARKSLATEGRAY") return KnownColor.DarkSlateGray;
						if (colorUpper == "DARKGOLDENROD") return KnownColor.DarkGoldenrod;
						if (colorUpper == "DARKTURQUOISE") return KnownColor.DarkTurquoise;
						break;
					case 'L':
						if (colorUpper == "LIGHTSEAGREEN") return KnownColor.LightSeaGreen;
						if (colorUpper == "LAVENDERBLUSH") return KnownColor.LavenderBlush;
						break;
					case 'P':
						if (colorUpper == "PALEGOLDENROD") return KnownColor.PaleGoldenrod;
						if (colorUpper == "PALETURQUOISE") return KnownColor.PaleTurquoise;
						if (colorUpper == "PALEVIOLETRED") return KnownColor.PaleVioletRed;
						break;
					default:
						return KnownColor.UnknownColor;
						break;
				}
				break;
			case 14:
				switch(colorUpper[0]) {
					case 'B':
						if (colorUpper == "BLANCHEDALMOND") return KnownColor.BlanchedAlmond;
						break;
					case 'C':
						if (colorUpper == "CORNFLOWERBLUE") return KnownColor.CornflowerBlue;
						break;
					case 'D':
						if (colorUpper == "DARKOLIVEGREEN") return KnownColor.DarkOliveGreen;
						break;
					case 'L':
						if (colorUpper == "LIGHTSLATEGRAY") return KnownColor.LightSlateGray;
						if (colorUpper == "LIGHTSTEELBLUE") return KnownColor.LightSteelBlue;
						break;
					case 'M':
						if (colorUpper == "MEDIUMSEAGREEN") return KnownColor.MediumSeaGreen;
						break;
					default:
						return KnownColor.UnknownColor;
						break;
				}
				break;
			case 15:
				if (colorUpper == "MEDIUMSLATEBLUE") return KnownColor.MediumSlateBlue;
				if (colorUpper == "MEDIUMTURQUOISE") return KnownColor.MediumTurquoise;
				if (colorUpper == "MEDIUMVIOLETRED") return KnownColor.MediumVioletRed;
				break;
			case 16:
				if (colorUpper == "MEDIUMAQUAMARINE") return KnownColor.MediumAquamarine;
				break;
			case 17:
				if (colorUpper == "MEDIUMSPRINGGREEN") return KnownColor.MediumSpringGreen;
				break;
			case 20:
				if (colorUpper == "LIGHTGOLDENRODYELLOW") return KnownColor.LightGoldenrodYellow;
				break;
			default:
				return KnownColor.UnknownColor;
				break;
		}
		return KnownColor.UnknownColor;
	}
}