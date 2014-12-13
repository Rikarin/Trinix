/**
 * Copyright (c) 2014 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix 
 * Public Source Licence Version 0.1 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * http://pastebin.com/raw.php?i=ADVe2Pc7 and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module TaskManager.Semaphore;

import Library;
import TaskManager;


class Semaphore {
	private string _name;
	private int _value;
	private int _maxValue;
	private SpinLock _spinLock;
	private LinkedList!Thread _waiting;
	private LinkedList!Thread _signaling;

	this(int initialCount, int maxCount, string name) in {
		assert(initialCount > 0);
		assert(maxCount > 0);
	} body {
		_value     = initialCount;
		_maxValue  = maxCount;
		_name      = name;
		_spinLock  = new SpinLock();
		_waiting   = new LinkedList!Thread();
		_signaling = new LinkedList!Thread();
	}
	
	~this() {
		delete _signaling;
		delete _spinLock;
		delete _waiting;
		delete _name;
	}

	@property package void LockInternal() {
		_spinLock.WaitOne();
	}

	@property package void UnlockInternal() {
		_spinLock.Release();
	}

	@property package LinkedList!Thread Waiting() {
		return _waiting;
	}

	@property package LinkedList!Thread Signaling() {
		return _signaling;
	}

	int WaitOne() {
		int taken;
		_spinLock.WaitOne();

		if (_value > 0) {
			taken = 1;
			_value--;
		} else {
			_waiting.Add(Task.CurrentThread);
			taken = cast(int)Task.CurrentThread.Sleep(ThreadStatus.SemaphoreSleep, cast(void *)this, 1, _spinLock);
			_spinLock.WaitOne();
		}

		while ((!_maxValue || _value < _maxValue) && _signaling.Count) {
			Thread t = _signaling.First.Value;
			ulong given = (t.RetStatus && _value + t.RetStatus < _maxValue) ? t.RetStatus : _maxValue - _value;

			_value -= given;
			t.RetStatus = given;
			t.AddActive();

			_signaling.RemoveFirst();
			_spinLock.Release();
			return taken;
		}

		return -1;
	}

	int Release(int releaseCount) in {
		assert(releaseCount >= 0);
	} body {
		_spinLock.WaitOne();
		int added;

		if (_maxValue && _value == _maxValue) {
			_signaling.Add(Task.CurrentThread);
			added = cast(int)Task.CurrentThread.Sleep(ThreadStatus.SemaphoreSleep, cast(void *)this, releaseCount, _spinLock);
			_spinLock.WaitOne();
		} else {
			added = (_maxValue && _value + releaseCount > _maxValue) ? _maxValue - _value : releaseCount;
			_value += releaseCount;
		}

		while (_value && _waiting.Count) {
			Thread t = _waiting.First.Value;
			int given = (t.RetStatus && _value > t.RetStatus) ? cast(int)t.RetStatus : _value;

			_value -= given;
			t.RetStatus = given;
			t.AddActive();

			_spinLock.Release();
			_waiting.RemoveFirst();
		}

		return added;
	}

	package static void ForceWake(Thread thread) {
		if (thread.Status != ThreadStatus.SemaphoreSleep)
			return;

		Semaphore semaphore = cast(Semaphore)thread.WaitPointer;
		with (semaphore) {
			_spinLock.WaitOne();
			_waiting.Remove(thread);
			_spinLock.Release();

			thread.RetStatus = 0;
			thread.AddActive();
		}
	}
}