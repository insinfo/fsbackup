//usuario e senha do copssh
//user: SvcCOPSSH
//senha: tibMKCp7xJ3787
//C:\Program Files (x86)\ICW\bin\cygrunsrv.exe | OpenSSHServer
//usuario e senha do cwRsyncServer
//user of cwRsyncServer
//User: SvcCWRSYNC
//Senha: tibMKCp7xJ3787
//Add new user account from command line (CMD)
//net user root 257257 /ADD
//net localgroup administrators root /add
//Em seguida digite os seguintes comandos que estão dentro de c:\ICW\bin
//Esses comandos basicamente irão ler a base local de usuários e grupos do Windows e ao mesmo tempo vão direcionar a saída para os arquivos passwd e group para o diretório C:\ICW\etc.
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
//usando rsync sobre SSH
// rsync -aix --progress /var/www/dart/$(date +%Y%m%d).tar.gz isaque@192.168.66.123:/cygdrive/c/bkp/

//chave publica id_rsa.pub
//-----BEGIN EC PRIVATE KEY-----
//MHcCAQEEIPDZdjsKAaXY4ZitrxpJNlfsPAjorDVLMUePsj7IAcqCoAoGCCqGSM49
//AwEHoUQDQgAEyb4HWPzNXrR7Rj207pyrWC2lGCOvuJjvEKUcE1s1C5gqY1W2qXqC
//hEeAlUaiLsK5Uw/IlHI4uKug5KfeSQzPZQ==
//-----END EC PRIVATE KEY-----

//chmod 600 /var/www/dart/id_rsa.pub
//copia o arquivo usando a chave publica
//  rsync --progress -ave  "ssh -i /var/www/dart/id_rsa.pub" /var/www/dart/$(date +%Y%m%d).tar.gz isaque@192.168.66.123:/cygdrive/c/bkp/

//Baseado em Berkeley Software Distribution (BSD) Remote Copy Protocol, o SCP (Secure Copy) é um protocolo de rede para transferências de arquivos
//Na essência, o SCP é uma mistura de RCP e SSH (Secure Shell)
//scp <source> <destination>
//To copy a file from B to A while logged into B:
//scp /var/www/dart/laravel.txt  isaque@192.168.66.123:/c/bkp/
//To copy a file from B to A while logged into A:
//scp username@b:/path/to/file /path/to/destination
class RsyncService {}
