module Runtime.Monitor;


public struct Monitor {
	IMonitor impl;
	DEvent[] devt;
	size_t   refs;
	//pthread_mutex_t mon;
}

//TODO