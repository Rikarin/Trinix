module System.DateTime;


class DateTime {
	this(ulong ticks) {

	}


	@property static DateTime Now() {
		return new DateTime(0);
	}
}