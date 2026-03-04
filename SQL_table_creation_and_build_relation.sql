CREATE DATABASE toy_store;

SELECT * FROM order_item_refunds;

SELECT * FROM order_items;

SELECT * FROM orders;

SELECT * FROM products; 

SELECT COUNT(*) FROM website_pageviews;

SELECT * FROM website_pageviews;

SELECT * FROM website_sessions;

SELECT COUNT(*) FROM website_sessions;

DESCRIBE orders;

ALTER TABLE orders MODIFY order_id INT;

ALTER TABLE orders MODIFY website_session_id INT;

ALTER TABLE orders MODIFY user_id INT;

ALTER TABLE orders MODIFY primary_product_id INT;

ALTER TABLE website_sessions MODIFY user_id INT;

ALTER TABLE order_item_refunds MODIFY order_item_refund_id INT;

ALTER TABLE order_item_refunds MODIFY order_item_id INT;

ALTER TABLE order_item_refunds MODIFY order_id INT;

ALTER TABLE order_items MODIFY order_item_id INT;

ALTER TABLE order_items MODIFY order_id INT;

ALTER TABLE order_items MODIFY product_id INT;

ALTER TABLE products MODIFY product_id INT;

ALTER TABLE website_pageviews MODIFY website_pageview_id INT;

ALTER TABLE website_pageviews MODIFY website_session_id INT;

ALTER TABLE website_sessions MODIFY website_session_id INT;

ALTER TABLE website_sessions MODIFY user_id INT;

ALTER TABLE orders ADD PRIMARY KEY (order_id);

ALTER TABLE order_item_refunds ADD PRIMARY KEY (order_item_refund_id);

ALTER TABLE products ADD PRIMARY KEY (product_id);

ALTER TABLE website_sessions ADD PRIMARY KEY (website_session_id);

ALTER TABLE website_pageviews ADD PRIMARY KEY (website_pageview_id);

ALTER TABLE orders
ADD CONSTRAINT fk_orders
FOREIGN KEY (website_session_id)
REFERENCES website_sessions(website_session_id);

ALTER TABLE orders
ADD CONSTRAINT fk_orders_product
FOREIGN KEY (primary_product_id)
REFERENCES products(product_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_products
FOREIGN KEY (product_id)
REFERENCES products(product_id);

ALTER TABLE order_item_refunds
ADD CONSTRAINT fk_refunds_order_items
FOREIGN KEY (order_item_id)
REFERENCES order_items(order_item_id);

ALTER TABLE order_item_refunds
ADD CONSTRAINT fk_refunds_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE website_pageviews
ADD CONSTRAINT fk_pageviews_sessions
FOREIGN KEY (website_session_id)
REFERENCES website_sessions(website_session_id);

ALTER TABLE orders
MODIFY order_date DATE;

ALTER TABLE order_items
MODIFY date DATE;

ALTER TABLE products
MODIFY date DATE;

ALTER TABLE website_sessions
MODIFY date DATE;

ALTER TABLE website_pageviews
MODIFY date DATE;

ALTER TABLE order_item_refunds
MODIFY refund_date DATE;

ALTER TABLE orders 
ADD COLUMN new_order_date DATE;

UPDATE orders
SET new_order_date = STR_TO_DATE(order_date, '%d-%m-%Y');

ALTER TABLE orders
DROP COLUMN order_date;

ALTER TABLE orders
CHANGE new_order_date order_date DATE;

ALTER TABLE order_items ADD COLUMN new_date DATE;

UPDATE order_items
SET new_date = STR_TO_DATE(date, '%d-%m-%Y');

ALTER TABLE order_items DROP COLUMN date;

ALTER TABLE order_items
CHANGE new_date date DATE;

ALTER TABLE products ADD COLUMN new_date DATE;

UPDATE products
SET new_date = STR_TO_DATE(date, '%d-%m-%Y');

ALTER TABLE products DROP COLUMN date;

ALTER TABLE products
CHANGE new_date date DATE;

ALTER TABLE website_sessions ADD COLUMN new_date DATE;

UPDATE website_sessions
SET new_date = STR_TO_DATE(date, '%d-%m-%Y');

ALTER TABLE website_sessions DROP COLUMN date;

ALTER TABLE website_sessions
CHANGE new_date date DATE;

ALTER TABLE website_pageviews ADD COLUMN new_date DATE;

UPDATE website_pageviews
SET new_date = STR_TO_DATE(date, '%d-%m-%Y');

ALTER TABLE website_pageviews DROP COLUMN date;

ALTER TABLE website_pageviews
CHANGE new_date date DATE;

ALTER TABLE order_item_refunds ADD COLUMN new_refund_date DATE;

UPDATE order_item_refunds
SET new_refund_date = STR_TO_DATE(refund_date, '%d-%m-%Y');

ALTER TABLE order_item_refunds DROP COLUMN refund_date;

ALTER TABLE order_item_refunds
CHANGE new_refund_date refund_date DATE;