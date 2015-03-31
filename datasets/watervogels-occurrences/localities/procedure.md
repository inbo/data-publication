# Procedure to create localities geojson from source shapefile

1. Change datum to `WGS84` in QGIS and export.
2. Upload data to CartoDB
3. Remove unnecessary fields:

    ```SQL
    ALTER TABLE watervogels_gebieden
    DROP COLUMN id, 
    DROP COLUMN shape_leng, 
    DROP COLUMN shape_area, 
    DROP COLUMN x_coordina, 
    DROP COLUMN y_coordina, 
    DROP COLUMN code, 
    DROP COLUMN regiocode, 
    DROP COLUMN gemeenteco, 
    DROP COLUMN monitoring, 
    DROP COLUMN egvogelric, 
    DROP COLUMN ramsargebi, 
    DROP COLUMN ecoregio, 
    DROP COLUMN habitatcod, 
    DROP COLUMN vrlcode, 
    DROP COLUMN ramsarcode, 
    DROP COLUMN hrlcode, 
    DROP COLUMN hoofdgebie,
    DROP COLUMN utm5km
    ```

4. Rename remaining fields:

    ```SQL
    ALTER TABLE watervogels_gebieden
    RENAME COLUMN actief TO active;
    ALTER TABLE watervogels_gebieden
    RENAME COLUMN gebiedscod TO code;
    ALTER TABLE watervogels_gebieden
    RENAME COLUMN gebiedsnaa TO name;
    ALTER TABLE watervogels_gebieden
    RENAME COLUMN objectid TO object_id;
    ```

5. Change data types:

    ```SQL
    ALTER TABLE watervogels_gebieden
    ALTER COLUMN active SET data type boolean USING active::boolean;
    ALTER TABLE watervogels_gebieden
    ALTER COLUMN code SET data type integer USING code::integer;
    ```

6. Find records with the same code (duplicates):

    ```SQL
    WITH duplicates as (
        SELECT code
        FROM watervogels_gebieden
        GROUP BY code
        HAVING count(*) > 1
    )
    
    SELECT w.code, w.object_id
    FROM watervogels_gebieden w
    RIGHT JOIN duplicates d
    ON w.code = d.code
    ```
    
    Result:
    
    ```
    code    object_id
    2050810 249
    2050810 250
    1020129 271
    1020129 272
    2090902 698
    2090902 699
    1014305 1364
    1014305 1365
    ```

7. Merge polygons for those records into one and delete the other. Do this for all pairs obtained above.

    ```SQL
    UPDATE watervogels_gebieden
    SET the_geom = st_union(the_geom,
      (SELECT the_geom
       FROM watervogels_gebieden
       WHERE object_id = 250))
    WHERE object_id = 249;
    
    DELETE FROM watervogels_gebieden
    WHERE object_id = 250;
    ```

8. Correct a locality:

    ```SQL
    UPDATE watervogels_gebieden
    SET
        code = 5190418,
        name = 'Velbo West (vroeger Lommel Kolonie)'
    WHERE code = 4190418
    ```

9. Create fields for the centroid:
    
    ```SQL
    ALTER TABLE watervogels_gebieden
    ADD COLUMN centroid_latitude numeric,
    ADD COLUMN centroid_longitude numeric
    ```

10. Calculate and add centroid for all localities:

    ```SQL
    UPDATE watervogels_gebieden
    SET
        centroid_latitude = round(st_y(st_centroid(the_geom))::numeric,7),
        centroid_longitude = round(st_x(st_centroid(the_geom))::numeric,7)
    ```

11. Create a view for geojson export:

    ```SQL
    SELECT
        code,
        name,
        active,
        centroid_latitude,
        centroid_longitude,
        the_geom
    FROM watervogels_gebieden
    ORDER BY code
    ```

12. Export as geojson and upload to GitHub as `localities.geojson`.
13. Create a view for csv export:

    ```SQL
    SELECT
        code,
        name,
        active,
        centroid_latitude,
        centroid_longitude
    FROM watervogels_gebieden
    ORDER BY code
    ```

14. Export as csv and upload to GitHub as `localities_centroid_coordinates.csv`.
