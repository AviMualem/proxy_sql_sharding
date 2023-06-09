# proxy sql hint based sharding

## routing library
This solution assumes that there is a routing library which can resolve a proper shard for a given tenant/user.

once a shard is being resolved,  a sharding hint will be added as a comment to every sql statment, and custom sharding rules will be apllied to the proxy so proper routing will be made.

## setting up the environment

### requiremnts
- docker/lima
- mysql client

### compose file 
the docker compose file includes proxy sql server and 2 mysql servers.
the servers are  isolated and dont know about the existence of the other.

in order to start the env
```
docker-compose up
```
# setting up proxysql
connecting to proxy sql
```
docker exec -it proxysql bash -c 'mysql -u admin -padmin -h 127.0.0.1 -P 6032'
```
configuring proxy sql:
```
#setting monitoring user
UPDATE global_variables SET variable_value='proxysql' WHERE variable_name='mysql-monitor_username';

UPDATE global_variables SET variable_value='$3Kr$t' WHERE variable_name='mysql-monitor_password';

#adding servers to different host groups based on shards
INSERT INTO mysql_servers(hostgroup_id,hostname,port,weight) VALUES (1,'mysql1',3306,1);

INSERT INTO mysql_servers(hostgroup_id,hostname,port,weight) VALUES (2,'mysql2',3306,1);

#adding mysql user
INSERT INTO mysql_users(username,password,default_hostgroup) VALUES ('mysqluser','mysqlpw',1);

#setting shard rule for shard1
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, destination_hostgroup,apply) VALUES(1, 1, 'exec_on_shard_1',1,1);

#setting shard rule for shard2
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, destination_hostgroup,apply) VALUES(2, 1, 'exec_on_shard_2',2,1);

update global_variables set variable_value='false' where variable_name='admin-hash_passwords';

#flushing changes
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







-------








