module System.Char;

class Char {
	const auto UE_UTF8 = 1;
	private uint value;

	private union ch_t {
		char c[4];
		uint i;
	}

	private __gshared Char []CP437;
/*	{
		"Ç", "ü", "é", "â", "ä", "à", "å", "ç", "ê", "ë", "è", "ï", "î", "ì", "Ä", "Å",
		"É", "æ", "Æ", "ô", "ö", "ò", "û", "ù", "ÿ", "Ö", "Ü", "¢", "£", "¥", "₧", "ƒ",
		"á", "í", "ó", "ú", "ñ", "Ñ", "ª", "º", "¿", "⌐", "¬", "½", "¼", "¡", "«", "»",
		"░", "▒", "▓", "│", "┤", "╡", "╢", "╖", "╕", "╣", "║", "╗", "╝", "╜", "╛", "┐",
		"└", "┴", "┬", "├", "─", "┼", "╞", "╟", "╚", "╔", "╩", "╦", "╠", "═", "╬", "¤",
		"╨", "╤", "╥", "╙", "╘", "╒", "╓", "╫", "╪", "┘", "┌", "█", "▄", "▌", "▐", "▀",
		"α", "ß", "Γ", "π", "Σ", "σ", "µ", "τ", "Φ", "Θ", "Ω", "δ", "∞", "φ", "ε", "∩",
		"≡", "±", "≥", "≤", "⌠", "⌡", "÷", "≈", "°", "∙", "·", "√", "ⁿ", "²", "■", "⍽"
	};*/

	void opAssign(char c) {
		AffectASCII(c);
	}

	private void AffectASCII(char c) {
		int a = c;
		if (a > 0)
			value = a;
		else
			value = 0;//CP437[a + 128];
	}

	private uint AffectUTF8(const char []c) {
		if (!(c[0] & 0x80)) {
			value = c[0];
			return 1;
		}

		if ((c[0] & 0xE0) == 0xC0) {
			value = ((c[0] & 0x1F) << 6) | (c[1] & 0x3F);
			if (value < 128) 
			value = 0;
			return 2;
		}

		if ((c[0] & 0xF0) == 0xE0) {
			value = ((c[0] & 0x0F) << 12) | ((c[1] & 0x3F) << 6) | (c[2] & 0x3F);

			if (value < 2048)
				value = 0;

			if (value >= 0xD800 && value <= 0xDFFF)
				value = 0;

			if (value >= 0xFFFE && value <= 0xFFFF) 
				value = 0;

			return 3;
		}

		if ((c[0] & 0xF8) == 0xF0) {
			value = ((c[0] & 0x0E) << 18) | ((c[1] & 0x3F) << 12) | ((c[2] & 0x3F) << 6) | (c[3] & 0x3F);

			if (value < 65536)
				value = 0;
			return 4;
		}

		value = 0;
		return 1;
	}

	this() {
		value = 0;
	}

	this(char c) {
		AffectASCII(c);
	}

	this(const char []c, ubyte encoding) {
		if (encoding == UE_UTF8)
			AffectUTF8(c);
	}
}
