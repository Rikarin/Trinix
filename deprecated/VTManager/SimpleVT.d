module VTManager.SimpleVT;

public import System.ConsoleColor;
import VTManager.VirtualTerminal;
import VTManager.VT;
import DeviceManager.Display;


class SimpleVT  : VirtualTerminal {
	private vtChar BC(ushort row, ushort col) { return buffer[(row * cols) + col]; }

protected:
	bool mapped = false;
	bool hideCursor = false;

	ushort rows, cols;
	ushort mapRow, mapCol;
	ushort csrRow, csrCol;

	ConsoleColor color, bgColor;
	vtChar[] buffer;


	struct vtChar {
		ConsoleColor color;
		ConsoleColor bgColor;
		char c;
	}


	override void UpdateCursor() {
		if (!mapped || hideCursor)
			return;

		Display.MoveCursor(cast(ushort)(csrRow + mapRow), cast(ushort)(csrCol + mapCol));
	}

	void Clear() {
		foreach (ref x; buffer) {
			x.c = ' ';
			x.color = ConsoleColor.Black;
			x.bgColor = ConsoleColor.Black;
		}

		Redraw();
	}

	override void Redraw() {
		if (!mapped)
			return;

		foreach (ushort r; 0 .. rows) {
			foreach (ushort c; 0 .. cols)
				Display.PutChar(cast(ushort)(r + mapRow), cast(ushort)(c + mapCol),  //TODO page fault... 2M+
					BC(r, c).c, BC(r, c).color, BC(r, c).bgColor);
		}
	}

	void Scroll() {
		buffer[0 .. (cols * (rows - 1))] = buffer[rows .. (cols * rows)];

		vtChar b = {c: ' ', color: this.color, bgColor: this.bgColor};
		buffer[(cols * (rows - 1)) .. (cols * rows)] = b;

		if (mapped)
			Redraw();
	}


public:
	override bool IsBoxed() { return true; }
	override @property ushort Width() { return cols; }
	override @property ushort Height() { return rows; }
	void SetColor(ConsoleColor color) { this.color = color; }
	void SetBackgroundColor(ConsoleColor color) { bgColor = color; }


	this(ushort rows, ushort cols, ConsoleColor color = ConsoleColor.Gray, ConsoleColor bgColor = ConsoleColor.Black) {
		super();

		csrCol = 0;
		csrRow = 0;
		this.rows = rows;
		this.cols = cols;
		this.color = color;
		this.bgColor = bgColor;

		buffer = new vtChar[rows * cols];
		Clear();
	}

	~this() {
		if (mapped)
			VT.Unmap(this);

		delete buffer;
	}

	void PutChar(ushort row, ushort col, char c) {
		if (row >= rows || col >= cols)
			return;

		BC(row, col).c = c;
		BC(row, col).color = color;
		BC(row, col).bgColor = bgColor;

		if (mapped)
			Display.PutChar(cast(ushort)(row + mapRow), cast(ushort)(col + mapCol), c, color, bgColor);
	}

	void Map(short row = -1, short col = -1) {
		mapRow = (row == -1 ? (Display.TextRows / 2) - (rows / 2) : row);
		mapCol = (col == -1 ? (Display.TextCols / 2) - (cols / 2) : col);

		mapped = true;
		Redraw();
		//VT.Map(this);
	}

	void Unmap() { 
		mapped = false;
		VT.Unmap(this);
	}

	override void Put(char c, bool updateSCR = true) {
		if (c == '\b') {
			if (csrCol > 0)
				csrCol--;
			PutChar(csrRow, csrCol, ' ');
		} else if (c == '\t')
			csrCol = cast(ushort)((csrCol + 8) & ~7UL);
		else if (c == '\r')
			csrCol = 0;
		else if (c == '\n') {
			csrCol = 0;
			csrRow++;
		} else if (c >= ' ') {
			PutChar(csrRow, csrCol, c);
			csrCol++;
		}

		if (csrCol >= cols) {
			csrCol = 0;
			csrRow++;
		}

		while (csrRow >= rows) {
			Scroll();
			csrRow--;
		}

		if (updateSCR && mapped)
			UpdateCursor();
	}
}