#!/bin/sh

read -s -p "Please enter the CA passkey:" PASSKEY
SCRIPTDIR=$(dirname -- "$( readlink -f -- "$0"; )";) 
CONFDIR="${SCRIPTDIR}/config"
ASSETDIR="${SCRIPTDIR}/assets"

if [ ! -d "${ASSETDIR}" ]; then mkdir "${ASSETDIR}"; fi

echo "Create Private CA Key [${ASSETDIR}/CA.key]"
openssl genrsa -aes256 -out "${ASSETDIR}/CA.key" -passout pass:"${PASSKEY}" 4096

echo "Create Certificate of the CA [${ASSETDIR}/CA.crt]"
openssl req -x509 -new -nodes -key "${ASSETDIR}/CA.key" -sha256 -days 1826 -out "${ASSETDIR}/CA.crt" -subj '/CN=ai root CA/C=DE/ST=None/L=None/O=Artificial Intelligence Applications Division' -passin pass:"${PASSKEY}"

echo "Please copy ${ASSETDIR}/CA.crt to your system certificate directory"

echo "Create a certificate for the webserver [${ASSETDIR}/ai.csr|${ASSETDIR}/ai.key]"
openssl req -new -nodes -out "${ASSETDIR}/ai.csr" -newkey rsa:4096 -keyout "${ASSETDIR}/ai.key" -subj '/CN=ai system/C=DE/ST=None/L=None/O=Artificial Intelligence Applications Division'

echo "Sign the certificate [${ASSETDIR}/ai.crt]"
openssl x509 -req -in "${ASSETDIR}/ai.csr" -CA "${ASSETDIR}/CA.crt" -CAkey "${ASSETDIR}/CA.key" -CAcreateserial -out "${ASSETDIR}/ai.crt" -days 730 -sha256 -extfile "${CONFDIR}/ai.v3.ext" -passin pass:"${PASSKEY}"
