#!/bin/bash

if [ "$1" == "--help" ] || [ "$1" == "-h" ];then

    #Help
    echo -e "[*] Valt Frog Help [*]\n\n--view-pass SITE USER\nbash $0 # for start vaultfrog.\n[*]"
    exit 0;

elif [ "$1" == "--view-pass" ];then

    #Get Encrypt Pass.
    passR="$(sqlite3 $HOME/.vaultfrog/.creds.db "select pass from secrets where site like '%$2%' and userN='$3';")"

    #Decrypt pass.
    fEnc="/tmp/.vaultfrog$RANDOM.f"
    echo $passR >> $fEnc
    openssl enc -d -aes-256-cbc -a -salt -in $fEnc

    #Clear.
    echo '' >> $fEnc
    rm -rf $fEnc
    exit 0;
fi

# Banner.
echo "Frog password vault v4.0"
printf "
        ()-()
      .-(___)-.
       _<   >_
frog   \/   \/
\n\n"

# Get necessary data from user.
read -p "Enter the site (ex: https://google.com): " site;
read -p "Enter Username: " userN;
read -p "Set password length: " lenpwd;

if grep -q "[a-z]" <<< "$lenpwd"; then
    echo "Somente numeros !"

elif grep -q "[A-Z]" <<< "$lenpwd";then
    echo "Somente numeros !"

else

    # Create secure keys.
    pass="$(</dev/urandom tr -dc 'A-Za-z0-9@#$&_+' | head -c$lenpwd)"
    fEnc="/tmp/.vaultfrog$RANDOM.f"
    echo $pass >> $fEnc
    passEnc="$(openssl enc -aes-256-cbc -a -salt -in $fEnc)"

    # Create or Store data.
    if [ -f $HOME/.vaultfrog/.creds.db ];then
        sqlite3 $HOME/.vaultfrog/.creds.db "insert into secrets (site,userN,pass) values ('$site','$userN','$passEnc');"
    else
        mkdir -p $HOME/.vaultfrog/
        sqlite3 $HOME/.vaultfrog/.creds.db "create table secrets (id INTEGER PRIMARY KEY,site TEXT,userN TEXT,pass TEXT);"
        sqlite3 $HOME/.vaultfrog/.creds.db "insert into secrets (site,userN,pass) values ('$site','$userN','$passEnc');"
    fi

    # Show passwords.
    echo -e "\n\n[*] Vault Frog [*]\n\n\tSite: $site\n\tUsername: $userN\n\tLength: $lenpwd\n\tPassword: $pass\n------------------------------------------------------------\n"

    # Clear encrypt files.
    echo '' >> $fENc
    rm -rf $fEnc

fi
