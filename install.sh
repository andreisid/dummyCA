#!/usr/bin/env bash
ROOT_PATH="/root/ca"
INTERMEDIATE_PATH="$ROOT_PATH/intermediate"

if [ -d $ROOT_PATH ] 
then
    printf "[ERROR]: \"$ROOT_PATH\" already exists"
    exit 1
fi

printf "\n[info]: Creating directory structure"
mkdir -p -v {$ROOT_PATH,$INTERMEDIATE_PATH}/{certs,crl,newcerts,private,csr}
printf "\n[info]: Setting permissions"
chmod 700 {$ROOT_PATH,$INTERMEDIATE_PATH}/private
printf "\n[info]: Creating aditional files"
touch {$ROOT_PATH,$INTERMEDIATE_PATH}/index.txt
echo 1000 > $ROOT_PATH/serial 
echo 1000 >  $INTERMEDIATE_PATH/serial
echo 1000 >  $INTERMEDIATE_PATH/crlnumber

cp opensslIntermediateCA.cnf $INTERMEDIATE_PATH/openssl.cnf
cp opensslRootCA.cnf $ROOT_PATH/openssl.cnf

printf "\n[info] --- Generating RootCA ---\n"
cd $ROOT_PATH
printf "\n[info] Creating RootCA Private Key---\n"
openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem
printf "\n[info] Creating RootCA Certificate---\n"
openssl req -config openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem

printf "\n[info] --- Generating IntermediateCA ---\n"
cd $ROOT_PATH
printf "\n[info] Creating IntermediateCA Private Key---\n"
openssl genrsa -aes256 \
      -out intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem
printf "\n[info] Creating IntermediateCA Request---\n"

##create request to be signed by RootCA
openssl req -config intermediate/openssl.cnf -new -sha256 \
      -key intermediate/private/intermediate.key.pem \
      -out intermediate/csr/intermediate.csr.pem

printf "\n[info]  Signing IntermediateCA Request---\n"
##RootCA signs the Intermediate request and outputs a certificate
cd $ROOT_PATH
openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in intermediate/csr/intermediate.csr.pem \
      -out intermediate/certs/intermediate.cert.pem
chmod 444 intermediate/certs/intermediate.cert.pem

printf "\n[info] Creating the certificate chain---\n"
cat intermediate/certs/intermediate.cert.pem \
      certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem
printf "\n[info] New certificate authority created successfully---\n"
printf "\n---> RootCA PK location: $ROOT_PATH/private/ca.key.pem\n"
printf "\n---> RootCA Certificate location: $ROOT_PATH/certs/ca.cert.pem\n"
printf "\n---> IntermediateCA PK location: $INTERMEDIATE_PATH/private/intermediate.key.pem\n"
printf "\n---> IntermediateCA Certificate location: $INTERMEDIATE_PATH/certs/intermediate.key.pem\n"
printf "\n---> Certificate Chain location: $INTERMEDIATE_PATH\certs\ca-chain.cert.pem\n"

 
