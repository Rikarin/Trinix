/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
module ProcessManager.SignalType;


enum Signal {
    Invalid,
    HangUp,
    Interrupt,
    Quit,
    IllegalInstruction,
    Trap,
    Abort,
    EmulationTrap,
    ArithmeticException,
    Kill,
    BusError,
    SegmentationFault,
    BadSysCall,
    BrokenPipe,
    Alarm,
    Terminated,
    User1,
    SUser2,
    ChildStatus,
    PowerFail,
    WindowSizeChange,
    UrgentSocketCondition,
    Poll,
    Stop,
    Suspend,
//    Continue,
//    SIGTTIN, /* TTY input has stopped */
//    SIGTTOUT, /* TTY output has stopped */
//    SIGVTALRM, /* Virtual timer has expired */
//    SIGPROF, /* Profiling timer expired */
//    SIGXCPU, /* CPU time limit exceeded */
//    SIGXFSZ /* File size limit exceeded */
}