#!/bin/bash
#
# This script is based on the script found at this location:
# https://serverfault.com/questions/483941/generate-an-openvpn-profile-for-client-user-to-import 
# as provided by Eric Maasdorp
# 

NAME=$1

OPENVPNCONFIG=/etc/openvpn
EASYRSAPATH=$OPENVPNCONFIG/easy-rsa
KEYSPATH="$EASYRSAPATH/keys"

TEMPLATE=$2
OUTPUTDIR=$OPENVPNCONFIG/clientconfig

CRT=".crt"
KEY=".key"
CA="ca.crt"
TA="ta.key"
FILEEXT=".ovpn"

if [ -z $NAME ]
then
    echo "Please supply the name of a client you want to create a configuration file for."
    exit 1
fi

if [ -z $TEMPLATE ]
then
    echo "Please specify the appropriate template file."
    exit 1
fi

if [ ! -e $TEMPLATE ]
then
    echo "Specified template file does not exist."
    exit 1
fi

if [ -e "$OUTPUTDIR/$NAME$FILEEXT" ]
then
    echo "File $OUTPUTDIR/$NAME$FILEEXT already exists - please backup and remove it first"
    exit 1
fi

#1st Verify that client's Public Key Exists
if [ ! -f $KEYSPATH//$NAME$CRT ]; then
    echo "[ERROR]: Client Public Key Certificate not found: $KEYSPATH//$NAME$CRT"
    exit
fi
echo "Client's cert found: $KEYSPATH/$NAME$CR"

#Then, verify that there is a private key for that client
if [ ! -f $KEYSPATH/$NAME$KEY ]; then
    echo "[ERROR]: Client 3des Private Key not found: $KEYSPATH/$NAME$KEY"
    exit
fi
echo "Client's Private Key found: $KEYSPATH/$NAME$KEY"

#Confirm the CA public key exists
if [ ! -f $KEYSPATH/$CA ]; then
     echo "[ERROR]: CA Public Key not found: $KEYSPATH/$CA"
    exit
fi
echo "CA public Key found: $KEYSPATH/$CA"

#Confirm the tls-auth ta key file exists
if [ ! -f $KEYSPATH/$TA ]; then
 echo "[ERROR]: tls-auth Key not found: $KEYSPATH/$TA"
    exit
fi
echo "tls-auth Private Key found: $KEYSPATH/$TA"

#Ready to make a new .opvn file - Start by populating with the
cat $TEMPLATE > $OUTPUTDIR/$NAME$FILEEXT

#Now, append the CA Public Cert
echo "<ca>" >> $OUTPUTDIR/$NAME$FILEEXT
cat $KEYSPATH/$CA | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> $OUTPUTDIR/$NAME$FILEEXT
echo "</ca>" >> $OUTPUTDIR/$NAME$FILEEXT

#Next append the client Public Cert
echo "<cert>" >> $OUTPUTDIR/$NAME$FILEEXT
cat $KEYSPATH/$NAME$CRT | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' >> $OUTPUTDIR/$NAME$FILEEXT
echo "</cert>" >> $OUTPUTDIR/$NAME$FILEEXT

#Then, append the client Private Key
echo "<key>" >> $OUTPUTDIR/$NAME$FILEEXT
cat $KEYSPATH/$NAME$KEY >> $OUTPUTDIR/$NAME$FILEEXT
echo "</key>" >> $OUTPUTDIR/$NAME$FILEEXT

#Finally, append the TA Private Key
echo "<tls-auth>" >> $OUTPUTDIR/$NAME$FILEEXT
cat $KEYSPATH/$TA >> $OUTPUTDIR/$NAME$FILEEXT
echo "</tls-auth>" >> $OUTPUTDIR/$NAME$FILEEXT

echo "Done! $OUTPUTDIR/$NAME$FILEEXT Successfully Created."

