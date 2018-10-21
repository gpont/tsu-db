# TSU Databases labs
Tomsk State University, Faculty of Applied Mathematics and Cybernetics, 3 year, 1 semester, Databases

## Repository structure

```
├── books        - Literature
├── src          - Laboratory works
├── schemas      - Databases schemas
├── startup      - Initial scripts (database fixtures)
├── tasks.md     - Tasks list
├── .gitignore
└── README.md
```

## Installing and usage OracleDB with Docker

### Building image
```shell
git clone git://github.com/oracle/docker-images.git
cd docker-images/OracleDatabase
cp path_to_database/linuxx64_12201_database.zip ./12.2.0.1/linuxx64_12201_database.zip
./buildDockerImage.sh -v 12.2.0.1 -e
```

### First running container
```shell
mkdir oradata
chmod a+w oradata
docker run --name oracle-ee -p 1521:1521 --shm-size 4GB -v ./startup:/opt/oracle/scripts/startup -v ./oradata:/opt/oracle/oradata oracle/database:12.2.0.1-ee
```

### Default username/password
```
pdbadmin/
```

### Starting container
```shell
docker start oracle-ee
```

### Stopping container
```shell
docker stop oracle-ee
```

### Resetting the Database Admin Account Passwords
```shell
docker exec oracle-ee ./setPassword.sh my_password
```

### Run `sqlplus` from the same container already running the database
```shell
docker exec -ti oracle-ee sqlplus pdbadmin@ORCLPDB1
```

## Usefull tools for developing

1. `./tools/dictgen.sh` - generate dictionary for autocomplete in sqlplus
2. `rlwrap -if path_to_proj/tools/sqlplus.dict -pgreen sqlplus user/pass@server` - enable autocomplete and coloring

# Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

# License
[MIT](./LICENSE)
