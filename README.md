# proxy sql hint based sharding

## routing library
This solution assumes that there is a routing library which can resolve a proper shard for a given tenant/user.

once a shard is being resolved,  a sharding hint will be added as a comment to every sql statment, and custom sharding rules will be apllied to the proxy so proper routing will be made.

## setting up the environment
the docker compose file includes proxy sql server and 2 mysql servers.
the servers are  isolated and dont know about the existence of the other.

in order to start the env
```
docker-compose up
```

## setting up a schema
The sql databases will have a pre made schema name "sample"

the following sql code needs to be executed on mysql 1
```sql
CREATE TABLE products (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(512),
  tenant VARCHAR(512)
);
ALTER TABLE products AUTO_INCREMENT = 101;

INSERT INTO products
VALUES (default,"scooter","Small 2-wheel scooter",'ace5d454-5aca-4ea7-8620-21f1cf0c5f8f'),
       (default,"car battery","12V car battery",'ace5d454-5aca-4ea7-8620-21f1cf0c5f8f'),
       (default,"12-pack drill bits","12-pack of drill bits with sizes ranging from #40 to #3",'ace5d454-5aca-4ea7-8620-21f1cf0c5f8f')


#creating monitoring user for proxy sql
CREATE USER 'proxysql'@'%' IDENTIFIED WITH mysql_native_password by '$3Kr$t';

GRANT USAGE ON *.* TO 'proxysql'@'%';
FLUSH privileges;

```

the following sql code needs to be executed on mysql 2
```sql
# Switch to this database
USE sample;

# Create and populate our products using a single insert with many rows
CREATE TABLE products (
  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(512),
  tenant VARCHAR(512)
);
ALTER TABLE products AUTO_INCREMENT = 201;

  INSERT INTO products
  VALUES (default,"bike","just a bike",'fca30520-c932-4d33-b028-968d00cc5eb0'),
         (default,"pc","nice pc",'fca30520-c932-4d33-b028-968d00cc5eb0'),
         (default,"table","table",'fca30520-c932-4d33-b028-968d00cc5eb0')

#creating monitoring user for proxy sql
CREATE USER 'proxysql'@'%' IDENTIFIED WITH mysql_native_password by '$3Kr$t';

GRANT USAGE ON *.* TO 'proxysql'@'%';
FLUSH privileges;
```

# setting up proxysql
```
UPDATE global_variables SET variable_value='proxysql' WHERE variable_name='mysql-monitor_username';

UPDATE global_variables SET variable_value='$3Kr$t' WHERE variable_name='mysql-monitor_password';

INSERT INTO mysql_servers(hostgroup_id,hostname,port,weight) VALUES (1,'mysql1',3306,1);

INSERT INTO mysql_servers(hostgroup_id,hostname,port,weight) VALUES (2,'mysql2',3306,1);

INSERT INTO mysql_users(username,password,default_hostgroup) VALUES ('mysqluser','mysqlpw',1);

INSERT INTO mysql_query_rules (rule_id, active, match_pattern, destination_hostgroup,apply) VALUES(1, 1, 'exec_on_shard_1',1,1);

INSERT INTO mysql_query_rules (rule_id, active, match_pattern, destination_hostgroup,apply) VALUES(2, 1, 'exec_on_shard_2',2,1);

update global_variables set variable_value='false' where variable_name='admin-hash_passwords';

LOAD MYSQL QUERY RULES TO RUNTIME;
load admin variables to runtime; 
save admin variables to disk;
load mysql users to runtime;
save mysql users to disk;
LOAD MYSQL SERVERS TO RUNTIME;
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;   
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;
```

## checking topology
its highly important to use the -c on the mysql client so comments wont be ignored.

mysql -c -h 127.0.0.1 -P 6033 -u mysqluser -pmysqlpw -e 'select /* exec_on_shard_1 */ * from sample.products;'

mysql -c -h 127.0.0.1 -P 6033 -u mysqluser -pmysqlpw -e 'select /* exec_on_shard_2 */ * from sample.products;'














