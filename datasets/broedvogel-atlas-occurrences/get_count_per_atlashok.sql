/* This SQL query allows you to group and plot records per "atlashok" (a 5x5km square grid cell)
* as used in the broedvogel atlas book.
* 
* The query below will give you a count of "Anas crecca" observations per atlashok and display 
* these on a CartoDB map using the_geom_webmercator. A bubble size visualization can be used to 
* indicate the count.
*
* Requirements for this query: CartoDB (which uses Postgres)
* Required fields for this query:
* - the_geom_webmercator: coordinates derived from decimal_latitude and decimal_longitude
* - locationid: the corresponding atlashok of the observation
* - samplesize(value): 25 (square kilometer) for atlashokken
* - scientificname
*/

-- Create a table with all unique atlashokken and their coordinates
WITH atlashokken AS (
  SELECT
  	the_geom_webmercator,
  	locationid AS atlashok
  FROM broedvogels
  WHERE samplesize = 25
  GROUP BY
  	the_geom_webmercator,
  	locationid
)

-- Use the geom_web_mercator from atlashokken to group and plot records
SELECT
	a.atlashok,
	a.the_geom_webmercator,
	count(*)
FROM broedvogels b
	LEFT JOIN atlashokken a
	ON b.locationid = a.atlashok
WHERE scientificname = 'Anas crecca'
GROUP BY
	a.atlashok,
	a.the_geom_webmercator
