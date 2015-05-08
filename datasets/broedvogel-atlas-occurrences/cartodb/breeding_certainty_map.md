## Category map of breeding certainty

This map is based on `behaviour` for "Atlashok" counts only. It does plot dots for different years on top of each other though, so this is just a first attempt.

## SQL

```SQL
SELECT *
FROM broedvogels
WHERE
    behavior != ''
    AND samplesize = 25
    AND samplingmethod != 'loose observations'
    AND scientificname = 'Acrocephalus schoenobaenus'
```

## CartoCSS

```CSS
/** category visualization */

#broedvogels {
    marker-fill-opacity: 0.9;
    marker-line-color: #FFF;
    marker-line-width: 1.5;
    marker-line-opacity: 1;
    marker-placement: point;
    marker-type: ellipse;
    marker-width: 20;
    marker-allow-overlap: true;
}

#broedvogels[behavior="confirmed breeding"] {
    marker-fill: #73300b;
}
#broedvogels[behavior="possibly breeding"] {
    marker-fill: #FF6600;
}
#broedvogels[behavior="probably breeding"] {
    marker-fill: #F11810;
}
```
