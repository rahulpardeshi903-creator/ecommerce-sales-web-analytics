-- Q1. What is the total revenue generated?

SELECT SUM(o.price_usd) - IFNULL(SUM(oir.refund_amount_usd),0) AS total_revenue
FROM orders o
LEFT JOIN order_item_refunds oir
ON o.order_id = oir.order_id;

-- Q2. What is the monthly revenue trend?

SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
	   SUM(o.price_usd) AS monthly_revenue
FROM orders o
LEFT JOIN order_item_refunds oir
ON o.order_id = oir.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m');

SELECT order_month,
	   monthly_revenue,
	   SUM(monthly_revenue) OVER(ORDER BY order_month) AS running_revenue
FROM (SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
	   ROUND(SUM(o.price_usd),2) AS monthly_revenue
FROM orders o
LEFT JOIN order_item_refunds oir
ON o.order_id = oir.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')) AS t;

-- Q3. What is the total number of orders and total items sold?

SELECT COUNT(*) AS total_orders, 
	   SUM(items_purchased) AS total_item_sold 
FROM orders;

-- Q4. What is the average order value (AOV)?

SELECT ROUND(SUM(o.price_usd) / COUNT(*),2) AS avg_order_value
FROM orders o
LEFT JOIN order_item_refunds oir
ON o.order_id = oir.order_id;

-- Q5. Which are the top 10 products by revenue?

SELECT product_id,
	   total_revenue
FROM (
		SELECT product_id,
			   ROUND(SUM(price_usd),2) AS total_revenue,
			   DENSE_RANK() OVER(PARTITION BY product_id ORDER BY SUM(price_usd) DESC) AS rnk
		FROM order_items
		GROUP BY product_id
	) AS t
WHERE rnk <= 10;

-- Q6 What is the overall refund rate?

SELECT CONCAT(ROUND((COUNT(DISTINCT order_id) / 
	   (SELECT COUNT(*) FROM orders)) * 100,2),'%') AS order_refund_rate
FROM order_item_refunds;

SELECT CONCAT(ROUND((SUM(refund_amount_usd) / 
	   (SELECT SUM(price_usd) FROM orders)) * 100,2),'%') AS revenue_refund_rate
FROM order_item_refunds;

-- Q7. What is the monthly profit trend?

SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month,
	   ROUND(SUM(price_usd - cogs_usd),2) AS monthly_profit
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;

WITH refund_amount AS(
			SELECT order_id, 
				   SUM(refund_amount_usd) AS total_refund_amount
			FROM order_item_refunds
            GROUP BY order_id)
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
	   ROUND(SUM(o.price_usd - IFNULL(r.total_refund_amount,0) - o.cogs_usd),2) AS monthly_profit
FROM orders o
LEFT JOIN refund_amount r
ON o.order_id = r.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;

-- Q8 Which product has the highest profit margin?

WITH highest_profit_margin AS(
			SELECT p.product_name,
				   ROUND(SUM(oi.price_usd - oi.cogs_usd),2) AS total_profit_per_product,
				   CONCAT(ROUND((SUM(oi.price_usd - oi.cogs_usd) / SUM(oi.price_usd)) * 100,2),'%') AS profit_margin_per_product,
                   DENSE_RANK() OVER(ORDER BY ROUND((SUM(oi.price_usd - oi.cogs_usd) / SUM(oi.price_usd)) * 100,2) DESC) AS rnk
			FROM products p
			JOIN order_items oi
			ON p.product_id = oi.product_id
			GROUP BY p.product_name)
SELECT product_name, total_profit_per_product,
	   profit_margin_per_product
FROM highest_profit_margin
WHERE rnk = 1;

-- Q9. Which traffic source (utm_source) generates the highest revenue?

SELECT utm_source,
	   total_revenue
FROM (
		SELECT ws.utm_source,
			   ROUND(SUM(o.price_usd),2) AS total_revenue,
			   DENSE_RANK() OVER(ORDER BY SUM(o.price_usd) DESC) AS rnk
		FROM website_sessions ws
		JOIN orders o
        ON ws.website_session_id = o.website_session_id
		GROUP BY ws.utm_source
	) AS t
WHERE rnk = 1;

-- Q10. What is the conversion rate?

SELECT ws.utm_source,
       COUNT(DISTINCT o.order_id) AS total_orders,
	   COUNT(DISTINCT ws.website_session_id) AS total_sessions,
       ROUND(COUNT(DISTINCT o.order_id) /
             COUNT(DISTINCT ws.website_session_id) * 100,2) AS conversion_rate_percent
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id = o.website_session_id
GROUP BY ws.utm_source
ORDER BY conversion_rate_percent DESC;

-- Q11. New vs Repeat Customer Revenue

SELECT ws.is_repeat_session,
	   ROUND(SUM(o.price_usd),2) AS total_revenue,
       COUNT(DISTINCT o.order_id) AS total_orders
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id = o.website_session_id
GROUP BY ws.is_repeat_session;

-- Q12. Revenue by Device Type

SELECT ws.device_type,
	   ROUND(SUM(o.price_usd),2) AS total_revenue_by
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id = o.website_session_id
GROUP BY ws.device_type; 

-- Q13. Best Marketing Campaign

SELECT ws.utm_campaign,
	   ROUND(SUM(o.price_usd),2) AS total_revenue_by_campaign
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id = o.website_session_id
GROUP BY ws.utm_campaign
ORDER BY total_revenue_by_campaign DESC;

-- Q14. Customer Lifetime Value (LTV)

SELECT user_id,
	   ROUND(SUM(price_usd),2) AS lifetime_value
FROM orders 
GROUP BY user_id
ORDER BY lifetime_value DESC;

-- Q15. Cohort Analysis (Customer Retention Base)

WITH first_purchase AS 
	(
		SELECT user_id,
			   MIN(order_date) AS first_order_date
		FROM orders
		GROUP BY user_id
	)
SELECT DATE_FORMAT(f.first_order_date,'%Y-%m') AS cohort_month,
       DATE_FORMAT(o.order_date,'%Y-%m') AS order_month,
       COUNT(DISTINCT o.user_id) AS customers
FROM orders o
JOIN first_purchase f
ON o.user_id = f.user_id
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month;

-- Q16. Funnel Analysis

SELECT COUNT(DISTINCT ws.website_session_id) AS sessions,
       COUNT(DISTINCT wp.website_pageview_id) AS pageviews,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(o.price_usd),2) AS revenue
FROM website_sessions ws
LEFT JOIN website_pageviews wp
ON ws.website_session_id = wp.website_session_id
LEFT JOIN orders o
ON ws.website_session_id = o.website_session_id;

-- Q17. Repeat Purchase Rate

SELECT ROUND(COUNT(*) / (SELECT COUNT(DISTINCT user_id) FROM orders) * 100,2) AS repeat_purchase_rate
FROM (
		SELECT user_id
		FROM orders
		GROUP BY user_id
		HAVING COUNT(order_id) > 1
	 ) t;
     
-- Q18. Revenue Lost Due to Refunds

SELECT ROUND(SUM(refund_amount_usd),2) AS total_refund_amount,
       ROUND(SUM(refund_amount_usd) /(SELECT SUM(price_usd) FROM orders) * 100,2) AS revenue_loss_percent
FROM order_item_refunds;

-- Q19. Top 3 Products Contribution

WITH product_revenue AS 
	(
		SELECT product_id,
			   SUM(price_usd) AS revenue
		FROM order_items
		GROUP BY product_id
    ),
ranked_products AS 
	(
		SELECT *,
			   DENSE_RANK() OVER (ORDER BY revenue DESC) AS rnk
		FROM product_revenue
	)
SELECT ROUND(SUM(CASE WHEN rnk <= 3 THEN revenue END) / SUM(revenue) * 100,2) AS top_3_product_contribution
FROM ranked_products;