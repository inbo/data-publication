USE [W0004_00_Waterbirds]
GO

/****** Object:  View [ipt].[vwGBIF_INBO_Watervogels_events]    Script Date: 21/06/2019 9:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









ALTER VIEW [ipt].[vwGBIF_INBO_Watervogels_events]
AS


SELECT  

  ---RECORD ---

      [type] = N'Event'
   	, [language] = N'en'
	, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
	, [rightsHolder] = N'INBO'
	, [accessRights] = N'https://www.inbo.be/en/norms-data-use'
	, [datasetID] = N'http://doi.org/10.15468/lj0udq'
	, [datasetName] = N'Watervogels - Wintering waterbirds in Flanders, Belgium'
	, [institutionCode] = N'INBO'
	
	
	
  ---EVENT---	
	
	, [eventID ] = N'INBO:WATERVOGELS:EVENT:' + Right( N'000000000' + CONVERT(nvarchar(20) ,dsa.SampleKey),10)  
-- obsolete	, [parentEventID] = N'INBO:WATERVOGELS:EVENT:' + Right( N'000000000' + CONVERT(nvarchar(20) ,di.SurveyKey),10)
	, [basisOfRecord] = N'HumanObservation'
	, [samplingProtocol] = CASE SurveyCode
							WHEN 'ZSCH' THEN 'survey from boat'
							WHEN 'NOORD' THEN 'Survey from boat'
							ELSE 'survey from land'
							END
	, [samplingEffort] = case CoverageDescription
							WHEN 'Volledig' THEN 'all waterbirds counted'
							WHEN 'Onvolledig' THEN 'not all waterbirds counted'
							ELSE 'unknown'
							END
	, [eventRemarks] = case CONCAT(IsgullsCounted,IsGeeseCounted,IsWaderCounted)
							WHEN '111' THEN 'waterbirds counted'
							WHEN '110' THEN 'waterbirds except waders counted'
							WHEN '001' THEN 'waterbirds except gulls and geese counted'
							WHEN '000' THEN 'waterbirds except waders, gulls and geese counted'
							WHEN '011' THEN 'waterbirds except gulls counted'
							WHEN '010' THEN 'waterbirds except gulls and waders counted'
							WHEN '101' THEN 'waterbirds except geese counted'
							WHEN '100' THEN 'waterbirds except geese and waders counted'
							ELSE 'unknown'
							END
	, IsGullsCounted
	, IsGeeseCounted
	, IsWaderCounted
	,[eventDate] = SampleDate
	,[dynamicProperties] = 
		'{'
		+
		CASE samplecondition
			WHEN 'FAVORABLE' THEN '"samplingConditions":"favourable", ' -- Gunstig / normaal
			WHEN 'UNFAVORABLE' THEN '"samplingConditions":"unfavourable", ' -- Ongunstig
			ELSE '"samplingConditions":"unknown"' 
		END
		+
		CASE CoverageCode
			WHEN 'V' THEN '"samplingCoverage":"complete", ' -- Volledig
			WHEN 'O' THEN '"samplingCoverage":"uncomplete", ' -- Onvolledig
			WHEN 'N' THEN '"samplingCoverage":"uncomplete"' -- Niet geteld;  -> should return no data, as we select on having a scientificName
			WHEN 'X' THEN '"samplingCoverage":"uncomplete"' -- Geteld, geen vogels -> should return no data, as we select on having a scientificName
			ELSE '"samplingCoverage":"uncomplete"'
		END
		+
		CASE SnowCoverCode 
			WHEN 'N' THEN '"snow":"none", ' -- Geen
			WHEN 'E' THEN '"snow":"everywhere", ' -- Overal
			WHEN 'L' THEN '"snow":"locally", ' -- Plaatselijk
			ELSE '"snow":"unknown"'
		END
		+ CASE IceCoverCode
			WHEN 'N' THEN '"ice":"0%", ' -- Geen
			WHEN 'M' THEN '"ice":">50%", ' -- < 50 %
			WHEN 'L' THEN '"ice":"<50%", ' -- > 50 %
			WHEN 'F' THEN '"ice":"100%", ' -- 100%
			ELSE '"ice":"unknown"'
		END
		+ CASE WaterLevelCode
			WHEN 'N' THEN '"waterLevel":"normal"' -- Normaal
			WHEN 'L' THEN '"waterLevel":"low"' -- Laag
			WHEN 'H' THEN '"waterLevel":"high"' -- Hoog
			ELSE '"waterLevel":"unknown"'
		END
		+
		'}'
	
	---LOCATION
	, [locationID] = N'INBO:WATERVOGELS:LOCATION:' + Right( N'000000000' + CONVERT(nvarchar(20) ,DiL.LocationWVCode),10) 
	, [continent] = N'Europe'
	, [waterbody] = Dil.LocationWVNaam
	, [countryCode] = N'BE'
	, [varbatimLocality] = DiL.LocationWVNaam
	, [georeferenceRemarks] = N'coordinates are centroid of location' 
	, CONVERT(decimal(10,5), Dil.LocationGeometry.STCentroid().STY) as decimalLatitude
	, CONVERT(decimal(10,5), Dil.LocationGeometry.STCentroid().STX) as decimalLongitude
	, [geodeticDatum] = N'WGS84'

	, Dil.LocationGeometry as LocationGeometry
	, Dil.LocationGeometry.STCentroid() as LocationGeometryCentroid
	, Dil.LocationGeometry.STCentroid().STAsText() as LocationGeometryCentroidTekst


	, SurveyCode
	, SurveyNaam
	--- , dsa.IceCoverDescription

FROM dbo.DimSample dsa 
 INNER JOIN (SELECT DISTINCT(SampleKey), SurveyKey, EventKey, LocationWVKey, SampleDateKey FROM FactTaxonOccurrence Fta WHERE SampleKey > 0) as Sa ON sa.sampleKey = dsa.SampleKey
 INNER JOIN dbo.DimSurvey Di on Di.SurveyKey = Sa.SurveyKey
							AND Di.SurveyCode IN ('ZSCH','MIDMA')
 INNER JOIN dbo.DimLocationWV DiL on DiL.LocationWVKey = Sa.LocationWVKey
									
--SELECT  *FROM DimSample
--SELECT  *FROM DimSurvey
AND dsa.sampleDate < '2016-03-31 00:00:00.000' 
AND dsa.sampleDate > '1991-01-01 00:00:00.000' 
---AND CoverageDescription LIKE 'Onvolledig'
AND LocationGeometry IS NOT NULL





GO


