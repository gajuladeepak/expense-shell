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

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enable Nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Start Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing default website"



curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOGFILE

VALIDATE $? "Extract frontend code"

cp /home/ec2-user/expence-shell/expence.conf /etc/nginx/default.d/expense.conf
systemctl restart nginx
