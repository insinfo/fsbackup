//C:\Program Files (x86)\ICW\bin\cygrunsrv.exe
//user of cwRsyncServer
//User: SvcCWRSYNC
//Senha: tibMKCp7xJ3787
//Add new user account from command line (CMD)
//net user root 257257 /ADD
//net localgroup administrators root /add
//cd ICW\bin
//mkpasswd.exe -l > ..\etc\passwd
//mkgroup.exe -l > ..\etc\group
//C:\Program Files (x86)\ICW\rsyncd.conf
//tamanho de pasta no linux
//Este comando exibe informações sobre o espaço usado pelos diretórios.
//-k : mostra o espaço ocupado em Kbytes (é o padrão). -s : mostra apenas o total ocupado (sumário).
//du -sk /var/www/dart | cut -f 1

//du -sb /var/www/dart # disk usage summarize in one line with bytes
//compacta uma pasta no debian
//tar czf /var/www/dart/$(date +%Y%m%d-%H%M%S).tar.gz /var/www/dart/
//tar cf - /var/www/dart -P | pv -s $(du -sb /var/www/dart | awk '{print $1}') | gzip > $(date +%Y%m%d).tar.gz

//rsync -Cravz --chmod=u=rwx,g=rx,o=rx --progress --partial --delete-excluded /var/www/dart/$(date +%Y%m%d).tar.gz rsync://192.168.66.123/bkp
//ou
//rsync -aix --progress /var/www/dart/$(date +%Y%m%d).tar.gz rsync://192.168.66.123/bkp

class RsyncService {}
