#!/bin/bash

mkdir -p certs crl newcerts private

openssl genrsa -aes256 -out private/ca.key.pem 4096

openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem \
      -subj '/C=US/ST=South Carolina/L=Moncks Corner/O=Red Hat/OU=OpenTLC/CN=Star Destroyer/emailAddress=administrative-not-existent-address@our-awesome-domain.com' 

rm -rf server.*
echo "gen server key"
openssl genrsa        -out server.key 2048 \
  -subj '/C=US/ST=South Carolina/L=Moncks Corner/O=Red Hat/OU=OpenTLC/CN=`hostname`/emailAddress=administrative-not-existent-address@our-awesome-domain.com' -config openssl.cnf

echo "create cert request"
echo '/C=US/ST=South Carolina/L=Moncks Corner/O=Red Hat/OU=OpenTLC/CN='`hostname`' emailAddress=administrative-not-existent-address@our-awesome-domain.com'
openssl req -new -key server.key -sha256 -nodes  \
  -subj '/C=US/ST=South Carolina/L=Moncks Corner/O=Red Hat/OU=OpenTLC/CN='`hostname`'/emailAddress=administrative-not-existent-address@our-awesome-domain.com' > server.csr


echo "sign request"
openssl ca -config openssl.cnf  -extensions server_cert -days 3750 -notext -md sha256       -in server.csr       -out server.crt

cp server.* /etc/openldap/certs
#cp ./private/ca.key.pem /etc/openldap/certs
cp ./certs/ca.cert.pem /etc/openldap/certs
ldapmodify -Y EXTERNAL -H ldapi:/// -f tls.ldif
systemctl restart slapd
