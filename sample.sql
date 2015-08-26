#To find order details by employee name
SELECT * FROM orders WHERE employee_id=(SELECT id from employees WHERE employees.name='Bob Lob');
#To find order details by account name
SELECT * FROM orders WHERE customer_id=(SELECT id from customers WHERE account_name='Apple');
#To find order details by invoice frequency and account name 
SELECT*FROM orders WHERE invoice_freq='Monthly' AND customer_id=(SELECT id from customers WHERE account_name='Apple');
#How many monthly orders there are
SELECT count(*) FROM orders WHERE invoice_freq='Monthly';
