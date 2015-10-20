/**
 * Copyright (c) 2014-2015 Trinix Foundation. All rights reserved.
 * 
 * This file is part of Trinix Operating System and is released under Trinix
 * Public Source Licence Version 1.0 (the 'Licence'). You may not use this file
 * except in compliance with the License. The rights granted to you under the
 * License may not be used to create, or enable the creation or redistribution
 * of, unlawful or unlicensed copies of an Trinix operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any terms
 * of an Trinix operating system software license agreement.
 * 
 * You may obtain a copy of the License at
 * https://github.com/Bloodmanovski/Trinix and read it before using this file.
 * 
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License.
 * 
 * Contributors:
 *      Matsumoto Satoshi <satoshi@gshost.eu>
 */

module System.Event;

import System;
import System.Collections;


class Event(T) {
    alias void delegate(T value) EventCallHandler;

    private List!T m_list;
    private EventCallHandler m_addHandler;
    private EventCallHandler m_removeHandler;

    @property {
        void Add(EventCallHandler value)    { m_addHandler    = value; }
        void Remove(EventCallHandler value) { m_removeHandler = value; }
    }

    this() {
        m_list = new List!T();
    }

    ~this() {
        delete m_list;
    }

    void opCall(Object sender, EventArgs e) {
        foreach (x; m_list) {
            x(sender, e);
        }
    }

    void opOpAssign(string TOp)(T event) if (TOp == "+") {
        if (m_addHandler !is null)
            m_addHandler(event);
        else
            AddHandler(event);
    }

    void opOpAssign(string TOp)(T event) if (TOp == "-") {
        if (m_removeHandler !is null)
            m_removeHandler(event);
        else
            RemoveHandler(event);
    }


    private void AddHandler(T value) {
        if (!m_list.Contains(value))
            m_list.Add(value);
    }

    private void RemoveHandler(T value) {
        m_list.Remove(value);
    }
}

unittest { //TODO: test it
    class test {
        Event!EventHandler event = new Event!EventHandler();

        this() {
            event += &test_OnEvent;
            event(this, new EventArgs());

            event += (sender, e) {  };
            event(this, new EventArgs());
        }

        void test_OnEvent(Object sender, EventArgs e) {
            //callsed by event.opCall
        }
    }
}