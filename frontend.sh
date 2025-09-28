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

SCRIPT_DIR=$PWD

START_TIME=$(date +%s)

mkdir -p $LOGS_FOLDER
echo "script started and exicuted:$(date)" | tee -a $LOG_FILE

VALIDATE(){
    if [ $1 -ne 0 ]; then 
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi        
}

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "install nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "remove the code"

curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "download the code"

cd /usr/share/nginx/html &>>$LOG_FILE
VALIDATE $? "move to folder"

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzip the code"

cp $SCRIPT_DIR/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE
VALIDATE $? "copy the exprnse"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "restart nginx"


END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"