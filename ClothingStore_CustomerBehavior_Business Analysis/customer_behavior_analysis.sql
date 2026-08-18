SELECT * FROM db_sales_analysis.customer_behaviour LIMIT 10;

# Total revenue Male vs Female
SELECT gender, SUM(sales) 
FROM customer_behaviour
group by gender;
# Males make up the largest proportion of customers, outnumbering female customers by the factor of 2
#-----------------------------------------------------------------------------------------------------

#How often is the discount applied, and how does this affect revenue?
select discount_applied, SUM(sales) as revenue, COUNT(customer_id) as orders_amount
from customer_behaviour
group by discount_applied;
/* There are 32% more orders without a discount than orders with a discount,
 and revenue from sales without a discount is 34% higher. */
 
#Top 5 products for men by rating
select item_purchased, ROUND(AVG(review_rating) as average_rating, 2), SUM(sales) as revenue 
from customer_behaviour
where gender = 'Male'
group by item_purchased
order by AVG(review_rating) desc
limit 5;

#Top 5 products for women by rating
select item_purchased, ROUND(AVG(review_rating) as average_rating, 2), SUM(sales) as revenue 
from customer_behaviour
where gender = 'Female'
group by item_purchased
order by AVG(review_rating) desc
limit 5;

#Express shiping vs Standard 
select shipping_type, COUNT(customer_id) as orders_amount, ROUND(AVG(sales), 0) as Average_order_value
from customer_behaviour
where shipping_type in ('Express', 'Standard')
group by shipping_type;

# Subscribers vs not subscribers 
select 
subscription_status, 
SUM(sales) as revenue, 
ROUND(AVG(sales), 0) as avg_customer_spend, 
COUNT(DISTINCT customer_id) as customers_amount,
SUM(
CASE WHEN discount_applied = 'Yes' THEN 1 
ELSE 0 
END
) AS times_discount_used 
from customer_behaviour
group by subscription_status;

# Repeat buyers and Subscription 
select subscription_status,
count(customer_id) as repeat_buyers
from customer_behaviour
where previous_purchases > 5
group by subscription_status;

#Revenue from every age group
select customer_age_group,
SUM(sales) as revenue,
COUNT(customer_id) as total_orders
from customer_behaviour
group by customer_age_group
order by SUM(sales) DESC;

