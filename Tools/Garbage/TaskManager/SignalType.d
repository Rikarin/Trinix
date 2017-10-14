/**
 * Copyright (c) Rikarin and contributors. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

module TaskManager.SignalType;


enum SignalType {
    Null,
    SIGHUP, /* Hangup */
    SIGINT, /* Interupt */
    SIGQUIT, /* Quit */
    SIGILL, /* Illegal instruction */
    SIGTRAP, /* A breakpoint or trace instruction has been reached */
    SIGABRT, /* Another process has requested that you abort */
    SIGEMT, /* Emulation trap XXX */
    SIGFPE, /* Floating-point arithmetic exception */
    SIGKILL, /* You have been stabbed repeated with a large knife */
    SIGBUS, /* Bus error (device error) */
    SIGSEGV, /* Segmentation fault */
    SIGSYS, /* Bad system call */
    SIGPIPE, /* Attempted to read or write from a broken pipe */
    SIGALRM, /* This is your wakeup call. */
    SIGTERM, /* You have been Schwarzenegger'd */
    SIGUSR1, /* User Defined Signal #1 */
    SIGUSR2, /* User Defined Signal #2 */
    SIGCHLD, /* Child status report */
    SIGPWR, /* We need moar powah! */
    SIGWINCH, /* Your containing terminal has changed size */
    SIGURG, /* An URGENT! event (On a socket) */
    SIGPOLL, /* XXX OBSOLETE; socket i/o possible */
    SIGSTOP, /* Stopped (signal) */
    SIGTSTP, /* ^Z (suspend) */
    SIGCONT, /* Unsuspended (please, continue) */
    SIGTTIN, /* TTY input has stopped */
    SIGTTOUT, /* TTY output has stopped */
    SIGVTALRM, /* Virtual timer has expired */
    SIGPROF, /* Profiling timer expired */
    SIGXCPU, /* CPU time limit exceeded */
    SIGXFSZ /* File size limit exceeded */
}