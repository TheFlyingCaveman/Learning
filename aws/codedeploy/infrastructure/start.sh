#!/bin/bash
exec > /tmp/init.log 2>&1

sudo yum update -y
sudo yum install -y ruby
# Found error in init.log since folder didn't exist. Woops
mkdir $HOME/ec2-user
cd $HOME/ec2-user
curl -O https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto

sudo rm /var/www/html/index.html -f

# Found error in init.log since folder didn't exist
sudo mkdir /var/www/html/ -p
sudo echo '<!DOCTYPE html><html><body><h1>Hello! Welcome to the start page.</h1></body></html>' >> /var/www/html/index.html

sudo yum install -y httpd
sudo service httpd start