#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER_ID=$(id -u)

if [ $USER_ID -ne 0 ]; then 
    echo "ERROR:: please run this script with root user"
    exit 1
fi 

LOGS_FOLDER="/var/log/shell-expense"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log
mysql_ip="mysql.tirusatrapu.fun"
SCRIPT_DIR=$PWD

START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER
echo "script started and exicuted:$(date)" | tee -a $LOG_FILE

VALIDATE(){
    if [ $1 -ne 0 ]; then 
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $R SUCCESS $N" | tee -a $LOG_FILE
    fi        
}

dnf module disable nodejs -y
VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "enable nodejs"

dnf install nodejs -y
VALIDATE $? "install nodejs"

id expense
if [ $? -ne 0 ]; then
    useradd expense
    VALIDATE $? "user add"
else
    echo -e "user already exits ..$Y SKIPPING $N"
fi 

mkdir /app
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? " download backend appilication"

cd /app
VALIDATE $? " move to app"

rm rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/backend.zip
VALIDATE $? "unzip the code"

npm install
VALIDATE $? " npm install"

cp $SCRIPT_DIR/$backend.serivce /etc/systemd/system/backend.service
VALIDATE $? " copy the backend service"

systemctl daemon-reload
systemctl enable backend
VALIDATE $? " enable backend"

dnf install mysql -y
VALIDATE $? "install mysql"

mysql -h $mysql_ip -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "connet to user"

systemctl restart backend
VALIDATE $? "restart backend"
