if [ $FTP_ENABLE ] ; then
    curlftpfs ${FTP_USR}:${FTP_PWD}@${FTP_SRV} ${FTP_MNT}\
    echo "Mount Remote FTP Server Finish."
else
    echo "Disable Mount Remote FTP Server"
fi

touch /aria2.session

aria2c --conf-path=/etc/aria2.conf
