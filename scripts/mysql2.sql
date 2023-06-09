#creating monitoring user for proxy sql
CREATE USER 'proxysql'@'%' IDENTIFIED WITH mysql_native_password by '$3Kr$t';

GRANT USAGE ON *.* TO 'proxysql'@'%';
FLUSH privileges;

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


