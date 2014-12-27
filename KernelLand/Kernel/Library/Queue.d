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
 * http://bit.ly/1wIYh3A and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY 
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module Library.Queue;

import Library;
import TaskManager;


class Queue(T) {
    private LinkedList!Thread m_waitingThreads;
	private T[] m_array;
	private long m_count;

	@property long Count() { return m_count; }

	int opApply(int delegate(ref T) dg) {
		int result;

		foreach (i; 0 .. m_count) {
			result = dg(m_array[i]);
			if (result)
				break;
		}

		return result;
	}

	this() {
        m_waitingThreads = new LinkedList!Thread();
		m_array = new T[4];
	}

	~this() {
        foreach (x; m_waitingThreads)
            x.Value.Wake();

        delete m_waitingThreads;
		delete m_array;
	}

	void Enqueue(T item) {
		if (Count == m_array.length)
			Resize();

		m_array[m_count++] = item;

        foreach (x; m_waitingThreads)
            x.Value.Wake();

        m_waitingThreads.Clear();
	}

	T Dequeue() {
		while (!m_count)
            Task.CurrentThread.Sleep();

		T ret = m_array[0];
		m_array[0 .. $ - 1] = m_array[1 .. $];
		m_count--;
		return ret;
	}

	private void Resize() {
		T[] newArray = new T[m_array.length * 2];
		newArray[0 .. m_array.length] = m_array[0 .. $];

		delete m_array;
		m_array = newArray;
	}
}