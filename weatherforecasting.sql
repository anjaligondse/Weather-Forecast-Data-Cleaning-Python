Use weatherdata;

#1. Give the count of the minimum number of days for the time when temperature reduced*/

WITH daily_temp AS (
  SELECT Date, Average_temperature,
         LAG(Average_temperature) OVER (ORDER BY Date) AS prev_temp
  FROM dailyweather)
  
SELECT COUNT(*) as minimumdays
FROM daily_temp
WHERE Average_temperature < prev_temp;
  
#2. Find the temperature as Cold / hot by using the case and avg of values of the given data set 

With CTE as 
(SELECT Date, Average_temperature from dailyweather)
Select Date, Average_temperature,
CASE 
    WHEN Average_temperature >= AVG(Average_temperature) over() THEN 'Hot'
    ELSE 'Cold'
END as 'temp_status'
FROM CTE;

WITH cte AS (
SELECT Date, Average_temperature, AVG(Average_temperature) OVER() as avg_temp
FROM dailyweather
)
SELECT Date, Average_temperature,
CASE
WHEN Average_temperature >= avg_temp THEN 'Hot'
ELSE 'Cold'
END as temp_status
FROM cte
ORDER BY Date;

#3. Can you check for all 4 consecutive days when the temperature was below 30 Fahrenheit
WITH CTE AS (
   SELECT 
     Date, 
     Average_temperature, 
     Case 
        When Average_temperature < 30 then 'below'
        else 'above'
     end as temp30,
     ROW_NUMBER() OVER (ORDER BY Date) AS RowNumber
   FROM dailyweather
)
SELECT 
  CTE.Date, 
  CTE.Average_temperature, 
  CTE.temp30 
FROM CTE
WHERE temp30 = 'below'
  AND (
    SELECT COUNT(*) 
    FROM CTE as innerCTE 
    WHERE innerCTE.RowNumber BETWEEN CTE.RowNumber AND CTE.RowNumber + 3
      AND innerCTE.temp30 = 'below'
  ) = 4
ORDER BY CTE.Date;

#4. Can you find the maximum number of days for which temperature dropped
ALTER TABLE dailyweather 
MODIFY COLUMN Date DATE;

WITH CTE1 AS (
SELECT Date, Average_temperature,
LAG(Average_temperature) OVER (ORDER BY Date) AS Prev_temp
FROM dailyweather),

CTE2 AS (
SELECT Date, Average_temperature,
IF(Prev_temp > Average_temperature, @temp_drop := @temp_drop + 1, @temp_drop := 0) AS temp_drop,
@temp_drop AS cumulative_temp_drop
FROM CTE1, (SELECT @temp_drop := 0) temp_drop_init
)
SELECT MAX(cumulative_temp_drop) as max_days_temp_dropped FROM CTE2;

#5. Can you find the average of average humidity from the dataset
#( NOTE: should contain the following clauses: group by, order by, date )

SELECT AVG(avg_humidity) as avgofavg_humidity
FROM (
  SELECT Date, AVG(Average_humidity) as avg_humidity
  FROM dailyweather
  GROUP BY Date
) as Temp;

#6. Use the GROUP BY clause on the Date column and make a query to fetch details for average windspeed ( which is now windspeed done in task 3 )

SELECT Date, Average_windspeed as avg_windspeed
FROM dailyweather
GROUP BY Date;

# 7.Please add the data in the dataset for 2034 and 2035 as well as forecast predictions for these years

#Not able to perform data prediction

#8. If the maximum gust speed increases from 55mph, fetch the details for the next 4 days 
SELECT Date, Average_windspeed, Average_gust_speed
FROM dailyweather
WHERE Date > (SELECT Date FROM dailyweather WHERE Average_gust_speed > 55 ORDER BY Date LIMIT 1)
LIMIT 4;

#9.Find the number of days when the temperature went below 0 degrees Celsius

Select count(*) as numofdays From 
(Select Round(((Average_temperature-32)*5)/9) 
From dailyweather where Average_temperature < 0) Temp;
    
WITH CTE AS (
SELECT
*,
ROW_NUMBER() OVER (ORDER BY Date) AS RowNum
FROM
dailyweather
)

#10. Create another table with a “Foreign key” relation with the existing given data set.

CREATE TABLE dailypredictions (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
date_id DATE,
season VARCHAR(50),
snowfall varchar(50)
rain varchar(50)
sun varchar(50)
FOREIGN KEY (date_id) REFERENCES dailyweather(Date)
);


