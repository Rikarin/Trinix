module Core.DateTime;


public abstract final class DateTime {
	private __gshared int[] DaysToMonth365 = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];
	private __gshared int[] DaysToMonth366 = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366];

	@property public static ulong Now() {
		return CurrentDate() + CurrentTime();
	}

	private static ulong CurrentDate() {
		ubyte day;
		ubyte month;
		ubyte year;

		asm {
		//FIXME: "LOOP:";
			// Get RTC register A
			"mov AL, 10";
			"out 0x70, AL";
			"in AL, 0x71";
			"test AL, 0x80";
			// Loop until it is not busy updating
			//"jne LOOP";
			
			// Get Day of Month (1 to 31)
			"mov AL, 0x07";
			"out 0x70, AL";
			"in AL, 0x71";
			"mov %0, AL" : "=r"(day);
			
			// Get Month (1 to 12)
			"mov AL, 0x08";
			"out 0x70, AL";
			"in AL, 0x71";
			"mov %0, AL" : "=r"(month);
			
			// Get Year (00 to 99)
			"mov AL, 0x09";
			"out 0x70, AL";
			"in AL, 0x71";
			"mov %0, AL" : "=r"(year);
		}
		
		// Convert from BCD to decimal
		day = (((day & 0xF0) >> 4) * 10) + (day & 0xF);
		month = (((month & 0xF0) >> 4) * 10) + (month & 0xF);
		int rYear = (((year & 0xF0) >> 4) * 10) + (year & 0xF) + 2000;

		int[] daysToMonth = IsLeapYear(rYear) ? DaysToMonth366 : DaysToMonth365;
		int previousYear = rYear - 1;
		int daysInPreviousYears = ((previousYear * 365 + previousYear / 4) - previousYear / 100) + previousYear / 400;
		int totalDays = ((daysInPreviousYears + daysToMonth[month - 1]) + day) - 1;

		return (totalDays - 719162) * 24 * 60 * 60; //719162 cuz we need date from 1.1.1970 in seconds
	}

	private static ulong CurrentTime() {
		ubyte second;
		ubyte minute;
		ubyte hour;

		asm {
		// FIXME: "_LOOP2:";
			// Get RTC register A
			"mov AL, 10";
			"out 0x70, AL";
			"in AL, 0x71";
			"test AL, 0x80";
			// Loop until it is not busy updating
			//"jne LOOP2";
			
			// Get Seconds
			"mov AL, 0x00";
			"out 0x70, AL";
			"in AL, 0x71";
			"mov %0, AL" : "=r"(second);
			
			// Get Minutes
			"mov AL, 0x02";
			"out 0x70, AL";
			"in AL, 0x71";
			"mov %0, AL" : "=r"(minute);
			
			// Get Hours
			"mov AL, 0x04";
			"out 0x70, AL";
			"in AL, 0x71";
			"mov %0, AL" : "=r"(hour);
		}
		
		if ((hour & 128) == 128) {
			// RTC is reporting 12 hour mode with PM
			hour &= 0b0111_1111;
			hour += 12;
		}
		
		// Convert from BCD to decimal
		hour = (((hour & 0xF0) >> 4) * 10) + (hour & 0xF);
		minute = (((minute & 0xF0) >> 4) * 10) + (minute & 0xF);
		second = (((second & 0xF0) >> 4) * 10) + (second & 0xF);

		return second + minute * 60 + hour * 3600;
	}

	private static bool IsLeapYear(int year) {
		if (year % 4)
			return false;

		if (!(year % 100))
			return !(year % 400);

		return true;
	}
}