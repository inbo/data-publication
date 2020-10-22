USE [D0017_00_NBNData]
GO

/****** Object:  View [ipt].[vwGBIF_INBO_Luronium natans standplaatsonderzoek_event]    Script Date: 12/10/2020 10:59:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










/**********************************
2018-05-17  Maken generische querie voor TrIAS
2018-06-21  finaliseren Query Grensmaas vegetatieopnamen
2020-10-12  changes for Luronium natans
*********************************/

ALTER View [ipt].[vwGBIF_INBO_Luronium natans standplaatsonderzoek_event]
AS

SELECT 
	  [eventID]= 'INBO:NBN:' + SA.[SAMPLE_KEY]

	--- RECORD ---	
	, [type] = N'Event'
	, [language] = N'en'
	, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
	, [rightsHolder] = N'INBO'
	, [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
	, [datasetID] = N'https://doi.org/completexxxxxx'
	, [datasetName] = ' Invasive species - Luronium natans site condition Flanders, Belgium'
	, [institutionCode] = N'INBO'

	--- EVENT ---
	, [parentEventID] ='INBO:NBN:' + SA.[survey_event_key]
	, [samplingProtocol] = 
		CASE CONVERT(Nvarchar(500),LOWER(ST.SHORT_NAME))
			WHEN 'vegrec' THEN 'vegetation recording'
			WHEN 'site description' THEN 'site description'
			WHEN 'Field observation' THEN 'casual observation'
			WHEN 'streeplijst' THEN 'tally sheet'
			WHEN 'Weather' THEN 'Weather report'
			ELSE ST.SHORT_NAME
		END 

	, [eventDate] = CONVERT(Nvarchar(23),[inbo].[LCReturnVagueDateGBIF]( SA.VAGUE_DATE_START, SA.VAGUE_DATE_END , SA.VAGUE_DATE_TYPE, 1),126)
	
	--- LOCATION ---
	, [locationID] = SA.LOCATION_KEY
	, [continent] = N'Europe'
	, [countryCode] = N'BE'
	, [verbatimLocality] = COALESCE(CONVERT(Nvarchar(500), LN.ITEM_NAME) + ' ', '') + COALESCE(CONVERT(Nvarchar(4000), Sa.LOCATION_NAME),'')
	, [verbatimLatitude] = LTRIM(SUBSTRING(SA.SPATIAL_REF,CHARINDEX(',',SA.SPATIAL_REF)+1,LEN(SA.SPATIAL_REF))) -- Everything after , = y = latitude
	, [verbatimLongitude] = SUBSTRING(SA.SPATIAL_REF,0,CHARINDEX(',',SA.SPATIAL_REF)) -- Everything before , = x = longitude
	, [verbatimCoordinateSystem] =
		CASE
			WHEN SA.SPATIAL_REF IS NOT NULL AND SA.SPATIAL_REF_SYSTEM = 'BD72' THEN N'Belgian Lambert 72'
		END
	, [verbatimSRS] = 
		CASE 
			WHEN SA.SPATIAL_REF IS NOT NULL THEN N'Belgian Datum 1972'
		END
	, [decimalLatitude] = 
		CASE
			WHEN SA.SPATIAL_REF IS NOT NULL THEN CONVERT(Nvarchar(20),CONVERT(decimal(12,5),ROUND(COALESCE(SA.Lat,0),5))) -- SA.SPATIAL_REF is needed, because NULL ones are translated to 0.000 in Lat and Long
		END
	, [decimalLongitude] = 
		CASE
			WHEN SA.SPATIAL_REF IS NOT NULL THEN CONVERT(Nvarchar(20),CONVERT(decimal(12,5),ROUND(COALESCE(SA.Long,0),5)))
		END
	, [geodeticDatum] = 
		CASE 
			WHEN SA.SPATIAL_REF IS NOT NULL THEN N'WGS84'
		END
	-- , [coordinateUncertaintyInMeters] = ... -- Polygonen en bronnen te verschillend om hier een nuttige schatting te maken
    , [georeferenceSources] = 
		CASE
			WHEN SA.SPATIAL_REF IS NOT NULL THEN LOWER(SA.[SPATIAL_REF_QUALIFIER])
		END
	
	
FROM dbo.Survey S
	INNER JOIN [dbo].[Survey_event] SE ON SE.[Survey_Key] = S.[Survey_Key]
	LEFT OUTER JOIN [dbo].[Location] L ON L.[Location_Key] = SE.[Location_key]
	LEFT OUTER JOIN [dbo].[Location_Name] LN ON LN.[Location_Key] = L.[Location_Key] AND LN.[PREFERRED] = 1
	INNER JOIN [dbo].[SAMPLE] SA ON SA.[SURVEY_EVENT_KEY] = SE.[SURVEY_EVENT_KEY]
	LEFT OUTER JOIN [dbo].[SAMPLE_TYPE] ST ON  ST.[SAMPLE_TYPE_KEY] = SA.[SAMPLE_TYPE_KEY]


WHERE
	S.[ITEM_NAME] IN ('Luronium natans standplaatsonderzoek') 
/**	AND ISNUMERIC(LEFT (SA.SPATIAL_REF, CHARINDEX(',', SA.SPATIAL_REF, 1)-1)) = 1
	AND CHARINDEX (',', SA.SPATIAL_REF, 1) > 5
	AND ISNUMERIC(SUBSTRING (SA.SPATIAL_REF, CHARINDEX(',', SA.SPATIAL_REF, 1 )+1, LEN(SA.SPATIAL_REF))) = 1
	and ST.SHORT_NAME <> 'Weather' **/
	



GO


