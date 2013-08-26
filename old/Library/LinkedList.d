/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module Library.LinkedList;


final class LinkedList(T) {
    private LinkedListNode!T m_head;
    private long m_count;
    private long m_version;

    @property long Count()             { return m_count; }
    @property LinkedListNode!T First() { return m_head;  }
    @property LinkedListNode!T Last()  { return m_head is null ? null : m_head.m_prev; }

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
        LinkedListNode!T result = new LinkedListNode!T(node.m_list, value);
        InternalInsertNodeBefore(node.m_next, result);
        return result;
    }

    void AddAfter(LinkedListNode!T node, LinkedListNode!T newNode) {
        ValidateNode(node);
        ValidateNewNode(newNode);
        InternalInsertNodeBefore(node.m_next, newNode);
        newNode.m_list = this;
    }

    LinkedListNode!T AddBefore(LinkedListNode!T node, T value) {
        ValidateNode(node);
        LinkedListNode!T result = new LinkedListNode!T(node.m_list, value);
        InternalInsertNodeBefore(node, result);

        if (node is m_head)
            m_head = result;

        return result;
    }
    
    void AddBefore(LinkedListNode!T node, LinkedListNode!T newNode) {
        ValidateNode(node);
        ValidateNewNode(newNode);
        InternalInsertNodeBefore(node, newNode);
        newNode.m_list = this;

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

        node.m_list = this;
    }

    LinkedListNode!T AddLast(T value) {
        auto result = new LinkedListNode!T(this, value);
        
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
        
        node.m_list = this;
    }

    void Clear() {
        auto current = m_head;

        while (current !is null) {
            auto tmp = current;
            current = current.Next;
            tmp.Invalidate();
            delete tmp;
        }

        m_head  = null;
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
                if (value is node.m_item)
                    return node;
                node = node.m_next;
            } while (node !is m_head);
        }

        return null;
    }

    LinkedListNode!T FindLast(T value) {
        if (m_head is null)
            return null;

        LinkedListNode!T last = m_head.m_prev;
        LinkedListNode!T node = last;
        
        if (node) {
            do {
                if (value is node.m_item)
                    return node;
                node = node.m_prev;
            } while (node !is last);
        }
        
        return null;
    }

    bool Remove(T value) {
        LinkedListNode!T node = Find(value);

        if (node) {
            InternalRemoveNode(node);
            delete node;

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
        InternalRemoveNode(m_head.m_prev);
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
        newNode.m_next     = node;
        newNode.m_prev     = node.m_prev;
        node.m_prev.m_next = newNode;
        node.m_prev        = newNode;            
        m_version++;
        m_count++;
    }

    private void InternalInsertNodeToEmptyList(LinkedListNode!T newNode) in {
        assert(m_head is null && !m_count, "LinkedList must be empty when this method is called!");
    } body {
        newNode.m_next = newNode;
        newNode.m_prev = newNode;
        m_head = newNode;
        m_version++;
        m_count++; 
    }

    private void InternalRemoveNode(LinkedListNode!T node) in {
        assert(node.m_list is this, "Deleting the node from another list!");   
        assert(m_head !is null, "This method shouldn't be called on empty list!");
    } body {
        if (node.m_next == node) {
            m_head = null;
        } else {
            node.m_next.m_prev = node.m_prev;
            node.m_prev.m_next = node.m_next;
            
            if (m_head is node)
                m_head = node.m_next;
        }

        node.Invalidate();
        m_count--;
        m_version++;
    }

    private void ValidateNewNode(LinkedListNode!T node) {
        if (node is null || node.m_list !is null)
            assert(false);
    }

    private void ValidateNode(LinkedListNode!T node) {
        if (node is null || node.m_list !is this)
            assert(false);
    }
}


final class LinkedListNode(T) {
    private LinkedList!T m_list;
    private LinkedListNode!T m_next;
    private LinkedListNode!T m_prev;
    private T m_item;

    this(T value) {
        m_item = value;
    }

    private this(LinkedList!T list, T value) {
        m_list = list;
        m_item = value;
    }

    @property LinkedList!T List() {
        return m_list;
    }

    @property LinkedListNode!T Next() {
        return m_next is null || m_next is m_list.m_head ? null : m_next;
    }

    @property LinkedListNode!T Prev() {
        return m_prev is null || m_prev is m_list.m_head ? null : m_prev;
    }

    @property ref T Value() { 
        return m_item;
    }

    private void Invalidate() {
        m_list = null;
        m_next = null;
        m_prev = null;
    }
}