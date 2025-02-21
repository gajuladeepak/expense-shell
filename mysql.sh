#!bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +Y-%m-%d-%H-%M-%S)
LOGFILE="$LOG_FOLDER/$SCRIPT_NAME-TIMESTAMP"



USERID=$(id -u)

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$Y Provide root previleges $N" | tee -a $LOGFILE
    fi
}

CHECK_ROOT

