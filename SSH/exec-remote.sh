#!/bin/bash

#_SELF="${0##*/}"
#_SELF=$(basename "$0")
#SSH_KEY_FILE="../Keys/${REMOTE_SERVER_NAME}.pem"

read -p '[+] Choose connection type (Exit=CTRL+C):
- [*] SSH
- [1] WinSCP
- [2] Navicat
Default[*]: ' CONN_TYPE

if [ -z $DISPLAY ]; then
  DISPLAY=127.0.0.1:0
fi
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
      echo $PASSWORD_FLAG
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
