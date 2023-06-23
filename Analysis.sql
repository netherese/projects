#Total Sales
SELECT SUM(price_usd) AS total_sales
FROM orders;

#Total Refunds
SELECT SUM(refund_amount_usd) AS total_refunds
FROM order_item_refunds;

# Total Profit
SELECT 
    (SUM(o.price_usd) - SUM(o.cogs_usd) - IFNULL(SUM(oir.refund_amount_usd), 0)) AS total_profit
FROM 
    orders o
LEFT JOIN 
    order_items oi ON o.order_id = oi.order_id
LEFT JOIN 
    order_item_refunds oir ON oi.order_item_id = oir.order_item_id;

#TOP Product Sold
SELECT p.product_name, SUM(oi.price_usd) AS product_sales
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY product_sales DESC
LIMIT 4;

#Revenue for per websession
SELECT AVG(revenue) AS average_revenue_per_session
FROM (
    SELECT ws.website_session_id, SUM(o.price_usd) AS revenue
    FROM website_sessions ws
    INNER JOIN orders o ON ws.website_session_id = o.website_session_id
    GROUP BY ws.website_session_id
) AS session_revenues;

# Refund Rate
SELECT 
    p.product_name, 
    COUNT(DISTINCT oir.order_item_refund_id) / COUNT(DISTINCT oi.order_item_id) AS refund_rate
FROM 
    products p
LEFT JOIN 
    order_items oi ON p.product_id = oi.product_id
LEFT JOIN 
    order_item_refunds oir ON oi.order_item_id = oir.order_item_id
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    refund_rate DESC
LIMIT 4;


#Conversion rate
SELECT 
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conversion_rate
FROM 
    website_sessions ws
LEFT JOIN 
    orders o ON ws.website_session_id = o.website_session_id;
    
    
# Sales by device type
SELECT device_type, COUNT(DISTINCT order_id) as order_count
FROM orders o
JOIN website_sessions ws ON o.website_session_id = ws.website_session_id
GROUP BY device_type
ORDER BY order_count DESC;   
    
# Average visits before purchase
SELECT AVG(count) 
FROM (
    SELECT user_id, COUNT(*) AS count
    FROM website_sessions
    WHERE user_id IN (SELECT DISTINCT user_id FROM orders)
    GROUP BY user_id) AS t;

    
SELECT 
    DATE_FORMAT(o.created_at, '%Y-%m') AS month, 
    ws.device_type, 
    COUNT(DISTINCT o.order_id) as order_count
FROM 
    orders o
JOIN 
    website_sessions ws ON o.website_session_id = ws.website_session_id
GROUP BY 
    month, ws.device_type
ORDER BY 
    month DESC, order_count DESC;

SELECT 
    t.month,
    t.device_type,
    t.order_count,
    (t.order_count / t2.total_orders) * 100 AS order_percentage
FROM 
(
    SELECT 
        DATE_FORMAT(o.created_at, '%Y-%m') AS month, 
        ws.device_type, 
        COUNT(DISTINCT o.order_id) as order_count
    FROM 
        orders o
    JOIN 
        website_sessions ws ON o.website_session_id = ws.website_session_id
    GROUP BY 
        month, 
        ws.device_type
) AS t
JOIN 
(
    SELECT 
        DATE_FORMAT(created_at, '%Y-%m') AS month, 
        COUNT(DISTINCT order_id) AS total_orders
    FROM 
        orders
    GROUP BY 
        month
) AS t2
ON t.month = t2.month
ORDER BY 
    t.month DESC, 
    order_percentage DESC;

    
