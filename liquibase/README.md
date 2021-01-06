https://www.liquibase.org/

# Notes

The following are the notes I took and thoughts I had when playing around with Liquibase. 

Important Thought: I had taken a stab at trying to propose that Liquibase be used in a manner similar to one I had used before (Development Practices below), but I believe there will be too many issues that I have not yet realized in doing so... Long story short, I advocate sticking with the proposed [Best Practices](https://docs.liquibase.com/concepts/bestpractices.html) file structure until you are confident/comfortable in your use of Liquibase. Long story short, be explicit about which changes are included, avoid using `<includeAll/>`.

## Best Practices when using Liquibase Best Practices Folder Structure

* Make a new minor version whenever an item has to be altered. Additions (Creates) can continue to be added to a specific minor version.
* If anything were to introduce a BREAKING CHANGE (e.g. item deletion), a new major version should be created. Note: changing the functionality of a sproc can be considered a breaking change, depending on how it is done. It may be better to CREATE a new sproc altogether, and have your application code reference that new sproc.

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

### VS Code Extension

```ps1
code --install-extension cweijan.vscode-mysql-client2
```

### MySQL on Docker

!! Note! Adding containers to network to aid in discovery (try doing this without networking containers, and/or lookup how to HTTP GET from one container to another)

Run MYSQL in Docker
```ps1
docker network create mynetwork
$rootPass="123456"
docker run --name=mysql1 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=$rootPass -d --network=mynetwork mysql/mysql-server:8.0
```

Setup MYSQL DB

!! Please note that there is no password being set

```ps1
docker exec -it mysql1 mysql -uroot -p
CREATE DATABASE liquibase;
CREATE USER mysqldeployer;
CREATE ROLE deployer;
GRANT alter,create,delete,drop,index,insert,select,update,trigger,alter routine,create routine, execute, create temporary tables on *.* to 'deployer';
GRANT 'deployer' TO 'mysqldeployer';
SET DEFAULT ROLE 'deployer' TO 'mysqldeployer';
```

### Docker

```ps1
$username="mysqldeployer"
$url="mysql1"
$database="liquibase"
$currentDirectory=(Get-Location).Path
# If you are seeing issues related to './changelog-master.xml' not found on Windows, make sure the drive is actually shared correctly with Docker.
# If all else fails, try using 'Reset credentials' on the Shared Drives page of the Docker for Windows settings dialog.
docker run --rm --network=mynetwork --mount type=bind,source=${currentDirectory},target=/liquibase/changelog,readonly liquibase/liquibase --url="jdbc:mysql://${url}/${database}" --driver=com.mysql.jdbc.Driver --changeLogFile=./changelog-master.xml --username=$username --logLevel=debug update
```

### Windows

Just run the installer... Will most likely have to create a container or machine image for eventual cloud deployments

## Thoughts on Development Practices

* Use a top level changelog file to include all files in a subfolder. 
  * This is to eliminate the need to pass in a different `--changeLogFile` upon every run.
  * As long as contributors follow best practices, and backwards/forwards compatibility, there should be no issues with this as there would never be a breaking change. Breaking changes would necessitate a slightly different strategy.
* !! Avoid having separate top level files for environment. Strive to have all environments utilize the same process (at least, as much as possible)
  * If items are specific to an environment, use [Contexts](https://docs.liquibase.com/concepts/advanced/contexts.html). Strive for a simplified environment approach: production and non-production. This should satisfy the need for non-production data that should never exist in production, and vice-versa. Arguably, test data generation can and should be accomplished by a different system. Using an external system would minimize, if not outright eliminate, the need for different environment Contexts.
* AVOID using [runOnChange](https://docs.liquibase.com/concepts/advanced/runonchange.html), and prefer creating a new version/file of the item you want to change.
  *  For example, `somesproc.sql`, `somesproc_0001.sql`, `somesproc_0002.sql`, etc. Each subsequent `somesproc_xxxx.sql` would contain ALTER statements. This mitigates problems caused by dropping and adding sprocs, etc.

### Folder Structure

```python for the highlighting that I want
.
.changelog.xml # The top level file that 
./changelogs
./changelogs/schema1 # DML should be divided by schema so as to promote
./changelogs/schema2 # discoverability and good schema design practices
./changelogs/schema2
./legacy-changelogs # changelogs generated from an import should live here
```

`.changelog.xml` should look like the following to insure legacy materials are ran first:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog xmlns="http://www.liquibase.org/xml/ns/dbchangelog" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.8.xsd">
    <includeAll  path="legacy-changelogs"/> 
    <includeAll  path="changelogs"/> 
</databaseChangeLog>
```

?? For items under schemas, should we use folders to define types, or prepend the type to the filename?

```python for the highlighting that I want
.
.changelog.xml # The top level file that 
./changelogs
./changelogs/schema1
./changelogs/schema1/tables
./changelogs/schema1/sprocs
```

**OR**

```python for the highlighting that I want
.
.changelog.xml # The top level file that 
./changelogs
./changelogs/schema1
./changelogs/schema1/table_sometable.sql
./changelogs/schema1/table_sometable2.sql
./changelogs/schema1/sproc_somesproc.sql
```

Going with the `folder structure` route so as to facilitate explicit ordering of how statements are executed. For example, it will make for an easier development experience if all User Defined Table Type changes are made before Sproc changes (generally, and if all changes being made are backwards/forwards compatible), as then if a Sproc depends on a UDTT, the UDTT will already exist when Liquibase executes.

### Schema Practices

* In general, schemas should be wholly contained within themselves
* No foreign key references across schemas
