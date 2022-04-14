#! /usr/bin/env bash

# Script name: copy_req_files_to_aws.sh

# Description: This script is called in main.sh and is run BEFORE setup_mysql.sh
# & setup_machine.sh are run. This script transfers those 2 setup files, plus
# the project files & folders for the create-jazz-lyric Python Flask web app,
# to the deployment machine.

# Author: Kim Lew

# Note: The .pem key is required by AWS, plus is needed to use SSH.
# Read in IP address, which is passed in from main.sh in the line that calls this script.

PEM_KEY=$1
IP_ADDR=$2
echo
echo "COPYING files from local to AWS..."
echo

# -- Copy files needed at root directory on AWS with .pem key ------------------
SRC_REQ_FILES_DIR='/Users/kimlew/code/aws-ec2-createjazz/'  # On Mac.
SRC_PROJ_DIR='/Users/kimlew/code/aws-ec2-createjazz/pythonapp-createjazzlyric/'  # On Mac.

# Paths for destinations for a. root directory b. project directory.
DEST_ON_AWS='/home/ec2-user/'  # Deployment machine root directory.
DEST_PROJ_DIR='/home/ec2-user/pythonapp-createjazzlyric/'  # On deployment machine.

# Create pythonapp-createjazzlyric on AWS & scp these files & folders to AWS.
# files:   conn_vars_dict.py, create_mysql_db.sql, create_jazz_lyric.py
# folders: static & all files & templates & all files
# CAN CHECK: Files were copied to AWS manually with ssh & ls.
# Note: aws cli list command ONLY lists things ABOUT the instance, NOT about the files ON instance.

scp -i "${PEM_KEY}" "${SRC_REQ_FILES_DIR}"setup_mysql.sh ec2-user@"${IP_ADDR}":"${DEST_ON_AWS}"setup_mysql.sh
scp -i "${PEM_KEY}" "${SRC_REQ_FILES_DIR}"setup_machine.sh ec2-user@"${IP_ADDR}":"${DEST_ON_AWS}"setup_machine.sh

# --- Copy project files & folders for app, pythonapp-createjazzlyric ---
# Note: scp -r recursively copies entire directory, pythonapp-createjazzlyric
scp -i "${PEM_KEY}" -r "${SRC_PROJ_DIR}" ec2-user@"${IP_ADDR}":"${DEST_PROJ_DIR}"

# Check for when had to mkdir pythonapp-createjazzlyric ...
# if ! ssh -n -i "${PEM_KEY}" ec2-user@"${IP_ADDR}" -- \[ -d "$(basename "${SRC_REQ_FILES_DIR}")" \]; then
#   echo "Failed to create expected directory $(basename "${SRC_REQ_FILES_DIR}")"
#   exit 1
# fi
