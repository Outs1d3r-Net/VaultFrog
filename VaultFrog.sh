#!/bin/bash

if [ "$1" == "--help" ] || [ "$1" == "-h" ];then

    # Help
    echo -e "[*] Vault Frog Help [*]\n\n\t--view-pass SITE USER\t# For get cred.\n\t--help or -h\t\t# Show this message\n\t--list or -l\t\t# Show creds store.\n\t--update ID USERNAME NEW_PASSWORD # Update cred password.\t\n\t--guard SITE_NAME USER_NAME PASSWORD # For add creds.\t\t\n\n\t/bin/bash $0\t# For start vaultfrog.\n\n[*]"
    exit 0;

elif [ "$1" == "--list" ] || [ "$1" == "-l" ];then

    # List method.
    sqlite3 $HOME/.vaultfrog/.creds.db "SELECT id,site,userN FROM secrets;" | column -s "|" -t
    exit 0;

elif [ "$1" == "--update" ];then

    # Update method.
    fEnc="/tmp/.vaultfrog$RANDOM.f"
    echo $4 >> $fEnc
    passEnc="$(openssl enc -aes-256-cbc -a -salt -in $fEnc)"
    sqlite3 $HOME/.vaultfrog/.creds.db "UPDATE secrets SET pass='$passEnc' WHERE id='$2' AND userN='$3'"

    # Clear.
    echo "croack!" > $fEnc
    rm -rf $fEnc
    exit 0;

elif [ "$1" == "--guard" ];then

    # Add creds method.
    fEnc="/tmp/.vaultfrog$RANDOM.f"
    echo $4 >> $fEnc
    passEnc="$(openssl enc -aes-256-cbc -a -salt -in $fEnc)"
    sqlite3 $HOME/.vaultfrog/.creds.db "INSERT INTO secrets (site,userN,pass) VALUES ('$2','$3','$passEnc');"
    clear
    echo "[*] Credential:--> $2:$3 --> add successful."

    # Clear.
    echo "croack!" > $fEnc
    rm -rf $fEnc
    exit 0;

elif [ "$1" == "--view-pass" ];then

    # Get Encrypt Pass.
    passR="$(sqlite3 $HOME/.vaultfrog/.creds.db "select pass FROM secrets WHERE site LIKE '%$2%' AND userN='$3';")"

    # Decrypt pass.
    fEnc="/tmp/.vaultfrog$RANDOM.f"
    echo $passR >> $fEnc
    openssl enc -d -aes-256-cbc -a -salt -in $fEnc

    # Clear.
    echo "croack!" > $fEnc
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
        sqlite3 $HOME/.vaultfrog/.creds.db "INSERT INTO secrets (site,userN,pass) VALUES ('$site','$userN','$passEnc');"
    else
        mkdir -p $HOME/.vaultfrog/
        sqlite3 $HOME/.vaultfrog/.creds.db "CREATE TABLE secrets (id INTEGER PRIMARY KEY,site TEXT,userN TEXT,pass TEXT);"
        sqlite3 $HOME/.vaultfrog/.creds.db "INSERT INTO secrets (site,userN,pass) VALUES ('$site','$userN','$passEnc');"
    fi

    # Show passwords.
    echo -e "\n\n[*] Vault Frog [*]\n\n\tSite: $site\n\tUsername: $userN\n\tLength: $lenpwd\n\tPassword: $pass\n------------------------------------------------------------\n"

    # Clear encrypt files.
    echo "croack!" > $fEnc
    rm -rf $fEnc

fi
