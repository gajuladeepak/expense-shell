#!bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE="$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOG_FOLDER



USERID=$(id -u)

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$Y Provide root previleges $N" | tee -a $LOGFILE
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is ...... $R FAILURE $N" | tee -a $LOGFILE
    else
        echo -e "$2 is ...... $G SUCCCESS $N" | tee -a $LOGFILE    

    fi
}

CHECK_ROOT

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql-server"


systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enable MYSQL"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "START MYSQL"


mysql -h mysql.deepakaws.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    echo -e "NEED TO SETUP ROOT PASSWORD... $Y SETTING UP ROOT PASSWORD $N" &>>$LOGFILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting up root password"

else
    echo -e "Root Password Is Already Setup....$Y Skip the step $N" | tee -a $LOGFILE

fi
