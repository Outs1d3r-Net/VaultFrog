#!/bin/bash

if [ "$1" == "--help" ] || [ "$1" == "-h" ];then

    # Help
    echo -e "[*] Vault Frog Help [*]\n\n\t--view-pass SITE USER\t\t\t# For get cred.\n\t--help or -h\t\t\t\t# Show this message\n\t--list or -l\t\t\t\t# Show creds store.\n\t--update ID USERNAME\t\t\t# Update cred password.\t\n\t--guard SITE_NAME USER_NAME\t\t# For add creds.\t\t\n\t--remove ID\t\t\t\t# Remove cred.\n\n\t/bin/bash $0\t\t\t# For start vaultfrog.\n\n[*]"
    exit 0;

elif [ "$1" == "--list" ] || [ "$1" == "-l" ];then

    # Verify if db exists.
    if [ ! -e $HOME/.vaultfrog/.creds.db ];then
        mkdir -p $HOME/.vaultfrog/
        sqlite3 $HOME/.vaultfrog/.creds.db "CREATE TABLE secrets (id INTEGER PRIMARY KEY,site TEXT,userN TEXT,pass TEXT);"
    fi
    
    # List method.
    sqlite3 $HOME/.vaultfrog/.creds.db "SELECT id,site,userN FROM secrets;" | column -s "|" -t
    exit 0;

elif [ "$1" == "--update" ];then

    # Update method.
    fEnc="/tmp/.vaultfrog$RANDOM.f"
    read -s -p "Enter Password: " pass;
    echo
    echo $pass >> $fEnc
    passEnc="$(openssl enc -aes-256-cbc -a -salt -in $fEnc -pbkdf2)"
    sqlite3 $HOME/.vaultfrog/.creds.db "UPDATE secrets SET pass='$passEnc' WHERE id='$2' AND userN='$3'"

    # Clear.
    history -wc
    echo "croack!" > $fEnc
    rm -rf $fEnc
    exit 0;

elif [ "$1" == "--guard" ];then

    # Verify if db exists.
    if [ ! -e $HOME/.vaultfrog/.creds.db ];then
        mkdir -p $HOME/.vaultfrog/
        sqlite3 $HOME/.vaultfrog/.creds.db "CREATE TABLE secrets (id INTEGER PRIMARY KEY,site TEXT,userN TEXT,pass TEXT);"
    fi
    
    # Add creds method.
    fEnc="/tmp/.vaultfrog$RANDOM.f"
    read -s -p "Enter Password: " pass;
    echo
    echo $pass >> $fEnc
    passEnc="$(openssl enc -aes-256-cbc -a -salt -in $fEnc -pbkdf2)"
    sqlite3 $HOME/.vaultfrog/.creds.db "INSERT INTO secrets (site,userN,pass) VALUES ('$2','$3','$passEnc');"
    clear
    echo "[*] Credential:--> $2:$3 --> add successful."

    # Clear.
    history -wc
    echo "croack!" > $fEnc
    rm -rf $fEnc
    exit 0;

elif [ "$1" == "--remove" ];then

    # Add remove method.
    rcred="$(sqlite3 $HOME/.vaultfrog/.creds.db "SELECT site,userN FROM secrets WHERE id='$2'")"
    echo $rcred
    read -p "Are you sure you want to delete this credential ? [Y/N]" qsT;
    if [ "$qsT" == "y" ] || [ "$qsT" == "Y" ];then
        read -p "Enter the following phrase to delete the credential:(Long fall):--> " qsT2;
        if [ "$qsT2" == "Long fall" ];then
            sqlite3 $HOME/.vaultfrog/.creds.db "DELETE FROM secrets WHERE id='$2'"
            clear
            echo "[*] Credential:--> $rcred --> removed !"
            exit 0;
        else
            echo "Error ! No credentials removed."
            exit 0;
        fi
    else
        echo "No credentials removed."
        exit 0;
    fi

elif [ "$1" == "--view-pass" ];then

    # Get Encrypt Pass.
    passR="$(sqlite3 $HOME/.vaultfrog/.creds.db "SELECT pass FROM secrets WHERE site LIKE '%$2%' AND userN='$3';")"

    # Decrypt pass.
    fEnc="/tmp/.vaultfrog$RANDOM.f"
    echo $passR >> $fEnc
    openssl enc -d -aes-256-cbc -a -salt -in $fEnc -pbkdf2

    # Clear.
    history -wc
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
    passEnc="$(openssl enc -aes-256-cbc -a -salt -in $fEnc -pbkdf2)"

    # Create or Store data.
    if [ -e $HOME/.vaultfrog/.creds.db ];then
        sqlite3 $HOME/.vaultfrog/.creds.db "INSERT INTO secrets (site,userN,pass) VALUES ('$site','$userN','$passEnc');"
    else
        mkdir -p $HOME/.vaultfrog/
        sqlite3 $HOME/.vaultfrog/.creds.db "CREATE TABLE secrets (id INTEGER PRIMARY KEY,site TEXT,userN TEXT,pass TEXT);"
        sqlite3 $HOME/.vaultfrog/.creds.db "INSERT INTO secrets (site,userN,pass) VALUES ('$site','$userN','$passEnc');"
    fi

    # Show passwords.
    echo -e "\n\n[*] Vault Frog [*]\n\n\tSite: $site\n\tUsername: $userN\n\tLength: $lenpwd\n\tPassword: $pass\n------------------------------------------------------------\n"

    # Clear encrypt files.
    history -wc
    echo "croack!" > $fEnc
    rm -rf $fEnc

fi
