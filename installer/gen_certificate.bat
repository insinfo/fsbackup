REM Gere uma chave privada.
openssl genrsa -out windows_certificate_key.key 2048
REM Gere um arquivo CSR com a ajuda da chave privada.

REM Country Name (2 letter code) [AU]:BR
REM State or Province Name (full name) [Some-State]:Rio de Janeiro
REM Locality Name (eg, city) []:Rio das Ostras
REM Organization Name (eg, company) [Internet Widgits Pty Ltd]:Prefeitura de Rio das Ostras
REM Organizational Unit Name (eg, section) []:ASCOMTI
REM Common Name (e.g. server FQDN or YOUR name) []:riodasostras.rj.gov.br
REM Email Address []:webmaster@riodasostras.rj.gov.br
openssl req -new -key windows_certificate_key.key -out windows_certificate_csr.csr
REM Gere um arquivo CRT com a ajuda da chave privada e do arquivo CSR
openssl x509 -in windows_certificate_csr.csr -out windows_certificate_crt.crt -req -signkey windows_certificate_key.key -days 3650
REM Gere. arquivo p fx (finalmente) com a ajuda da chave privada e arquivo CRT. Senha: 123456
openssl pkcs12 -export -out CERTIFICATE.pfx -inkey windows_certificate_key.key -in windows_certificate_crt.crt
REM C = BR, ST = Rio de Janeiro, L = Rio das Ostras, O = Prefeitura de Rio das Ostras, OU = ASCOMTI, CN = riodasostras.rj.gov.br