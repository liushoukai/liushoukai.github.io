---
layout: post
title: linux-daemon
categories: linux-shell
tags: linux-shell
---

## Init Daemon

init是Initialization的缩写， init是一个守护进程，在计算机启动后立即启动并继续运行直到计算机关闭；
init是计算机引导时启动的第一个进程，使其直接或间接地成为所有其他正在运行的进程的父进程，因此通常会为其分配PID=1；
如果init守护进程无法启动，则不会启动其它进程，系统将进入一个称为“Kernel Panic”的状态。 init通常被称为System V init，是因为System V是第一个商用UNIX操作系统的名称，目前大多数Linux发行版的init的设计和使用都与System V操作系统相同；

## Systemd Daemon

systemd是一个用UNIX惯例命名的系统管理守护进程，在守护进程结束时添加'd'。所以，他们可以很容易识别。
最初它是在GNU通用公共许可证下发布的，但现在这些发布版本是在GNU Lesser General Public License下制作的。
与init类似，Systemd是所有其他进程的直接或间接父进程，并且是第一个在启动时启动的进程，因此通常会分配一个PID=1

## Init Script

```shell
The start_daemon, killproc and pidofproc functions shall use the following algorithm for determining the status and the process identifiers of the specified program.
1. If the -p pidfile option is specified, and the named pidfile exists, a single line at the start of the pidfile shall be read. If this line contains one or more numeric values, separated by spaces, these values shall be used.
2. Otherwise, /var/run/basename.pid shall be read in a similar fashion. If this contains one or more numeric values on the first line, these values shall be used.
3. Optionally, if neither of the above methods has determined the process identifiers required, implementations may use unspecified additional methods to locate the process identifiers required.
The method used to determine the status is implementation defined, but should allow for non-binary programs.
Note: Commonly used methods check either for the existence of the /proc/pid directory or use /proc/pid/exe and /proc/pid/cmdline. Relying only on /proc/pid/exe is discouraged since this specification does not specify the existence of, or semantics for, /proc. Additionally, using /proc/pid/exe may result in a not-running status for daemons that are written in a script language.
Conforming implementations may use other mechanisms besides those based on pidfiles, unless the -p pidfile option has been used. Conforming applications should not rely on such mechanisms and should always use a pidfile. When a program is stopped, it should delete its pidfile. Multiple process identifiers shall be separated by a single space in the pidfile and in the output of pidofproc.
start_daemon [-f] [-n nicelevel] [-p pidfile] pathname [args...]
runs the specified program as a daemon. The start_daemon function shall check if the program is already running using the algorithm given above. If so, it shall not start another copy of the daemon unless the -f option is given. The -n option specifies a nice level. See nice. start_daemon shall return the LSB defined exit status codes. It shall return 0 if the program has been successfully started or is running and not 0 otherwise.
killproc [-p pidfile] pathname [signal]
The killproc function shall stop the specified program. The program is found using the algorithm given above. If a signal is specified, using the -signal_name or -signal_number syntaxes as specified by the kill command, the program is sent that signal. Otherwise, a SIGTERM followed by a SIGKILL after an unspecified number of seconds shall be sent. If a program has been terminated, the pidfile should be removed if the terminated process has not already done so. The killproc function shall return the LSB defined exit status codes. If called without a signal, it shall return 0 if the program has been stopped or is not running and not 0 otherwise. If a signal is given, it shall return 0 only if the program is running.
pidofproc [-p pidfile] pathname
The pidofproc function shall return one or more process identifiers for a particular daemon using the algorithm given above. Only process identifiers of running processes should be returned. Multiple process identifiers shall be separated by a single space.
Note: A process may exit between pidofproc discovering its identity and the caller of pidofproc being able to act on that identity. As a result, no test assertion can be made that the process identifiers returned by pidofproc shall be running processes.
The pidofproc function shall return the LSB defined exit status codes for "status". It shall return 0 if the program is running and not 0 otherwise.

log_success_msg message
The log_success_msg function shall cause the system to print a success message.
Note: The message should be relatively short; no more than 60 characters is highly desirable.

log_failure_msg message
The log_failure_msg function shall cause the system to print a failure message.
Note: The message should be relatively short; no more than 60 characters is highly desirable.

log_warning_msg message
The log_warning_msg function shall cause the system to print a warning message.
Note: The message should be relatively short; no more than 60 characters is highly desirable.
```
