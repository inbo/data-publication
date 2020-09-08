SELECT [type],collectionCode, count (*) FROM ipt.vwGBIF_Saltabel_2020
GROUP BY [type],collectionCode

SELECT coordinateUncertaintyInMeters, count (*) FROM ipt.vwGBIF_Saltabel_2020
GROUP BY coordinateUncertaintyInMeters

SELECT lifeStage, count (*) FROM ipt.vwGBIF_Saltabel_2020
GROUP BY lifeStage

SELECT sex, count (*) FROM ipt.vwGBIF_Saltabel_2020
GROUP BY sex

SELECT verbatimCoordinateSystem, coordinateUncertaintyInMeters, georeferenceRemarks, count (*) FROM ipt.vwGBIF_Saltabel_2020
GROUP BY verbatimCoordinateSystem, coordinateUncertaintyInMeters, georeferenceRemarks