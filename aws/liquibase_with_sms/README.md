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