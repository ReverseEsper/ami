#!/bin/bash
set -x

############################################################
## GLOBAL SETTINGS #########################################
############################################################

echo "LANG=en_US.utf-8" | sudo tee --append /etc/environment
echo "LC_ALL=en_US.utf-8" | sudo tee --append /etc/environment

echo "* hard nofile 65536" | sudo tee --append /etc/security/limits.conf
echo "* soft nofile 65536" | sudo tee --append /etc/security/limits.conf

echo "session required pam_limits.so" | sudo tee --append /etc/pam.d/login

############################################################
## INSTALL ADDITIONAL SOFTWARE #############################
############################################################

sudo yum install -y amazon-efs-utils aws-cli htop jq telnet wget

# Create directory
sudo mkdir -p /opt/jars/ && sudo chmod -R 775 /opt/jars/

# Download Amazon Redshift JDBC driver
sudo wget --no-verbose https://s3.amazonaws.com/redshift-downloads/drivers/jdbc/2.1.0.4/redshift-jdbc42-2.1.0.4.jar -P /opt/jars/

# Download additional jar files
sudo aws s3 cp s3://$env-emr-dw-stst/jars/ /opt/jars/ --recursive

############################################################
## INSTALL PYTHON PACKAGAES ################################
############################################################

# sudo pip3 install -r /tmp/config/requirements.txt

############################################################
## COPY SCRIPTS AND SETUP CRON JOBS ########################
############################################################

sudo chown -R root:root /tmp/scripts
sudo chmod -R +x /tmp/scripts/
sudo cp -rf /tmp/scripts/ /usr/local/bin/

echo "0 * * * * root /usr/local/bin/purge_users_yarn_cache.sh /mnt/yarn/usercache/ 85 2&>1 >> /var/log/purge_users_yarn_cache.log" | sudo tee --append /etc/crontab

# Cleanup
sudo rm -rf /tmp/*
