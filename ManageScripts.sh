#!/bin/bash

main() {
  read -p '[+] Choose Action (Exit=CTRL+C):
- [*] SSH Remote
- [1] WinSCP Stand-Alone
- [2] Navicat Stand-Alone
- [3] Update (with git pull)
- [4] git push
- [5] Install
- [6] Create new SSH
- [7] Forward Local Port
Default[*]: ' ACTION_OPT

  case $ACTION_OPT in
    1)
      echo '!!! Please keep this window open. Only close the WinSCP window !!!'
      cp WinSCP/WinSCP.ini .RemoteTools/WinSCP/WinSCP.ini
      .RemoteTools/WinSCP/WinSCP.exe
      cp .RemoteTools/WinSCP/WinSCP.ini WinSCP/WinSCP.ini
      ;;

    2)
      cd SSH
      start ../.RemoteTools/Navicat/navicat.exe
      cd ..
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
      cat > SSH/${SSH_SERVER_NAME}.sh <<'_EOF'
#!/bin/bash

REMOTE_SERVER_HOST=${REMOTE_SERVER_HOST}
REMOTE_SERVER_PORT=${REMOTE_SERVER_PORT}
REMOTE_SERVER_USERNAME=${REMOTE_SERVER_USERNAME}
REMOTE_SERVER_PASSWORD='${REMOTE_SERVER_PASSWORD}'

source ../.RemoteTools/SSH/exec-remote.sh
_EOF
      ;;

    7)
      echo '[i] You need to update /etc/ssh/sshd_config:AllowTcpForwarding yes + GatewayPorts yes'
      echo 'ssh -XY -o ServerAliveInterval=30 -R <REMOTE_PORT>:127.0.0.1:<LOCAL_RESOURCE_PORT> -R <REMOTE_PORT>:127.0.0.1:<LOCAL_RESOURCE_PORT> <REMOTE_USERNAME>@<REMOTE_HOST_NAME> -i <PERM_FILE>'
      ;;

    *)
      cd SSH
      ls -Al *.sh
      read -p '[+] Enter FileName: ' SSH_TARGET_FILE_NAME
      if [ -f "${SSH_TARGET_FILE_NAME}" ]; then
        bash $SSH_TARGET_FILE_NAME
      else
        echo '(exit)'
      fi
      cd ..
      ;;
  esac

  main
}

main

