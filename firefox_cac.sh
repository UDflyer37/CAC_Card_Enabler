#!/bin/bash

firefox --version

nssdb_exists="$(ls -lAh /home/$USERNAME/.mozilla/firefox/ | grep '.default')"
if [ "$nssdb_exists" != "" ]
  then
	echo 'firefox nssdb already initialized.  Skipping creation...'
  else
	Xvfb :1337& firefox --display=:1337& sleep 3 ; killall firefox ; killall Xvfb
fi

export ffdir="$(grep Path /home/$USERNAME/.mozilla/firefox/profiles.ini | cut -d'=' -f 2)"

for file in /usr/local/share/ca-certificates/*.cer
do
  certutil -d sql:/home/$USERNAME/.mozilla/firefox/$ffdir/ -A -t "CT,C,C" -n "$file" -i "$file"
done

cackey_loaded="$(modutil -dbdir sql:/home/$USERNAME/.pki/nssdb/ -list | grep 'libcackey.so')"

if [ "$cackey_loaded" == "library name: /usr/lib64/libcackey.so" ]
  then
	modutil -dbdir sql:/home/$USERNAME/.pki/nssdb/ -force -delete "CAC Module"
  else echo 'CACkey not loaded.  Skipping...'
fi

cac_loaded="$(export ffdir="$(grep Path /home/$USERNAME/.mozilla/firefox/profiles.ini | cut -d'=' -f 2)" && modutil -list -dbdir sql:/home/$USERNAME/.mozilla/firefox/$ffdir | grep CAC)"
if [ "$cac_loaded" != "" ]
  then
	echo 'CAC Module already loaded.  Exiting...'
  else modutil -add CAC -force -dbdir sql:/home/$USERNAME/.mozilla/firefox/$ffdir/ -libfile /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so
fi

########################
#IF ERROR FINDING $ffdir
########################

# navigate to /home/$USERNAME/.mozilla/firefox/profiles.ini and copy $ffdir in line 2

modutil -add CAC -force -dbdir sql:/home/$USERNAME/.mozilla/firefox/nmp2nq4l.default-release/ -libfile /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so
