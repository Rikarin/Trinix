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

module Library.LinkedList;


class LinkedList(T) {
	private LinkedListNode!T m_head;
	private long m_count;
	private long m_version;

	@property long Count()             { return m_count; }
	@property LinkedListNode!T First() { return m_head; }
	@property LinkedListNode!T Last()  { return m_head is null ? null : m_head._prev; }

	this() {
	}

	~this() {
		Clear();
	}

	LinkedListNode!T Add(T value) {
		return AddLast(value);
	}

	LinkedListNode!T AddAfter(LinkedListNode!T node, T value) {
		ValidateNode(node);
		LinkedListNode!T result = new LinkedListNode!T(node._list, value);
		InternalInsertNodeBefore(node._next, result);
		return result;
	}

	void AddAfter(LinkedListNode!T node, LinkedListNode!T newNode) {
		ValidateNode(node);
		ValidateNewNode(newNode);
		InternalInsertNodeBefore(node._next, newNode);
		newNode._list = this;
	}

	LinkedListNode!T AddBefore(LinkedListNode!T node, T value) {
		ValidateNode(node);
		LinkedListNode!T result = new LinkedListNode!T(node._list, value);
		InternalInsertNodeBefore(node, result);

		if (node is m_head)
			m_head = result;

		return result;
	}
	
	void AddBefore(LinkedListNode!T node, LinkedListNode!T newNode) {
		ValidateNode(node);
		ValidateNewNode(newNode);
		InternalInsertNodeBefore(node, newNode);
		newNode._list = this;

		if (node is m_head)
			m_head = newNode;
	}

	LinkedListNode!T AddFirst(T value) {
		LinkedListNode!T result = new LinkedListNode!T(this, value);

		if (m_head is null)
			InternalInsertNodeToEmptyList(result);
		else {
			InternalInsertNodeBefore(m_head, result);
			m_head = result;
		}

		return result;
	}

	void AddFirst(LinkedListNode!T node) {
		ValidateNewNode(node);
		
		if (m_head is null)
			InternalInsertNodeToEmptyList(node);
		else {
			InternalInsertNodeBefore(m_head, node);
			m_head = node;
		}

		node._list = this;
	}

	LinkedListNode!T AddLast(T value) {
		LinkedListNode!T result = new LinkedListNode!T(this, value);
		
		if (m_head is null)
			InternalInsertNodeToEmptyList(result);
		else
			InternalInsertNodeBefore(m_head, result);
		
		return result;
	}
	
	void AddLast(LinkedListNode!T node) {
		ValidateNewNode(node);
		
		if (m_head is null)
			InternalInsertNodeToEmptyList(node);
		else
			InternalInsertNodeBefore(m_head, node);
		
		node._list = this;
	}

	void Clear() {
		auto current = m_head;

		while (current !is null) {
			auto tmp = current;
			current = current.Next;
			tmp.Invalidate();
			delete tmp;
		}

		m_head = null;
		m_count = 0;
		m_version++;
	}

	bool Contains(T value) {
		return Find(value) !is null;
	}

	LinkedListNode!T Find(T value) {
		LinkedListNode!T node = m_head;

		if (node) {
			do {
				if (value is node._item)
					return node;
				node = node._next;
			} while (node !is m_head);
		}

		return null;
	}

	LinkedListNode!T FindLast(T value) {
		if (m_head is null)
			return null;

		LinkedListNode!T last = m_head._prev;
		LinkedListNode!T node = last;
		
		if (node) {
			do {
				if (value is node._item)
					return node;
				node = node._prev;
			} while (node !is last);
		}
		
		return null;
	}

	bool Remove(T value) {
		LinkedListNode!T node = Find(value);

		if (node) {
			InternalRemoveNode(node);
			return true;
		}

		return false;
	}

	void Remove(LinkedListNode!T node) {
		ValidateNode(node);
		InternalRemoveNode(node);
	}

	void RemoveFirst() in {
		if (m_head is null)
			assert(0);
	} body {
		InternalRemoveNode(m_head);
	}

	void RemoveLast() in {
		if (m_head is null)
			assert(0);
	} body {
		InternalRemoveNode(m_head._prev);
	}

	int opApply(int delegate(ref LinkedListNode!T) dg) {
		int result;

		for (auto x = m_head; x !is null; x = x.Next) {
			result = dg(x);
			if (result)
				break;
		}

		return result;
	}

	int opApplyReverse(int delegate(ref LinkedListNode!T) dg) {
		int result;
		
		for (auto x = m_head; x !is null; x = x.Prev) {
			result = dg(x);
			if (result)
				break;
		}
		
		return result;
	}

	private void InternalInsertNodeBefore(LinkedListNode!T node, LinkedListNode!T newNode) {
		newNode._next    = node;
		newNode._prev    = node._prev;
		node._prev._next = newNode;
		node._prev       = newNode;            
		m_version++;
		m_count++;
	}

	private void InternalInsertNodeToEmptyList(LinkedListNode!T newNode) in {
		assert(m_head is null && !m_count, "LinkedList must be empty when this method is called!");
	} body {
		newNode._next = newNode;
		newNode._prev = newNode;
		m_head = newNode;
		m_version++;
		m_count++; 
	}

	private void InternalRemoveNode(LinkedListNode!T node) in {
		assert(node._list is this, "Deleting the node from another list!");   
		assert(m_head !is null, "This method shouldn't be called on empty list!");
	} body {
		if (node._next == node) {
			m_head = null;
		} else {
			node._next._prev = node._prev;
			node._prev._next = node._next;
			
			if (m_head is node)
				m_head = node._next;
		}

		node.Invalidate();
		delete node;
		m_count--;
		m_version++;
	}

	private void ValidateNewNode(LinkedListNode!T node) {
		if (node is null || node._list !is null)
			assert(false);
	}

	private void ValidateNode(LinkedListNode!T node) {
		if (node is null || node._list !is this)
			assert(false);
	}
}


final class LinkedListNode(T) {
	private LinkedList!T _list;
	private LinkedListNode!T _next;
	private LinkedListNode!T _prev;
	private T _item;

	this(T value) {
		_item = value;
	}

	private this(LinkedList!T list, T value) {
		_list = list;
		_item = value;
	}

	@property LinkedList!T List() {
		return _list;
	}

	@property LinkedListNode!T Next() {
		return _next is null || _next is _list.m_head ? null : _next;
	}

	@property LinkedListNode!T Prev() {
		return _prev is null || _prev is _list.m_head ? null : _prev;
	}

	@property ref T Value() { 
		return _item;
	}

	private void Invalidate() {
		_list = null;
		_next = null;
		_prev = null;
	}
}