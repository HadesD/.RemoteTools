#!/bin/bash

read -p '[+] Choose Action (Exit=CTRL+D):
- [*] SSH Remote
- [1] WinSCP Stand-Alone
- [2] Update (with git pull)
- [3] git push
- [4] Install
- [5] Init
Default[0]: ' ACTION_OPT

case $ACTION_OPT in
  *)
    cd SSH
    ls -la
    read -p 'Enter FileName: ' SSH_TARGET_FILE_NAME

    ;;
esac

