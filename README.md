# Vault Frog v4.0 :frog:  
> A simple password vault based in bash using AES-256-CBC.  
#  
[![Banner](img/00.png)](Banner)  
#  
### Requirements:  
 * Openssl
 * Sqlite3
#### Install openssl:  
```
frog@lago:~$ sudo apt update
frog@lago:~$ sudo apt install openssl -y
```
#### Install sqlite3:  
```
frog@lago:~$ sudo apt update
frog@lago:~$ sudo apt install sqlite3 -y
```
### Usage:  
#### Help:  
```
frog@lago:~$ bash VaultFrog.sh --help
```
[![Banner](img/01.png)](Help)  
#### Store credential:  
```
frog@lago:~$ bash VaultFrog.sh 
```
[![Banner](img/02.png)](Store)  
#### List creds:  
```
frog@lago:~$  bash VaultFrog.sh --list
```
[![Banner](img/04.png)](Store)  
#### Recover:  
```
frog@lago:~$ bash VaultFrog.sh --view-pass SITE_NAME USER_NAME
```
[![Banner](img/03.png)](Recover)  

:frog:
