#!/bin/bash

read -p '[+] Choose Action (Exit=CTRL+C):
- [*] SSH Remote
- [1] WinSCP Stand-Alone
- [2] Navicat Stand-Alone
- [3] Update (with git pull)
- [4] git push
- [5] Install
- [6] Create new SSH
Default[*]: ' ACTION_OPT

case $ACTION_OPT in
  1)
    echo '!!! Please keep this window open. Only close the WinSCP window !!!'
    cp WinSCP/WinSCP.ini .RemoteTools/WinSCP/WinSCP.ini
    .RemoteTools/WinSCP/WinSCP.exe
    cp .RemoteTools/WinSCP.ini WinSCP/WinSCP.ini
    ;;

  2)
    cd SSH
    start ../.RemoteTools/Navicat/navicat.exe
    ;;

  3)
	git submodule foreach git checkout .
	git submodule foreach git checkout master
	git submodule foreach git pull
	git pull
    ;;

  4)
    git add .
    git commit -m "Update"
    git push
    ;;

  5)
    git submodule update --init --recursive
    git submodule foreach git checkout .
    git submodule foreach git pull
    git submodule foreach git checkout master
    git submodule foreach git pull

    curl -L https://github.com/HadesD/.RemoteTools/releases/download/latest/RemoteTools.tar.gz --output RemoteTools.tar.gz
    tar -zxvf RemoteTools.tar.gz -C ./.RemoteTools/
    rm -f RemoteTools.tar.gz
    ;;

  6)
    read -p '[+] Enter SSH_SERVER_NAME: ' SSH_SERVER_NAME
    read -p '[+] Enter REMOTE_SERVER_HOST: ' REMOTE_SERVER_HOST
    read -p '[+] Enter REMOTE_SERVER_PORT: ' REMOTE_SERVER_PORT
    read -p '[+] Enter REMOTE_SERVER_USERNAME: ' REMOTE_SERVER_USERNAME
    read -p '[+] Enter REMOTE_SERVER_PASSWORD: ' REMOTE_SERVER_PASSWORD
    vim Keys/${SSH_SERVER_NAME}.pem
    echo "#!/bin/bash

REMOTE_SERVER_HOST=${REMOTE_SERVER_HOST}
REMOTE_SERVER_PORT=${REMOTE_SERVER_PORT}
REMOTE_SERVER_USERNAME=${REMOTE_SERVER_USERNAME}
REMOTE_SERVER_PASSWORD='${REMOTE_SERVER_PASSWORD}'

source ../.RemoteTools/SSH/exec-remote.sh" >> SSH/${SSH_SERVER_NAME}.sh
    ;;

  *)
    cd SSH
    ls -Al *.sh
    read -p '[+] Enter FileName: ' SSH_TARGET_FILE_NAME
    bash $SSH_TARGET_FILE_NAME
    ;;
esac
