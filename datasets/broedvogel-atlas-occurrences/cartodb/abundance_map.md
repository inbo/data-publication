## Bubble map of breeding pairs

This map is based on `individualCount` for "Atlashok" counts only.

## SQL

```SQL
SELECT
    the_geom_webmercator,
    locationid AS atlashok,
    sum(individualcount)/2 as breeding_pairs
FROM broedvogels
WHERE
    samplesize = 25
    AND samplingmethod != 'loose observations'
    AND scientificname = 'Acrocephalus schoenobaenus'
GROUP BY
    the_geom_webmercator,
    locationid
```

## CartoCSS

```CSS
#broedvogels{
    marker-fill-opacity: 0.9;
    marker-line-color: #FFF;
    marker-line-width: 1.5;
    marker-line-opacity: 1;
    marker-placement: point;
    marker-multi-policy: largest;
    marker-type: ellipse;
    marker-fill: #000000;
    marker-allow-overlap: true;
    marker-clip: false;
}
#broedvogels [ breeding_pairs <= 500] {
    marker-width: 25;
}
#broedvogels [ breeding_pairs <= 150] {
    marker-width: 22;
}
#broedvogels [ breeding_pairs <= 100] {
    marker-width: 19;
}
#broedvogels [ breeding_pairs <= 50] {
    marker-width: 16;
}
#broedvogels [ breeding_pairs <= 25] {
    marker-width: 13;
}
#broedvogels [ breeding_pairs <= 10] {
    marker-width: 10;
}
#broedvogels [ breeding_pairs <= 3] {
    marker-width: 7;
}
```
