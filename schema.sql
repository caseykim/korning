-- DEFINE YOUR DATABASE SCHEMA HERE
DROP TABLE IF EXISTS employees,customers,products,orders;

CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  name varchar(100) UNIQUE NOT NULL,
  email varchar(100)
);

CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  account_name varchar(100) UNIQUE NOT NULL,
  account_no varchar(50) UNIQUE
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  product_name varchar(50) UNIQUE NOT NULL
);

CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  employee_id int REFERENCES employees,
  customer_id int REFERENCES customers,
  product_id int REFERENCES products,
  sale_date date,
  sale_amount money,
  units_sold int,
  invoice_no int,
  invoice_freq varchar(20)
);

CREATE UNIQUE INDEX orders_index on orders(customer_id, product_id, sale_date, invoice_no);
