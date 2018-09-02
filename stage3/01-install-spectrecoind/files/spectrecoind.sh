#!/bin/sh
# /etc/init.d/spectrecoind.sh
### BEGIN INIT INFO
# Provides:          spectrecoind
# Required-Start:    $all
# Required-Stop:     $local_fs $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start Spectrecoin daemon at boot time
# Description:       Enable Spectrecoind service provided by daemon.
### END INIT INFO

# Author: HLXEasy <hlxeasy@gmail.com>

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="Spectrecoin Daemon"
NAME=spectrecoind
DAEMON=/usr/bin/${NAME}
PIDFILE=/var/run/${NAME}.pid
SCRIPTNAME=/etc/init.d/${NAME}
CHUID=pi:pi
DAEMON_ARGS="-daemon"

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/${NAME} ] && . /etc/default/${NAME}

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

# ============================================================================
# Function that starts the daemon/service
# Return
#   0 if daemon has been started
#   1 if daemon was already running
#   2 if daemon could not be started
do_start() {
    start-stop-daemon --start --quiet --pidfile ${PIDFILE} --exec ${DAEMON} --test > /dev/null || return 1
    start-stop-daemon --start --quiet --chuid ${CHUID} --pidfile ${PIDFILE} --exec ${DAEMON} -- ${DAEMON_ARGS} || return 2
}

# ============================================================================
# Function that stops the daemon/service
# Return
#   0 if daemon has been stopped
#   1 if daemon was already stopped
#   2 if daemon could not be stopped
#   other if a failure occurred
do_stop() {
    start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile ${PIDFILE} --name ${NAME}
    RETVAL="$?"
    [ "$RETVAL" = 2 ] && return 2
    # Wait for children to finish too if this is a daemon that forks
    # and if the daemon is only ever run from this initscript.
    # If the above conditions are not satisfied then add some other code
    # that waits for the process to drop all resources that could be
    # needed by services started subsequently.  A last resort is to
    # sleep for some time.
    start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec ${DAEMON}
    [ "$?" = 2 ] && return 2
    # Many daemons don't delete their pidfiles when they exit.
    rm -f ${PIDFILE}
    return "$RETVAL"
}

# ============================================================================
# Function that sends a SIGHUP to the daemon/service
# If the daemon can reload its configuration without restarting (for example,
# when it is sent a SIGHUP), then implement that here.
do_reload() {
    start-stop-daemon --stop --signal 1 --quiet --pidfile ${PIDFILE} --name ${NAME}
    return 0
}

# ============================================================================
case "$1" in
    start)
        [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
        do_start
        case "$?" in
            0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
            2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
    stop)
        [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
        do_stop
        case "$?" in
            0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
            2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
    restart)
        log_daemon_msg "Restarting $DESC" "$NAME"
        do_stop
        case "$?" in
            0|1)
            do_start
            case "$?" in
                0) log_end_msg 0 ;;
                1) log_end_msg 1 ;; # Old process is still running
                *) log_end_msg 1 ;; # Failed to start
                esac
                ;;
            *)
                # Failed to stop
                log_end_msg 1
                ;;
        esac
        ;;
    *)
        echo "Usage: $SCRIPTNAME {start|stop|restart}" >&2
        exit 3
        ;;
esac

: