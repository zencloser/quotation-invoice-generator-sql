-- ========================================
-- Quotation and Invoice Generator Project
-- Developed by [Your Name]
-- SQL-Only Internship Assignment (DevifyX)
-- ========================================

-- 1. Create the database
CREATE DATABASE IF NOT EXISTS quotation_db;
USE quotation_db;

-- 2. Create clients table
CREATE TABLE clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT
);

-- 3. Create products table
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    price DECIMAL(10, 2)
);

-- 4. Create quotations table
CREATE TABLE quotations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT,
    date DATE,
    status VARCHAR(50),
    discount_type VARCHAR(10), -- PERCENT or FIXED
    discount_value DECIMAL(10, 2),
    FOREIGN KEY (client_id) REFERENCES clients(id)
);

-- 5. Create quotation_items table
CREATE TABLE quotation_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quotation_id INT,
    product_id INT,
    quantity INT,
    tax_rate DECIMAL(5, 2),
    price DECIMAL(10, 2),
    FOREIGN KEY (quotation_id) REFERENCES quotations(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 6. Create invoices table
CREATE TABLE invoices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quotation_id INT,
    invoice_number VARCHAR(50),
    date DATE,
    status VARCHAR(50),
    FOREIGN KEY (quotation_id) REFERENCES quotations(id)
);

-- 7. Create audit_logs table
CREATE TABLE audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    action_type VARCHAR(50),
    entity VARCHAR(50),
    entity_id INT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- 8. Insert sample clients
INSERT INTO clients (name, email, phone, address)
VALUES 
('Aditi Sharma', 'aditi@gmail.com', '9876543210', 'Delhi, India'),
('Rohan Mehta', 'rohan@yahoo.com', '8765432109', 'Mumbai, India'),
('Sneha Verma', 'sneha@outlook.com', '9123456789', 'Pune, India');

-- 9. Insert sample products
INSERT INTO products (name, description, price)
VALUES 
('Web Hosting', '1 Year Hosting Plan with SSL', 4999.00),
('SEO Service', 'SEO Optimization for businesses', 7999.00),
('E-Commerce Website', 'Responsive site with payment gateway', 25000.00);

-- 10. Insert sample quotation
INSERT INTO quotations (client_id, date, status, discount_type, discount_value)
VALUES (1, '2025-06-18', 'Draft', 'PERCENT', 10.00);

-- 11. Insert quotation items
INSERT INTO quotation_items (quotation_id, product_id, quantity, tax_rate, price)
VALUES 
(1, 1, 1, 18.00, 4999.00),
(1, 2, 1, 18.00, 7999.00);

-- 12. Insert sample invoice
INSERT INTO invoices (quotation_id, invoice_number, date, status)
VALUES (1, 'INV2025001', '2025-06-19', 'Unpaid');

-- 13. Insert a sample audit log (manual)
INSERT INTO audit_logs (action_type, entity, entity_id, notes)
VALUES ('APPROVE', 'quotation', 1, 'Quotation approved by Admin.');

-- 14. Triggers

DELIMITER $$

-- Trigger: After Invoice Creation
CREATE TRIGGER after_invoice_insert
AFTER INSERT ON invoices
FOR EACH ROW
BEGIN
  INSERT INTO audit_logs (action_type, entity, entity_id, notes)
  VALUES ('CREATE', 'invoice', NEW.id, CONCAT('Invoice ', NEW.invoice_number, ' created.'));
END $$

-- Trigger: After Quotation Creation
CREATE TRIGGER after_quotation_insert
AFTER INSERT ON quotations
FOR EACH ROW
BEGIN
  INSERT INTO audit_logs (action_type, entity, entity_id, notes)
  VALUES ('CREATE', 'quotation', NEW.id, CONCAT('Quotation created for client ID ', NEW.client_id));
END $$

-- Trigger: When Quotation is Approved
CREATE TRIGGER after_quotation_approval
AFTER UPDATE ON quotations
FOR EACH ROW
BEGIN
  IF NEW.status = 'Approved' AND OLD.status <> 'Approved' THEN
    INSERT INTO audit_logs (action_type, entity, entity_id, notes)
    VALUES ('APPROVE', 'quotation', NEW.id, 'Quotation approved.');
  END IF;
END $$

-- Trigger: When Invoice is Paid
CREATE TRIGGER after_invoice_paid
AFTER UPDATE ON invoices
FOR EACH ROW
BEGIN
  IF NEW.status = 'Paid' AND OLD.status <> 'Paid' THEN
    INSERT INTO audit_logs (action_type, entity, entity_id, notes)
    VALUES ('PAY', 'invoice', NEW.id, 'Invoice marked as Paid.');
  END IF;
END $$

DELIMITER ;

-- 15. Sample Queries for Evaluation

-- View all clients
SELECT * FROM clients;

-- View all products
SELECT * FROM products;

-- View all quotations with status
SELECT * FROM quotations;

-- View quotation items for quotation 1
SELECT * FROM quotation_items WHERE quotation_id = 1;

-- View all invoices
SELECT * FROM invoices;

-- View audit log
SELECT * FROM audit_logs;

-- Done 