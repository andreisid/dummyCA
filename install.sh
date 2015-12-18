#!/usr/bin/env bash
ROOT_PATH="/tmp/test"
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


