module TaskManager.Semaphore;

import Library;
import TaskManager;


public class Semaphore {
	private string _name;
	private int _value;
	private int _maxValue;
	private SpinLock _spinLock;
	private LinkedList!Thread _waiting;
	private LinkedList!Thread _signaling;

	public this(int initialCount, int maxCount, string name) in {
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

	public int WaitOne() {
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

	public int Release(int releaseCount) in {
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