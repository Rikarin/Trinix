module System.DateTime;


class DateTime {
	this(ulong ticks) {

	}


	@property ulong Ticks() { 
		return 0;
	}
	
	@property static DateTime Now() {
		return new DateTime(0);
	}
}