
#creating monitoring user for proxy sql
CREATE USER 'proxysql'@'%' IDENTIFIED WITH mysql_native_password by '$3Kr$t';

GRANT USAGE ON *.* TO 'proxysql'@'%';
FLUSH privileges;

USE sample;

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

