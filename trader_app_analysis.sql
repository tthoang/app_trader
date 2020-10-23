WITH prefered_apps AS (SELECT DISTINCT name
						FROM app_store_apps
						INTERSECT
						SELECT DISTINCT name
						FROM play_store_apps
					  	ORDER BY name),					
	 review_count_int AS(
						SELECT name, CAST(review_count AS integer) as apple_review_count
						FROM app_store_apps
						WHERE review_count IS NOT NULL
	 					),
combined_review_count AS( 
						SELECT app_store_apps.name, 
							(AVG(((app_store_apps.review_count::integer) + play_store_apps.review_count)/2)::integer)
						FROM app_store_apps INNER JOIN play_store_apps 
						ON app_store_apps.name=play_store_apps.name
						GROUP BY app_store_apps.name) 
SELECT DISTINCT
	pan.name, 
	ROUND(apa.rating/.5, 0)*.5 AS apple_rating, 
	ROUND(psa.rating/.5, 0)*.5 AS google_rating, 
	crc.avg AS avg_review_count,
	apa.primary_genre AS genre,
	psa.content_rating AS content_rating
FROM app_store_apps AS apa INNER JOIN prefered_apps AS pan ON apa.name = pan.name
	INNER JOIN play_store_apps AS psa ON pan.name = psa.name
	INNER JOIN review_count_int AS rci ON rci.name = pan.name
	INNER JOIN combined_review_count AS crc ON crc.name = pan.name
WHERE ROUND(apa.rating/.5, 0)*.5 >= 4.5 
	AND ROUND(psa.rating/.5, 0)*.5 >= 4.5
	AND crc.avg >= 1000000
	AND apa.price = '0.00'
	OR psa.type = 'free' 
GROUP BY pan.name, 
		apa.rating, 
		psa.rating, 
		rci.apple_review_count, 
		psa.review_count, 
		crc.avg, 
		apa.primary_genre,
		psa.content_rating
ORDER BY crc.avg DESC
LIMIT 15;

SELECT generate_series( 1, 12, 1) AS month;

WITH 
roi AS (SELECT generate_series( 0, 30000, 2500) AS monthly_revenue,
	   generate_series(1, 12, 1) AS num),

months AS (SELECT generate_series( NOW(), NOW() + ' 11 months' , '1 month') AS twelve_months,
		 generate_series(1, 12, 1) AS num )
SELECT date_part('month', twelve_months),
		monthly_revenue,
		roi.num
FROM roi INNER JOIN months ON roi.num = months.num;
		 

SELECT generate_series( 0, 30000, 2500) AS monthly_revenue,
		date_trunc('month', (SELECT generate_series( NOW(), NOW() + '1 year' , '1 month'))) AS twelve_months;

SELECT generate_series(1, 9, 1.5);

WITH prefered_apps AS (SELECT DISTINCT name
						FROM app_store_apps
						INTERSECT
						SELECT DISTINCT name
						FROM play_store_apps
					  	ORDER BY name)
SELECT COUNT(psa.price), psa.price
FROM play_store_apps AS psa 
	INNER JOIN prefered_apps AS pan 
	ON psa.name = pan.name 
GROUP BY psa.price
ORDER BY count DESC
LIMIT 6;

WITH 
roi AS (SELECT generate_series( 30000, 300000, 30000) AS yearly_revenue,
	   generate_series(1, 10, 1) AS num),

years AS (SELECT generate_series( NOW(), NOW() + ' 10 year' , '1 year') AS ten_years,
		 generate_series(1, 10, 1) AS num ),
		 
cost AS (SELECT generate_series(22000, 120000, 12000) as decade_cost,
		generate_series(1,10, 1) AS num)
SELECT date_part('year', ten_years) AS year,
		yearly_revenue,
		roi.num, 
		cost.yearly_cost
FROM roi INNER JOIN years ON roi.num = years.num
	INNER JOIN cost ON cost.num = roi.num;
