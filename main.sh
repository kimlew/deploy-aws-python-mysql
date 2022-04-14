#! /usr/bin/env bash

# Script name: main.sh

# Description: This script runs all the other scripts required to set up the
# machine with MySQL and other programs, so the Python Flask app,
# Create Jazz Lyric, can run on AWS.

# Author: Kim Lew

hide_mid_chars() {
  PASSWD="$1"
  LEN="${#PASSWD}"
  FIRST="${PASSWD:0:1}"
  MID="${PASSWD:1:$((LEN-2))}"
  LAST="${PASSWD:$((LEN-1)):1}"
  STARS="${MID//?/*}"
  echo -n "Password is: ${FIRST}${STARS}${LAST}"
  echo
}
# Prompt user for root MySQL password.
# read - to read the database password typed by user
# -s option for silent mode, so passwords not echo-ed to terminal/chars not shown
# Note: Will verify password according to MySQL password policies in setup_mysql.sh.
read -rsep "Type a root password for MySQL: " PASSWORD_ROOT
echo
read -rsep "Re-type the root password for MySQL: " PASSWORD_CONFIRMED
echo
echo

hide_mid_chars "${PASSWORD_ROOT}"
if [ ! "${PASSWORD_ROOT}" = "${PASSWORD_CONFIRMED}" ]; then
  echo "Passwords entered do NOT match."
  echo -n "Confirmed "
  hide_mid_chars "${PASSWORD_CONFIRMED}"
  echo "Re-run main.sh."
  exit 1
fi

# Prompt user for PEM_KEY and IP_ADDR. Then read in the variables.
read -resp "Type the full path to the .pem key: " PEM_KEY
echo
read -rep "Type the IP address: " IP_ADDR
echo
echo "Setting up Create Jazz Lyric..."
echo

# These 2 commands are all run on your local computer.
chmod u+x copy_req_files_to_aws.sh
./copy_req_files_to_aws.sh "${PEM_KEY}" "${IP_ADDR}"

# These commands use ssh to run in a shell on Deployment Machine, e.g. AWS.
# TEST ssh with, e.g., ssh -i <full path>/key.pem ec2-user@34.213.67.66

ssh -i "${PEM_KEY}" ec2-user@"${IP_ADDR}" -- chmod u+x setup_mysql.sh
ssh -i "${PEM_KEY}" ec2-user@"${IP_ADDR}" -- cat \> mysql_pw.txt < <(echo "$PASSWORD_ROOT")  # bash named pipe, man process substitution redirection?
ssh -i "${PEM_KEY}" ec2-user@"${IP_ADDR}" -- ./setup_mysql.sh
ssh -i "${PEM_KEY}" ec2-user@"${IP_ADDR}" -- ./setup_machine.sh

# Note: These next 2 lines in this 1 command must be run on AWS, but within this
# script, you are NOT on AWS. So, ssh to AWS & change into the subdirectory,
# pythonapp-createjazzlyric, to run the app.
ssh -i "${PEM_KEY}" ec2-user@"${IP_ADDR}" -- cd /home/ec2-user/pythonapp-createjazzlyric \&\& pipenv run flask run

# In a Browser Tab: See the running app at the IP address, e.g., https://54.190.12.61/
