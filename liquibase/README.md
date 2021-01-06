https://www.liquibase.org/

# Notes

The following are the notes I took and thoughts I had when playing around with Liquibase. 

## Best Practices

Liquibase does support to approaches to change:

* State-based
    * Typically my favorite
    * Good example is Terraform, you define what you want, Terraform determines how to get there.
* Migration based
    * Seems popular with database type changes
    * Recommended by Liquibase (https://www.liquibase.org/blog/liquibase-diffs)

From the shear popularity of migration based database deployments, I'm going to go forward with that. Prior experiences with managing database deployments was really just migration based masquerading as state-based (we would update the current state files in addition to creating the actual migration and rollback scripts).

## Setup

### MySQL on Docker

!! Note! Adding containers to network to aid in discovery (try doing this without networking containers, and/or lookup how to HTTP GET from one container to another)

Run MYSQL in Docker
```ps1
$rootPass="123456"
$database="BigCorp"
docker exec -it mysql1 mysql -uroot -p $rootPass
docker run --name=mysql1 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=$rootPass -d --network=mynetwork mysql/mysql-server:8.0
```

Setup MYSQL DB

!! Please note that there is no password being set

```ps1
docker exec -it mysql1 mysql -uroot -p
CREATE DATABASE BigCorp;
CREATE USER mysqldeployer;
CREATE ROLE deployer;
GRANT alter,create,delete,drop,index,insert,select,update,trigger,alter routine,create routine, execute, create temporary tables on BigCorp.* to 'deployer';
GRANT 'deployer' TO 'mysqldeployer';
SET DEFAULT ROLE 'deployer' TO 'mysqldeployer';
```

### Docker

```ps1
$username="mysqldeployer"
$url="mysql1"
$database="BigCorp"
$currentDirectory=(Get-Location).Path

docker run --rm --network=mynetwork -v "//f/Cloud Storage/SourceControl/Experiments/liquibase:/liquibase/changelog" liquibase/liquibase --url="jdbc:mysql://${url}/${database}" --driver=com.mysql.jdbc.Driver --changeLogFile=./dbchangelog.xml --username=$username --logLevel=debug update
```

### Windows

Just run the installer... Will most likely have to create a container or machine image for eventual cloud deployments