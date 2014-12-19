module Runtime.Monitor;


alias Object.Monitor        IMonitor;
alias void delegate(Object) DEvent;

class Mutex {} //TODO: this call from Kappa.framework

struct Monitor {
	IMonitor impl;
	DEvent[] devt;
	size_t   refs;
    Mutex mon;
}

/*static __gshared pthread_mutex_t _monitor_critsec; TODO

extern (C) void _STI_monitor_staticctor() {
    if (!inited) {
        pthread_mutexattr_init(&_monitors_attr);
        pthread_mutexattr_settype(&_monitors_attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&_monitor_critsec, &_monitors_attr);
        inited = 1;
    }
}

extern (C) void _STD_monitor_staticdtor()
{
    if (inited)
    {
        inited = 0;
        pthread_mutex_destroy(&_monitor_critsec);
        pthread_mutexattr_destroy(&_monitors_attr);
    }
}*/

extern (C) void _d_monitor_create(Object h) {
    assert(h);
    Monitor *cs;

    //pthread_mutex_lock(&_monitor_critsec);
    if (!h.__monitor) {
        cs = cast(Monitor *)null;//calloc(Monitor.sizeof, 1);
        assert(cs);
        //pthread_mutex_init(&cs.mon, &_monitors_attr);
        SetMonitor(h, cs);
        cs.refs = 1;
        cs = null;
    }

    //pthread_mutex_unlock(&_monitor_critsec);
   // if (cs)
     //   free(cs);
}

extern (C) void _d_monitor_destroy(Object h) {
    assert(h && h.__monitor && !GetMonitor(h).impl);

    //pthread_mutex_destroy(&getMonitor(h).mon);
   // free(h.__monitor);
    SetMonitor(h, null);
}

extern (C) void _d_monitor_lock(Object h) {
    assert(h && h.__monitor && !GetMonitor(h).impl);
    //pthread_mutex_lock(&getMonitor(h).mon);
}

extern (C) void _d_monitor_unlock(Object h) {
    assert(h && h.__monitor && !GetMonitor(h).impl);
    //pthread_mutex_unlock(&getMonitor(h).mon);
}