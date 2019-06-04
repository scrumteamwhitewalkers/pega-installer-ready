Installer Docker Image
=============
This project creates a docker image which, when run , kicks off either installation and upgrade.

# Build
There are two ways to build this project - either using Gradle or docker build. The build infrastructure uses bamboo because it ties in to the other platform jobs, but it is sometimes easier to build locally by invoking the Dockerfile directly.

1. Verify the prerequisites are present. You should see a build/archives/ folder in the relative root of this docker project. That root directory must contain the rules,archives,scripts folders.
   If prerequisites are not present then the below gradle buildImage command will pull the dependency from the meshbincam before starting to build the image.

2. Build this image using either docker or gradle:

 Gradle:

 `./gradlew -PincludeOnly=infrastructure/distribution/docker/images/installer/ buildImage`

 Docker (you may replace pega with the name you wish to give the resulting image):

 `docker build -t pega-installer .`

# Run
To run the docker image (note: if running from a local build, leave out meshbincam.pega.com:7000)

```bash
$ docker run meshbincam.pega.com:7000/platform/installer[:tags]
```

You can make adjustments by overiding environmental variables

```bash
$ docker run -e "RULES_SCHEMA=rules_schema" -e "DATA_SCHEMA=data_schema" meshbincam.pega.com:7000/platform/installer[:tags]
```

You can provide a directory containing a setupDatabase.properties and prlog4j2.xml file like so:

```bash
$ docker run -v /some/local/directory:/config meshbincam.pega.com:7000/platform/deploy:<build#>
```

## Docker Tags

When pulling the Docker image, you may optionally specify tags to specify which version and/or build of the image you want to use. The [:tags] portion of the above CLI pull commands may be replaced with any of the following.

1. `:latest` (or no tag specified) will return the latest good HEAD build. (ex. `platform/installer:latest or platform/installer`)
2. `:<build #>` will return the specified build from HEAD. (ex. `platform/installer:1234`)
3. `:version` will return the latest good build for the specified product version. (ex. `platform/installer:8.3`)
4. `:X-<build #>` will return the specified build from for the specified product version. (ex. `platform/installer:8.3-1234`)

## Actions

Type of actions supported by pega-installer image while this action must be passed as a environment variable during docker run.

1. `:install` performs pega-installation 

```bash
$ docker run -it -e ACTION="install" pega-installer
```

2. `:upgrade` performs pega-upgrade and since there are two types of pega-upgrade, the type of upgrade also has to be provided as an argument during run.

```bash
$ docker run -it -e ACTION="upgrade" -e UPGRADE_TYPE="in-place" pega-installer 
```

## Environmental variables

**Action Input for pega-installer**

| Name	             | Description  |
| ------------------ | ------------ |
| ACTION | Provide install or upgrade as an action to perform pega-installation or pega-upgrade respectively |
| UPGRADE_TYPE  | Required only during upgrade. Provide type of upgrade to be performed, i.e., "in-place" or "out-of-place" |

**JDBC Driver**

| Name	             | Description  |
| ------------------ | ------------ |
| JDBC_DRIVER_URI | Load Database driver on startup |

**Database Information**

| Name	             | Description  |
| ------------------ | ------------ |
| JDBC_URL | Constructs JDBC URL that will be used to connect to database |
| DB_TYPE  | Database Type |
| JDBC_CLASS | JDBC Class |	
| DB_USERNAME | Database username |
| DB_PASSWORD | Database password |

**Schema Related Information**
 
| Name	             | Description |
| ------------------ | ----------- |
| RULES_SCHEMA | Rules Schema name | 
| DATA_SCHEMA | Data Schema name |
| CUSTOMERDATA_SCHEMA |	Customer Data Schema name |

**System Related Information**

| Name	             | Description |
| ------------------ | ----------- | 
| SYSTEM_NAME | System name that uniquely identifies a single system |
| PRODUCTION_LEVEL | The system production level . Range is (1-5) |
| ADMIN_PASSWORD | Set the temporary password for administrator@pega.com |
| MT_SYSTEM	 | Multitenant system allows organizations to act as separate Pega Platform installations |

**Customizable Installation Parameters**

| Name               | Description |
| ------------------ | ----------- |
| BYPASS_UDF_GENERATION | UDF generation will be skipped if this property is set to true |
| BYPASS_PEGA_SCHEMA | Schema generation will be skipped if this property is set to true |
| ASSEMBLER | Run the Static Assembler if set to true |
| BYPASS_TRUNCATE_UPDATESCACHE | Bypass automatically truncating PR_SYS_UPDATESCACHE |
| JDBC_CUSTOM_CONNECTION | JDBC custom connection properties |

**Thread Level Parameters**

| Name               | Description |
| ------------------ | ----------- |
| MAX_IDLE | Maximum Idle Thread |
| MAX_WAIT | Maximum Wait Thread |
| MAX_ACTIVE | Maximum Active Thread |

**z/OS Related Information**
          
| Name              | Description |
| ----------------- | ----------- |
| ZOS_PROPERTIES | z/OS site specific properties file name |
| DB2_ZOS_UDF_WLM | Specify the workload manager to load UDFs into db2zos |

**Upgrade Related Properties**

| Name	             | Description |
| -------------------| ----------- |
| TARGET_RULES_SCHEMA | Target Rules Schema name | 
| TARGET_ZOS_PROPERTIES | The location of the db2zos site specific properties file. Only used if the target system is a db2zos database |
| MIGRATION_DB_LOAD_COMMIT_RATE | The commit count to use when loading database tables |
| UPDATE_EXISITING_APPLICATIONS | Update existing application will be run if this property is set to true |
| UPDATE_APPLICATIONS_SCHEMA | Runs the Update Applications Schema utility to update the cloned Rule, Data, Work and Work History tables with the schema changes in the latest base tables if this property is set to true |
| RUN_RULESET_CLEANUP | Generate and execute an SQL script to clean old rulesets and their rules from the system if this property is set to true |
| REBUILD_INDEXES | Rebuild Database Rules Indexes after Rules Load to improve Database Access Performance |
