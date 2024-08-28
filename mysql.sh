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

echo "Script started executing at: $(date)" &>>LOGFILE | tee -a $LOGFILE
CHECK_ROOT

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MYSQL Server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabled MySQL Server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Started MySQL Server"

mysql -h backend.deepakaws.online -u root -pExpenseApp@1 -e 'show databases;' &>>LOGFILE
if [ $? -ne 0 ]
then
    echo "Mysql root password is not setup setting now..." &>>$LOGFILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting up root password".
else
    echo -e "MySQL root password is already setup...$Y Skip the step $N" | tee -a $LOGFILE
fi


