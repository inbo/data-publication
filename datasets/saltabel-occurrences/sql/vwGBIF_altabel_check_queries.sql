SELECT [type],collectionCode, basisOfRecord, count (*) FROM ipt.vwGBIF_Saltabel_2020
WHERE collectionCode = 'FSAG'
GROUP BY [type],collectionCode, basisOfRecord

SELECT coordinateUncertaintyInMeters, count (*) FROM ipt.vwGBIF_Saltabel_2020
GROUP BY coordinateUncertaintyInMeters

SELECT lifeStage, count (*) FROM ipt.vwGBIF_Saltabel_2020
GROUP BY lifeStage

SELECT sex, count (*) FROM ipt.vwGBIF_Saltabel_2020
GROUP BY sex

SELECT verbatimCoordinateSystem, coordinateUncertaintyInMeters, georeferenceRemarks, count (*) FROM ipt.vwGBIF_Saltabel_2020
GROUP BY verbatimCoordinateSystem, coordinateUncertaintyInMeters, georeferenceRemarks

SELECT verbatimSRS from ipt.vwGBIF_Saltabel_2020
GROUP BY verbatimSRS

