#!/bin/bash

read -p '[+] Choose Action (Exit=CTRL+C):
- [*] SSH Remote
- [1] WinSCP Stand-Alone
- [2] Navicat Stand-Alone
- [3] Update (with git pull)
- [4] git push
- [5] Install
Default[*]: ' ACTION_OPT

case $ACTION_OPT in
  1)
    echo '!!! Please keep this window open. Only close the WinSCP window !!!'
    cp WinSCP/WinSCP.ini .RemoteTools/WinSCP.ini
    .RemoteTools/WinSCP/WinSCP.exe
    cp .RemoteTools/WinSCP.ini WinSCP/WinSCP.ini
    ;;

  2)
    start .RemoteTools/navicat.exe
    ;;

  3)
    git pull
    git submodule update --init --recursive
    git submodule foreach git checkout master
    git submodule foreach git pull
    ;;

  4)
    git add .
    git commit -m "Update"
    git push
    ;;

  5)
    git submodule update --init --recursive
    git submodule foreach git pull
    git submodule foreach git checkout master
    git submodule foreach git pull

    curl -L https://github.com/HadesD/.RemoteTools/releases/download/latest/RemoteTools.tar.gz --output RemoteTools.tar.gz
    tar -zxvf RemoteTools.tar.gz -C ./.RemoteTools/
    rm -f RemoteTools.tar.gz
    ;;

  *)
    cd SSH
    ls -Al *.sh
    read -p '[+] Enter FileName: ' SSH_TARGET_FILE_NAME
    bash $SSH_TARGET_FILE_NAME
    ;;
esac
