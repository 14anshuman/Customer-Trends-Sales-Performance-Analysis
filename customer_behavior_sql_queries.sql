/* =====================================================
   Customer Trends & Sales Performance Analysis
   ===================================================== */

-- 1. Revenue contribution by gender (with percentage share)
WITH gender_revenue AS (
    SELECT 
        gender,
        SUM(purchase_amount) AS total_revenue
    FROM customer
    GROUP BY gender
)
SELECT 
    gender,
    total_revenue,
    ROUND(100.0 * total_revenue / SUM(total_revenue) OVER (), 2) AS revenue_percentage
FROM gender_revenue
ORDER BY total_revenue DESC;

-- 2. High-value customers using discounts (above average spend)
WITH avg_spend AS (
    SELECT AVG(purchase_amount) AS avg_purchase
    FROM customer
)
SELECT 
    customer_id,
    purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
AND purchase_amount > (SELECT avg_purchase FROM avg_spend)
ORDER BY purchase_amount DESC;


-- 3. Top-rated products (minimum review threshold applied)
SELECT 
    item_purchased,
    ROUND(AVG(review_rating::numeric), 2) AS avg_rating,
    COUNT(*) AS total_reviews
FROM customer
GROUP BY item_purchased
HAVING COUNT(*) >= 5
ORDER BY avg_rating DESC
LIMIT 5;


-- 4. Average spend by shipping type
SELECT 
    shipping_type,
    COUNT(*) AS total_orders,
    ROUND(AVG(purchase_amount), 2) AS avg_spend
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;


-- 5. Subscriber vs non-subscriber value comparison
SELECT 
    subscription_status,
    COUNT(DISTINCT customer_id) AS customer_count,
    ROUND(AVG(purchase_amount), 2) AS avg_spend,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC;


-- 6. Products most influenced by discounts
SELECT 
    item_purchased,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE discount_applied = 'Yes') / COUNT(*),
        2
    ) AS discount_dependency_percentage
FROM customer
GROUP BY item_purchased
ORDER BY discount_dependency_percentage DESC
LIMIT 5;


-- 7. Customer segmentation based on purchase history
WITH customer_segments AS (
    SELECT 
        customer_id,
        CASE
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer
)
SELECT 
    customer_segment,
    COUNT(*) AS customer_count
FROM customer_segments
GROUP BY customer_segment;


-- 8. Top 3 products by order volume within each category
WITH ranked_products AS (
    SELECT 
        category,
        item_purchased,
        COUNT(*) AS total_orders,
        RANK() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS category_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT *
FROM ranked_products
WHERE category_rank <= 3;


-- 9. Revenue contribution by age group (with percentage share)
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue,
    ROUND(
        100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER (),
        2
    ) AS revenue_share_percentage
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;
