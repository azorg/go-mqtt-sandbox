#!/bin/bash

DAYS="3653" # 10 years

NODES="-nodes"

function getipaddresses() {
  /sbin/ifconfig |
          grep -v tunnel |
          sed -En '/inet6? /p' |
          sed -Ee 's/inet6? (addr:)?//' |
          awk '{print $1;}' |
          sed -e 's/[%/].*//' |
          egrep -v '(::1|127\.0\.0\.1)'	# omit loopback to add it later
}

function addresslist() {
  ALIST=""
  for a in $(getipaddresses); do
          ALIST="${ALIST}IP:$a,"
  done
  ALIST="${ALIST}IP:127.0.0.1,IP:::1,"

  for ip in $(echo ${ALTADDRESSES}); do
          ALIST="${ALIST}IP:${ip},"
  done
  for h in $(echo ${ALTHOSTNAMES}); do
          ALIST="${ALIST}DNS:$h,"
  done
  ALIST="${ALIST}DNS:${host},DNS:localhost"
  echo $ALIST
}

rm -rf ca
rm -rf server
rm -rf client

mkdir -p ca
mkdir -p server
mkdir -p client

echo "*** Create un-encrypted (!) CA key (ca.key, ca.crt)"
openssl req -newkey rsa:4096 -x509 $NODES -sha512 -days $DAYS -extensions v3_ca \
        -subj "/CN=Fake root CA/O=localhost/OU=generate-CA/emailAddress=root@example.net" \
        -keyout ca/ca.key -out ca/ca.crt

echo "*** Warning: the CA key (ca.key) is not encrypted; store it safely!"
chmod 400 ca/ca.key
chmod 444 ca/ca.crt

echo "*** View CA certificate (ca.crt):"
openssl x509 -in ca/ca.crt -nameopt multiline -subject -noout

echo "*** Creating server key and signing request (server.key, server.csr)"
openssl genrsa -out server/server.key 4096
openssl req -new -sha512 \
        -subj "/CN=An MQTT broker/O=localhost/OU=generate-CA/emailAddress=broker@example.net" \
        -key server/server.key \
        -out server/server.csr

chmod 400 server/server.key

# There's no way to pass subjAltName on the CLI so
# create a cnf file and use that.
CNF=`mktemp /tmp/cacnf.XXXXXXXX` || { echo "$0: can't create temp file" >&2; exit 1; }
sed -e 's/^.*%%% //' > $CNF <<\!ENDconfig
%%% [ JPMextensions ]
%%% basicConstraints        = critical,CA:false
%%% nsCertType              = server
%%% keyUsage                = nonRepudiation, digitalSignature, keyEncipherment
%%% extendedKeyUsage        = serverAuth
%%% nsComment               = "Broker Certificate"
%%% subjectKeyIdentifier    = hash
%%% authorityKeyIdentifier  = keyid,issuer:always
%%% subjectAltName          = $ENV::SUBJALTNAME
%%% # issuerAltName           = issuer:copy
%%% ## nsCaRevocationUrl       = http://mqttitude.org/carev/
%%% ## nsRevocationUrl         = http://mqttitude.org/carev/
%%% certificatePolicies     = ia5org,@polsection
%%% 
%%% [polsection]
%%% policyIdentifier	    = 1.3.5.8
%%% CPS.1		    = "http://localhost"
%%% userNotice.1	    = @notice
%%% 
%%% [notice]
%%% explicitText            = "This CA is for a local MQTT broker installation only"
%%% organization            = "Null Labs"
%%% noticeNumbers           = 1
!ENDconfig

SUBJALTNAME="$(addresslist)"
export SUBJALTNAME

echo "*** Creating and signing server certificate (server.crt)"
openssl x509 -req -sha512 \
        -days $DAYS \
        -extfile $CNF \
        -CA       ca/ca.crt \
        -CAkey    ca/ca.key \
        -CAserial ca/ca.srl \
        -CAcreateserial \
        -in  server/server.csr \
        -out server/server.crt
        #-extensions JPMclientextensions \

rm -f $CNF
chmod 444 server/server.crt

echo "*** Creating client key and signing request (client.key, client.csr)"
openssl genrsa -out client/client.key 4096

CNF=`mktemp /tmp/cacnf-req.XXXXXXXX` || { echo "$0: can't create temp file" >&2; exit 1; }

# Mosquitto's use_identity_as_username takes the CN attribute
# so we're populating that with the client's name
sed -e 's/^.*%%% //' > $CNF <<!ENDClientconfigREQ
%%% [ req ]
%%% distinguished_name = req_distinguished_name
%%% prompt             = no
%%% output_password    = secret
%%% 
%%% [ req_distinguished_name ]
%%% # O                       = Nobody
%%% # OU                      = MQTT
%%% # CN                      = User
%%% CN                        = client
%%% # emailAddress            = client
!ENDClientconfigREQ

openssl req -new -sha512 \
        -config $CNF \
        -key client/client.key \
        -out client/client.csr

rm -f $CNF
chmod 400 client/client.key

CNF=`mktemp /tmp/cacnf-cli.XXXXXXXX` || { echo "$0: can't create temp file" >&2; exit 1; }
sed -e 's/^.*%%% //' > $CNF <<\!ENDClientconfig
%%% [ JPMclientextensions ]
%%% basicConstraints        = critical,CA:false
%%% subjectAltName          = email:copy
%%% nsCertType              = client,email
%%% extendedKeyUsage        = clientAuth,emailProtection
%%% keyUsage                = digitalSignature, keyEncipherment, keyAgreement
%%% nsComment               = "Client Broker Certificate"
%%% subjectKeyIdentifier    = hash
%%% authorityKeyIdentifier  = keyid,issuer:always
!ENDClientconfig

echo "*** Creating and signing client certificate (client.crt)"
openssl x509 -req -sha512 \
        -days $DAYS \
        -extfile ${CNF} \
        -CA       ca/ca.crt \
        -CAkey    ca/ca.key \
        -CAserial ca/ca.srl \
        -CAcreateserial \
        -in  client/client.csr \
        -out client/client.crt
        #-extensions JPMclientextensions \

rm -f $CNF
chmod 444 client/client.crt


