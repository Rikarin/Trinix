module Devices.Random;

import Architectures.Timing;


class Random {
static:
	private __gshared long num;

	@property long Number() {
		return (Rand1(~0UL) - Rand2(~0UL) + Rand3(~0UL)) * Timing.CurrentTime().InSeconds();
	}

private:
	long Rand1(long lim) {
		long ret = (num * 125) % 2796203;
		return ((ret % lim) + 1);
	}

	long Rand2(long lim) {
        long ret = (num * 32719 + 3) % 32749;
        return ((num % lim) + 1);
	}
 
	long Rand3(long lim) {
        long a = 3;
        a = (((a * 214013L + 2531011L) >> 16) & 32767);
        return ((a % lim) + 1);
	}
}