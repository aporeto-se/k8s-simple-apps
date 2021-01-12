#!/bin/bash

main() {
  err "Running"
  run=true
  trap sigterm SIGTERM
  trap sigint SIGINT
  trap sighup SIGHU
  err ""
  event_loop || { err "Fatal!"; return 3; }
  err "Goodbye"
}

event_loop() {
  sleep_for 30
  /usr/sbin/stupid-http &
  $run || return 0
  while $run; do
    sleep_for 2
    $run || return 0
    event
  done
}

event() {
  /usr/bin/stupid-curl backend
}

sigterm() {
  err "Caught SIGTERM"
  run=false
}

sigint() {
  err "Caught SIGINT"
  run=false
}

sighup() {
  err "Caught SIGHUP"
}

sleep_for() {
  local t=$1
  [ "$t" -eq "$t" ] || { err "$t is must be a positive integer"; return 2; }
  [ "$t" -gt 0 ] || { err "$t is an integer but must be positived"; return 2; }
  err "Sleeping for $t second(s)"
  local c=0
  while $run; do
    ((c=c+1))
    [ "$c" -ge "$t" ] && return 0
    sleep 1
  done
}

sleep_forever() {
  err "Sleeping forever (or until killed)"
  while $run; do
    sleep 1
  done
}

err() { echo "$@" 1>&2; }

main "$@"
