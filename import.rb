# Use this file to import the sales information into the
# the database.
require 'csv'
require "pg"

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  rescue PG::UniqueViolation
  ensure
    connection.close
  end
end

class Sales
  attr_reader :employee_info, :customer_info, :product_name,
    :sale_date, :sale_amount, :units_sold, :invoice_no, :invoice_freq
  def initialize(hash)
    @employee_info = hash[:employee]
    @customer_info = hash[:customer_and_account_no]
    @product_name = hash[:product_name]
    @sale_date = hash[:sale_date]
    @sale_amount = hash[:sale_amount]
    @units_sold = hash[:units_sold]
    @invoice_no = hash[:invoice_no]
    @invoice_freq = hash[:invoice_frequency]
  end
end

def info_split(str)
  arr = str.split(" (")
  name = arr[0]
  etc = arr[1].chomp(")")
  return name,etc
end

# db_connection do |conn|
#   conn.exec("DELETE FROM orders")
#   conn.exec("DELETE FROM employees")
#   conn.exec("DELETE FROM customers")
#   conn.exec("DELETE FROM products")
# end

db_connection do |conn|
  CSV.foreach('sales.csv', headers: true, header_converters: :symbol) do |row|
    sales = Sales.new(row.to_hash)

    name,email = info_split(sales.employee_info)
    account_name,account_no = info_split(sales.customer_info)
    #Add employees to table "employees"
    if conn.exec_params("SELECT name FROM employees WHERE name=$1",[name]).to_a.empty?
      conn.exec_params("INSERT INTO employees (name, email) VALUES ($1,$2)",[name, email])
    end
    #Add customers to table "customers"
    if conn.exec_params("SELECT account_name FROM customers WHERE account_name=$1",[account_name]).to_a.empty?
      conn.exec_params("INSERT INTO customers (account_name, account_no) VALUES ($1,$2)",[account_name, account_no])
    end
    #Add products to table "products"
    if conn.exec_params("SELECT product_name FROM products WHERE product_name=$1",[sales.product_name]).to_a.empty?
      conn.exec_params("INSERT INTO products (product_name) VALUES ($1)",[sales.product_name])
    end

    #Add orders..
    employee_id = conn.exec("SELECT id FROM employees WHERE name=$1",[name]).to_a[0]["id"]
    customer_id = conn.exec("SELECT id FROM customers WHERE account_name=$1",[account_name]).to_a[0]["id"]
    product_id = conn.exec("SELECT id FROM products WHERE product_name=$1",[sales.product_name]).to_a[0]["id"]
    sql = "INSERT INTO orders (employee_id, customer_id, product_id, sale_date, sale_amount, units_sold, invoice_no, invoice_freq) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)"
    input_arr = [employee_id,customer_id,product_id,sales.sale_date,sales.sale_amount,sales.units_sold,sales.invoice_no,sales.invoice_freq]
    conn.exec_params(sql,input_arr)

  end
end
