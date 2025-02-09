#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME/$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER


CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Please provide root privelegs $N" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE () {
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is.... $R FAILED $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is.... $G SUCCESS $N" | tee -a $LOG_FILE

    fi
}

CHECK_ROOT

echo "Script started executing at: $(date)"




dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabled nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

useradd expense