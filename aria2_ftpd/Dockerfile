FROM gam2046/aria2  

ENV FTP_SRV "127.0.0.1"
ENV FTP_USR "test"
ENV FTP_PWD "test"
ENV FTP_MNT "/mnt"

ADD command.sh .
RUN apt-get -y install curlftpfs
 
CMD ["sh", "command.sh"]
