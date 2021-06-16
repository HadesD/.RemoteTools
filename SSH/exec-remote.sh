#!/bin/bash

read -p 'Choose connection type:
[1] SSH
[2] WinSCP' CONN_TYPE

if [[ "$CONN_TYPE" == "2" ]]; then
  wine ../WinSCP/WinSCP.exe
else
  ssh ${APPEND_FLAGS}
fi


