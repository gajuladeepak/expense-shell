#!bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "$R Please run this script with root priveleges $N" | tee -a $LOGFILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is...$R FAILED $N" | tee -a $LOGFILE
        exit 1
    else
        echo -e "$2 is... $G SUCCESS $N" | tee -a $LOGFILE
    fi
}

echo "Script started executing at: $(date)" | tee -a $LOGFILE
CHECK_ROOT

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disable default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enable nodejs:20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Install nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    echo -e "expense user not exists... $G Creating User $N"
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating Expense User"
else
    echo -e "Expence user already exists... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating /app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading bacckend application code"

cd /app
rm -rf /app/* #remove the existing code
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracting backend application code"
