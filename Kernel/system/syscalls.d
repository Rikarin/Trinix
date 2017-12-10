/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module system.syscalls;


enum Syscall : ulong {
	Nop                   = 0x000,
	
	MessageCurrent        = 0x100,
	MessageSend           = 0x101,
	MessageError          = 0x102,
	MessageReceive        = 0x103,
	MessageReply          = 0x104,
	MessageRead           = 0x105,
	MessageWrite          = 0x106,
	MessageInfo           = 0x107,
	MessageSendPulse      = 0x108,
	MessageDeliverEvent   = 0x109,
	MessageKeyData        = 0x110,
	MessageReadIO         = 0x111,
	MessageReceivePulse   = 0x112,
	MessageVerifyEvent    = 0x113,
	
	SignalEmit            = 0x200,
	SignalAttach          = 0x201,
	SignalProcMask        = 0x202,
	SignalSuspend         = 0x203,
	SignalWaitInfo        = 0x204,
	
	ChannelCreate         = 0x300,
	ChannelDestroy        = 0x301,
	
	ConnectAttach         = 0x400,
	ConnectDetach         = 0x401,
	ConnectServerInfo     = 0x402,
	ConnectClientInfo     = 0x403,
	ConnectFlags          = 0x404,
	
	ThreadCreate          = 0x500,
	ThreadDestroy         = 0x501,
	ThreadDestroyAll      = 0x502,
	ThreadDetach          = 0x503,
	ThreadJoin            = 0x504,
	ThreadCancel          = 0x505,
	ThreadControl         = 0x506,
	
	InterruptAttach       = 0x601,
	InterruptDetach       = 0x602,
	InterruptWait         = 0x603,
	InterruptMask         = 0x604,
	InterruptUnmask       = 0x605,
	
	ClockTime             = 0x700,
	ClockAdjust           = 0x701,
	ClockPeriod           = 0x702,
	ClockId               = 0x703,
	
	TimerCreate           = 0x800,
	TimerDestroy          = 0x801,
	TimerSetTime          = 0x802,
	TimerInfo             = 0x803,
	TimerAlarm            = 0x804,
	TimerTimeout          = 0x805,
	
	SyncCreate            = 0x900,
	SyncDestroy           = 0x901,
	SyncMutexLock         = 0x902,
	SyncMutexUnlock       = 0x903,
	SyncMutexRevive       = 0x904,
	SyncCondVarWait       = 0x905,
	SyncCondVarSignal     = 0x906,
	SyncSemaphorePost     = 0x907,
	SyncSemaphoreWait     = 0x908,
	SyncControl           = 0x909,

	SchedulerGet          = 0x1000,
	SchedulerSet          = 0x1001,
	SchedulerYield        = 0x1002,
	SchedulerInfo         = 0x1003,
	SchedulerControl      = 0x1004,	
}
