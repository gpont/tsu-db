# Tomsk State University, Faculty of Applied Mathematics and Cybernetics, 3 year, Databases

## Repository structure

```
├── books        - Literature
├── src          - Laboratory works
├── schemas      - Databases shemas
├── startup      - Initial scripts (database fixtures)
├── tasks.md     - Tasks list
├── .gitignore
└── README.md
```

## Installing and usage OracleDB with Docker

### Building image
```
git clone git://github.com/oracle/docker-images.git
cd docker-images/OracleDatabase
cp path_to_database/linuxx64_12201_database.zip .
cd ..
./buildDockerImage.sh -v 12.2.0.1 -e
```

### First running container
```
mkdir oradata
chmod a+w oradata
docker run --name oracle-ee -p 1521:1521 -v ./startup:/opt/oracle/scripts/startup -v ./oradata:/opt/oracle/oradata oracle/database:12.2.0.1-ee
```

### Default username/password
```
pdbadmin/
```

### Starting container
```
docker start oracle-ee
```

### Stopping container
```
docker stop oracle-ee
```

### Resetting the Database Admin Account Passwords
```
docker exec oracle-ee ./setPassword.sh my_password
```

### Run `sqlplus` from the same container already running the database
```
docker exec -ti oracle-ee sqlplus pdbadmin@ORCLPDB1
```
