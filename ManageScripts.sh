#!/bin/bash

cecho(){
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    BLUE="\033[1;34m"
    # ... ADD MORE COLORS
    NC="\033[0m" # No Color
    # ZSH
    # printf "${(P)1}${2} ${NC}\n"
    # Bash
    printf "${!1}${2} ${NC}\n"
}

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

  clear

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
      cat > SSH/${SSH_SERVER_NAME}.sh <<_EOF
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
      if [[ -f config ]]; then
	    cecho 'YELLOW' '[!] Please select a Hostname from list bellow:'

        grep -ni 'Host [[:alnum:]]' config

        while read -p '[+] Enter Host: ' REMOTE_SERVER_NAME; do
          if [ "$REMOTE_SERVER_NAME" != "" ]; then
            break;
          fi
        done

        SSH_TARGET_LINE=$(grep -n '^Host '${REMOTE_SERVER_NAME}'$' config | awk '{print $1}' FS=':')
        ((SSH_TARGET_STARTL = $SSH_TARGET_LINE + 1))
        ((SSH_TARGET_ENDL = $SSH_TARGET_STARTL + 4))

        REMOTE_SERVER_PORT=$(sed -n $SSH_TARGET_STARTL','$SSH_TARGET_ENDL'p' config | grep 'Port [[:digit:]]' | xargs echo -n | awk '{print $2}' FS=' ')
        REMOTE_SERVER_LOCAL_PORT=$REMOTE_SERVER_PORT
        SSH_KEY_FILE=$(sed -n $SSH_TARGET_STARTL','$SSH_TARGET_ENDL'p' config | grep 'IdentityFile' | xargs echo -n | awk '{print $2}' FS=' ')
        REMOTE_SERVER_USERNAME=$(sed -n $SSH_TARGET_STARTL','$SSH_TARGET_ENDL'p' config | grep 'User' | xargs echo -n | awk '{print $2}' FS=' ')
        REMOTE_SERVER_HOST=localhost

        SSH_APPEND_FLAGS='-F config'

        cecho 'BLUE' "[i] Target Port: $REMOTE_SERVER_PORT"

        if [ "$REMOTE_SERVER_PORT" != "22" ]; then
          SSH_TARGET_PORT_PREFIX=$((${REMOTE_SERVER_PORT::-2}))
          
          if [[ ${SSH_TARGET_PORT_PREFIX} -ge 600 ]]; then
            (( SSH_TARGET_PORT_PREFIX = SSH_TARGET_PORT_PREFIX / 2 ))
          fi
          SSH_APPEND_FLAGS="${SSH_APPEND_FLAGS} -L ${SSH_TARGET_PORT_PREFIX}06:localhost:3306"
          SSH_APPEND_FLAGS="${SSH_APPEND_FLAGS} -L ${SSH_TARGET_PORT_PREFIX}22:localhost:22"
          REMOTE_SERVER_LOCAL_PORT="${SSH_TARGET_PORT_PREFIX}22"
        else
          REMOTE_SERVER_LOCAL_PORT="35022" # Just random >= 30k
          SSH_APPEND_FLAGS="${SSH_APPEND_FLAGS} -L ${REMOTE_SERVER_LOCAL_PORT}:localhost:22"
        fi

        cecho 'BLUE' "[i] SSH_APPEND_FLAGS: $SSH_APPEND_FLAGS"

        #ssh -F config $SSH_APPEND_FLAGS $REMOTE_SERVER_NAME
        source ../.RemoteTools/SSH/exec-remote.sh
      else
    	  ls -Al *.sh
    	  read -p '[+] Enter FileName: ' SSH_TARGET_FILE_NAME
    	  if [[ -f "${SSH_TARGET_FILE_NAME}" ]]; then
    		bash $SSH_TARGET_FILE_NAME
    	  fi
      fi
      cd ..
      ;;
  esac

  main
}

main
