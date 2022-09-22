#!/bin/bash

nssdb_exists="$(ls -lAh /home/$USER | grep '.pki')"
if [ "$nssdb_exists" != "" ]
  then
	echo 'nssdb already initialized.  Skipping creation...'
  else
	killall chrome
	mkdir -p /home/$USER/.pki/nssdb && modutil -force -create -dbdir sql:/home/$USER/.pki/nssdb/
fi

for file in /usr/local/share/ca-certificates/*.cer
do
  certutil -d sql:/home/$USER/.pki/nssdb/ -A -t "CT,C,C" -n "$file" -i "$file"
done

cackey_loaded="$(modutil -dbdir sql:/home/$USER/.pki/nssdb/ -list | grep 'CAC Module')"

if [ "$cackey_loaded" != "" ]
  then
	modutil -dbdir sql:/home/$USER/.pki/nssdb/ -force -delete "CAC Module"
  else echo 'CACkey not loaded.  Skipping...'
fi

cac_loaded="$(modutil -dbdir sql:/home/$USER/.pki/nssdb/ -list | grep 'CAC Module')"

if [ "$cac_loaded" != "" ]
  then
	echo 'CAC Module already loaded.  Skipping...'
  else modutil -dbdir sql:/home/$USER/.pki/nssdb/ -force -add "CAC Module" -libfile /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so
fi
