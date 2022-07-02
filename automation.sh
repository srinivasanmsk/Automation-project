#! /bin/bash

# Update the available packages
sudo apt update -y

#********************************************************************************
# Ensure that the apache2 server is installed or not. If not, install the package
#********************************************************************************
apt list *apache2 | grep -w "installed"  > /tmp/apache_installed.txt

count=$(grep -c "installed" /tmp/apache_installed.txt)

if [ $count -gt 0 ]
then
	echo "apache is installed"
else
	echo "apache not found!!!! Installing apache ..."
	sudo apt install apache2 -y
fi
#********************************************************************************

#********************************************************************************
# Enure that the Apache server is running. If not, start the server
#********************************************************************************

systemctl status apache2  > /tmp/apache_status.txt

count=$(grep -c "active (running)" /tmp/apache_status.txt)

if [ $count -gt 0 ]
then
	echo "Apache2 service not running. Starting the apache2 service"
	systemctl start apache2
else
	echo "Apache2 service already up and running"
fi
#********************************************************************************

#********************************************************************************
# Ensure that the apache2 service is enabled as a service. If not, enable the service
#********************************************************************************
sudo systemctl is-enabled apache2 > /tmp/apache2_system_status.txt

count=$(grep -c "enabled" /tmp/apache2_system_status.txt)

if [ $count -eq 0 ]
then
	echo "apache2 service is disabled!! hence, enabling the same"
	systemctl enable apache2
else
	echo "apache2 service is enabled already in init.d"
fi
#********************************************************************************

#********************************************************************************
# Archiving the Apache2 http logs and syncing to the S3 bucket
#********************************************************************************

name="srinivasan"
s3BucketName="upgrad-srinivasan"

# get the timestamp
time=$(date '+%d%m%Y-%H%M%S')

# Archive the http logs
tar -cvf /tmp/$name-httpd-logs-$time.tar -P /var/log/apache2/*.log

#Synchronize the logs to the S3 bucket
aws s3 cp /tmp/$name-httpd-logs-$time.tar s3://$s3BucketName/$name-httpd-logs-$time.tar

#***************** Scipt completed **************
