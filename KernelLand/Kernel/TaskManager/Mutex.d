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

module TaskManager.Mutex;

import Library;
import TaskManager;


class Mutex {
	private SpinLock _spinLock;
	private LinkedList!Thread _waiting;
	private Thread _owner;

	this() {
		_spinLock = new SpinLock();
		_waiting = new LinkedList!Thread();
	}

	~this() {
		delete _spinLock;
		delete _waiting;
	}

	bool WaitOne() {
		_spinLock.WaitOne();

		if (_owner) {
			_waiting.Add(Task.CurrentThread);
			Task.CurrentThread.Sleep(ThreadStatus.MutexSleep, cast(void *)this, 0, _spinLock);
		} else {
			_owner = Task.CurrentThread;
			_spinLock.Release();
		}

		return true;
	}

	void Release() {
		_spinLock.WaitOne();

		if (_waiting.Count) {
			_owner = _waiting.First.Value;
			_waiting.RemoveFirst();

			if (_owner.Status != ThreadStatus.Active)
				_owner.AddActive();
		} else
			_owner = null;

		_spinLock.Release();
	}

	bool IsLocked() {
		return _owner !is null;
	}
}