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

dnf module disable nodejs -y &>>LOG_FILE
VALIDATE $? "Disabling NODEJS"


dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATE $? "Enabling NODEJS"

dnf install nodejs -y &>>LOG_FILE
VALIDATE $? "Installing NODEJS"

id expense &>>LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "$Y NO SUCH USER $N"
    echo -e "$Y Creating USER $N"
    useradd expense &>>LOG_FILE
    VALIDATE $? "Created USER"
else
    echo -e " $Y User is already Created $N"
fi

mkdir -p /app
VALIDATE $? "Creating DIRECTORY"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading the code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip
VALIDATE $? "Extracting backend application code"

npm install &>>$LOG_FILE
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service


dnf install mysql -y | &>>$LOG_FILE
VALIDATE $? "Installing MYSQL CLIENT"

mysql -h mysql.deepakaws.online -uroot -pExpenseApp@1 < /app/schema/backend.sql | &>>$LOG_FILE
VALIDATE $? "Schema loading"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon reload"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enabled backend"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restarted Backend"