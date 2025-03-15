#! /bin/bash
sigint_handler()
{
  kill $PID
  exit
}

trap sigint_handler SIGINT

while true; do
  $@ &
  PID=$!
  inotifywait -e modify -e move -e create -e delete -e attrib -r /
  kill $PID
done
