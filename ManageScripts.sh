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

MSG_ACT_TYPE='Choose Action (Exit=CTRL+C):
[*] SSH Remote
[1] WinSCP Stand-Alone
[2] Navicat Stand-Alone
[3] Update (with git pull)
[4] git push
[5] Install
[6] Forward Local Port
Default[*]: '

MSG_CONN_TYPE='[+] Choose connection type (Exit=CTRL+C):
- [*] SSH (https://superuser.com/questions/1579346/many-excludedportranges-how-to-delete-hyper-v-is-disabled)
- [1] WinSCP
- [2] Navicat
Default[*]: '

main() {
  read -p "${MSG_ACT_TYPE}" ACTION_OPT

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
      echo '[i] You need to update /etc/ssh/sshd_config:AllowTcpForwarding yes + GatewayPorts yes'
      echo 'ssh -XY -o ServerAliveInterval=30 -R <REMOTE_PORT>:127.0.0.1:<LOCAL_RESOURCE_PORT> -R <REMOTE_PORT>:127.0.0.1:<LOCAL_RESOURCE_PORT> <REMOTE_USERNAME>@<REMOTE_HOST_NAME> -i <PERM_FILE>'
      ;;

    *)
      cd SSH
	  cecho 'YELLOW' '[!] Please select a Hostname from list bellow:'

      grep -ni 'Host [[:alnum:]]' config | awk -F ':' '{print "[" $1 "]\t" $2}'

      while read -p '[+] Enter Host: ' REMOTE_HOST_SELECT; do
        if [ "$REMOTE_HOST_SELECT" != "" ]; then
          break;
        fi
      done

      if [[ $REMOTE_HOST_SELECT =~ ^[0-9]+$ ]]; then
          SSH_TARGET_LINE=$(( $REMOTE_HOST_SELECT ))
          REMOTE_SERVER_NAME=$(sed -n $SSH_TARGET_LINE'p' config | grep 'Host' | xargs echo -n | awk '{print $2}' FS=' ')
      else
          SSH_TARGET_LINE=$(grep -n '^Host '${REMOTE_HOST_SELECT}'$' config | awk '{print $1}' FS=':')
          REMOTE_SERVER_NAME=$REMOTE_HOST_SELECT
      fi
      ((SSH_TARGET_STARTL = $SSH_TARGET_LINE + 1))
      ((SSH_TARGET_ENDL = $SSH_TARGET_STARTL + 4))

      REMOTE_SERVER_PORT=$(sed -n $SSH_TARGET_STARTL','$SSH_TARGET_ENDL'p' config | grep 'Port [[:digit:]]' | xargs echo -n | awk '{print $2}' FS=' ')
      REMOTE_SERVER_LOCAL_PORT=$REMOTE_SERVER_PORT
      SSH_KEY_FILE=$(sed -n $SSH_TARGET_STARTL','$SSH_TARGET_ENDL'p' config | grep 'IdentityFile' | xargs echo -n | awk '{print $2}' FS=' ')
      REMOTE_SERVER_USERNAME=$(sed -n $SSH_TARGET_STARTL','$SSH_TARGET_ENDL'p' config | grep 'User' | xargs echo -n | awk '{print $2}' FS=' ')
      REMOTE_SERVER_HOST=localhost

      SSH_APPEND_FLAGS='-F config'

      cecho 'BLUE' "[i] Target Port: $REMOTE_SERVER_PORT"

      SSH_TARGET_PORT_PREFIX=$((${REMOTE_SERVER_PORT::-2}))
      if [[ ${SSH_TARGET_PORT_PREFIX} -ge 600 ]]; then
        (( SSH_TARGET_PORT_PREFIX = SSH_TARGET_PORT_PREFIX / 2 ))
      elif [[ $(( REMOTE_SERVER_PORT )) -eq 22 ]]; then
        MIN_TOTAL=0
        for i in $(echo $SSH_KEY_FILE | grep -o .); do
          printf -v ordr "%d" "'$i"
          MIN_TOTAL=$(( $MIN_TOTAL + $ordr ))
        done
        (( SSH_TARGET_PORT_PREFIX = (MIN_TOTAL % 350) + 22 ))
      fi
      SSH_APPEND_FLAGS="${SSH_APPEND_FLAGS} -L ${SSH_TARGET_PORT_PREFIX}06:localhost:3306"
      SSH_APPEND_FLAGS="${SSH_APPEND_FLAGS} -L ${SSH_TARGET_PORT_PREFIX}22:localhost:22"
      REMOTE_SERVER_LOCAL_PORT="${SSH_TARGET_PORT_PREFIX}22"

      cecho 'BLUE' "[i] Local Forward Port: ${SSH_TARGET_PORT_PREFIX}22->22"
      cecho 'BLUE' "[i] MySQL Local Forward Port: ${SSH_TARGET_PORT_PREFIX}06->3306"
      cecho 'BLUE' "[i] SSH_APPEND_FLAGS: $SSH_APPEND_FLAGS"

      read -p "${MSG_CONN_TYPE}" CONN_TYPE

      echo "[+] Connecting to [${REMOTE_SERVER_USERNAME} : ${REMOTE_SERVER_PASSWORD} @ ${REMOTE_SERVER_HOST} : ${REMOTE_SERVER_LOCAL_PORT}]..."
      
      case $CONN_TYPE in
        1)
          PPK_KEY_FILE="${SSH_KEY_FILE}.ppk"
          PASSWORD_FLAG="-password=\"$REMOTE_SERVER_PASSWORD\""
          WINE_EXE=start
          WINEPATH_EXE=echo
          WINE_EXE_WINSCP_KEYGEN=''
          #WINE_EXE='' # Debug
          if [ -x "$(command -v wine)" ]; then
            WINE_EXE=wine
            WINEPATH_EXE='winepath --windows'
            WINE_EXE_WINSCP_KEYGEN=$WINE_EXE
          fi
      
          if [ -f "$SSH_KEY_FILE" ]; then
            $WINE_EXE_WINSCP_KEYGEN ../.RemoteTools/WinSCP/WinSCP.com /keygen: "$(${WINEPATH_EXE} ${SSH_KEY_FILE})" -o "$(${WINEPATH_EXE} ${PPK_KEY_FILE})"
          fi
          if [ -f "${PPK_KEY_FILE}" ]; then
            PASSWORD_FLAG="-privatekey="$(${WINEPATH_EXE} ${PPK_KEY_FILE})
          fi
          $WINE_EXE ../.RemoteTools/WinSCP/WinSCP.exe $PASSWORD_FLAG sftp://${REMOTE_SERVER_USERNAME}:${REMOTE_SERVER_PASSWORD}@${REMOTE_SERVER_HOST}:${REMOTE_SERVER_LOCAL_PORT} -sessionname="${REMOTE_SERVER_NAME}"
          ;;
        2)
          start ../.RemoteTools/Navicat/navicat.exe
          ;;
      
        *)
          SSH_APPEND_FLAGS="${SSH_APPEND_FLAGS}"
      
          if [[ -f ${SSH_KEY_FILE} ]]; then
            chmod 0600 ${SSH_KEY_FILE}
          fi
          LANG=C.UTF-8
          LC_CTYPE=C.UTF-8
          ssh ${SSH_APPEND_FLAGS} $REMOTE_SERVER_NAME
          ;;
      esac
      cd ..
      ;;
  esac

  main
}

main
