#!/bin/bash

USER_ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
START_TIME=$(date + %s)
LOGS_FOLDER="/var/log/shell-expense"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log

mkdir -p $LOGS_FOLDE
echo -e "script started and exicuted at:$(date)" | tee -a $LOG_FILE

if [ $USER_ID -ne 0 ]; then
    echo "ERROR:: please run this script with root user"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ...$R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ...$G SUCCESS $N" | tee -a $LOG_FILE
    fi 
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "install mysql"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enable mysqld"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "start mysqld"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
VALIDATE $? "set root password"

END_TIME=$(date +%s)
TOTAL_TIME=$(($START_TIME - $END_TIME))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"
