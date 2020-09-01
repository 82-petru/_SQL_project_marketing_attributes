-- create a query and find relationship between sources and campaign
SELECT * 
FROM page_visits
GROUP BY utm_source, utm_campaign;

-- create a query to select distinct values  from page_name column  
SELECT DISTINCT page_name
FROM page_visits;

-- create a temporary table to count first touches for each campaign 
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id)
SELECT ft.user_id,
    ft.first_touch_at,
    pv.utm_source,
		pv.utm_campaign,
    COUNT(*) as users_campaign
FROM first_touch ft
JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
    GROUP BY utm_campaign
    ORDER BY 5 DESC;

-- create a temporary table to count last touches for each campaign 
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id)
SELECT lt.user_id,
    lt.last_touch_at,
    pv.utm_source,
		pv.utm_campaign,
    COUNT(*) as users_campaign
FROM last_touch lt
JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
    GROUP BY utm_campaign
    ORDER BY 5 DESC;

-- create a query and count the number of user who make a purchase
SELECT page_name,
  COUNT(*)
FROM page_visits
GROUP BY 1;

-- create a query that counts the users who make a purchase  for each campaign 
SELECT utm_campaign,
  utm_source, 
  COUNT(*) as user_who_purchase
FROM page_visits
WHERE page_name = '4 - purchase'
GROUP BY 1
Order By 3 DESC;

-- create a temporary table and build up a column for each page name
WITH page_name as 
(SELECT 
  utm_campaign,
  utm_source,
    CASE
      WHEN page_name == "1 - landing_page" THEN 1
      ELSE 0
    END as 'user_who_landing_page',
    CASE
      WHEN page_name == "2 - shopping_cart" THEN 1
      ELSE 0
    END as 'user_who_shopping_cart',
    CASE
      WHEN page_name == "3 - checkout" THEN 1
      ELSE 0
    END as 'user_who_checkout',
      CASE
      WHEN page_name == "4 - purchase" THEN 1
      ELSE 0
    END as 'user_who_purchase'
FROM page_visits) 
SELECT 
  utm_campaign,
  utm_source,
  SUM(user_who_landing_page) as landing_page,
  SUM(user_who_shopping_cart) as shoping_cart,
  SUM(user_who_checkout) as checkout,
  SUM(user_who_purchase) as purchase
FROM page_name
GROUP BY 1
ORDER BY purchase DESC;


WITH journey as 
  (SELECT *
  FROM page_visits
  WHERE page_name = '4 - purchase'),
-- SELECT FROM journeyINNER JOIN page_visits as pvON journey.user_id = pv.user_id;
join_tables as 
  (SELECT 
    pv.user_id,
    pv.page_name,
    pv.timestamp,
    pv.utm_campaign,
    pv.utm_source
  FROM journey
  INNER JOIN page_visits as pv
    ON journey.user_id = pv.user_id),
-- SELECT * FROM join_tables LIMIT  50;
first_journey as 
  (SELECT 
    page_name,
    utm_campaign,
    utm_source
  FROM join_tables
  WHERE page_name = '1 - landing_page' OR page_name = "2 - shopping_cart"),
--SELECT * FROM first_journey;
landing_page as 
  (SELECT 
      utm_campaign,
      utm_source,
      COUNT(*) as num_users
    FROM first_journey
    WHERE page_name = "2 - shopping_cart"
    GROUP BY 1
    ORDER BY 3 DESC)
SELECT * FROM landing_page;
