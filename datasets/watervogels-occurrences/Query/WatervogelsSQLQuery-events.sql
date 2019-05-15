USE [W0004_00_Waterbirds]
GO

/****** Object:  View [iptdev].[vwGBIF_INBO_Watervogels_new_events]    Script Date: 13/05/2019 12:35:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*** 2019-05-13 queryopnieuw gedaan***/

/**ALTER VIEW [iptdev].[vwGBIF_INBO_Watervogels_events]
AS**/


SELECT  
      [eventID ] = N'INBO:WATERVOGELS:EVENT:' + Right( N'000000000' + CONVERT(nvarchar(20) ,dsa.SampleKey),10)  
	, [type] = N'Event'
	, [language] = N'en'
	, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
	, [rightsHolder] = N'INBO'
	, [accessRights] = N'https://github.com/LifeWatchINBO/norms-for-data-use'
	, [datasetID] = N'http://doi.org/10.15468/lj0udq'
	, [institutionCode] = N'INBO'
	, [datasetName] = N'Watervogels - Wintering waterbirds in Flanders, Belgium'
	, [ownerInstitutionCode] = N'INBO'
	, [basisOfRecord] = N'HumanObservation'
	, dsa.IceCoverDescription
	, [eventRemarks] = 
		'{'
		+
		CASE samplecondition
			WHEN 'FAVORABLE' THEN '"samplingConditions":"favourable", ' -- Gunstig / normaal
			WHEN 'UNFAVORABLE' THEN '"samplingConditions":"unfavourable", ' -- Ongunstig
			ELSE '' 
		END
		+
		CASE CoverageCode
			WHEN 'V' THEN '"samplingCoverage":"complete", ' -- Volledig
			WHEN 'O' THEN '"samplingCoverage":"incomplete", ' -- Onvolledig
			WHEN 'N' THEN '' -- Niet geteld;  -> should return no data, as we select on having a scientificName
			WHEN 'X' THEN '' -- Geteld, geen vogels -> should return no data, as we select on having a scientificName
			ELSE ''
		END
		+
		CASE SnowCoverCode 
			WHEN 'N' THEN '"snow":"none", ' -- Geen
			WHEN 'E' THEN '"snow":"everywhere", ' -- Overal
			WHEN 'L' THEN '"snow":"locally", ' -- Plaatselijk
			ELSE ''
		END
		+ CASE IceCoverCode
			WHEN 'N' THEN '"ice":"0%", ' -- Geen
			WHEN 'M' THEN '"ice":">50%", ' -- < 50 %
			WHEN 'L' THEN '"ice":"<50%", ' -- > 50 %
			WHEN 'F' THEN '"ice":"100%", ' -- 100%
			ELSE ''
		END
		+ CASE WaterLevelCode
			WHEN 'N' THEN '"waterLevel":"normal"' -- Normaal
			WHEN 'L' THEN '"waterLevel":"low"' -- Laag
			WHEN 'H' THEN '"waterLevel":"high"' -- Hoog
			ELSE ''
		END
		+
		'}'
		, SampleDate as 'eventDate'
		, SurveyNaam
		, surveyCode
		, [sampleProtocol] = CASE SurveyCode 
			WHEN 'ZSCH' then 'Count On Boat'
			ELSE 'Count on Land'
			End
		, LocationWVNaam
		, LocationWVCode
		, sa.LocationWVKey
		, LocationGeometry



FROM dbo.DimSample dsa 
 INNER JOIN (SELECT DISTINCT(SampleKey), SurveyKey, EventKey, LocationWVKey, SampleDateKey FROM FactTaxonOccurrence Fta WHERE SampleKey > 0) as Sa ON sa.sampleKey = dsa.SampleKey
 INNER JOIN dbo.DimSurvey Di on DI.SurveyKey = SA.SurveyKey
 INNER JOIN dbo.DimLocationWV DiL on DiL.LocationWVKey = Sa.LocationWVKey
 GO