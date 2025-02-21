#!bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOG_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP"
mkdir -p $LOG_FOLDER

USERID=$(id -u)

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Please Provide Root Preveliges $N" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is.... $R FAILURE $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is.... $G SUCCESS $N" | tee -a $LOG_FILE

    fi
}

CHECK_ROOT

echo "Script started execution at: $(data)" | tee -a $LOG_FILE

dnf module disable nodejs -y
VALIDATE $? "Disabling NODEJS"


dnf module enable nodejs:20 -y
VALIDATE $? "Enabling NODEJS"

dnf install nodejs -y
VALIDATE $? "Installing NODEJS"

id expense
if [ $? -ne 0 ]
then
    echo -e "$Y NO SUCH USER $N"
    echo -e "$Y Creating USER $N"
    useradd expense
    VALIDATE $? "Created USER"
else
    echo -e " $Y User is already Created"
fi

