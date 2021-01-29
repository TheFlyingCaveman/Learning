## Basic Premise

Use AWS Systems Manager Session Manager to pull a liquibase config from S3 and run it against a specified database within the VPC.

## Original Liquibase Experiments

https://github.com/JoshuaTheMiller/Experiments/tree/main/liquibase

## Commands

!! Requires aws cli
!! Requires [SSM Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

```sh
aws ssm start-session --target i-006554b3bb0e2a8ad
# one time setup
sudo amazon-linux-extras install java-openjdk11
sudo wget https://github.com/liquibase/liquibase/releases/download/v4.2.2/liquibase-4.2.2.tar.gz
sudo tar xvzf liquibase-4.2.2.tar.gz
# for current session
export PATH=$PATH:/usr/bin/liquibase

# download liquibase migration files
# unzip

url=""
database=""
username="from environment vars"
database="from environment vars"
liquibase --url="jdbc:mysql://$url/$database" --driver=com.mysql.jdbc.Driver --changeLogFile=./changelog-master.xml --username=$username --logLevel=debug update
```

## Controlling User Access

* https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-restrict-access.html

## Setting up MYSQL for PoC

* https://revdb.io/2020/09/25/terraform-rds-mysql-example/

## Commands after all is said and done

```sh
mysql --host "dbUrl" --user=user --password=hello_mysql
```

## MySQL Workbench over SSM

* https://stackoverflow.com/questions/18551556/permission-denied-publickey-when-ssh-access-to-amazon-ec2-instance

```sh
ssh ec2-user@i-0d04b204f2e718bf6 -L 9999:liquibasetests.cvnrx2p94j5x.us-east-1.rds.amazonaws.com:3306 -i ./what.pem
```

From MySQL Workbench, connect to localhost:9999 (user and password is included in database.tf) 