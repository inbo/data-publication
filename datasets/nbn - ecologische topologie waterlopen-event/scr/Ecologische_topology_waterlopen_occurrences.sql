USE [NBNData_IPT]
GO

/****** Object:  View [ipt].[vwGBIF_INBO_Grensmaas_vegetatieopnamen_occurrences]    Script Date: 17/01/2019 13:58:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






/**********************************
2018-05-17  Maken generische querie voor TrIAS
2018-12-10  Grensmaas vegetatie starts DiB
*********************************/

ALTER View [ipt].[vwGBIF_INBO_INBO_Ecologische typologie waterlopen - occurrences]
AS

SELECT 
      --- EVENT ---

	  [eventID]= 'INBO:NBN:' + SA.[SAMPLE_KEY]
	, [parentEventID] ='INBO:NBN:' + SA.[survey_event_key]
	, [eventDate] = CONVERT(Nvarchar(23),[inbo].[LCReturnVagueDateGBIF]( SA.VAGUE_DATE_START, SA.VAGUE_DATE_END , SA.VAGUE_DATE_TYPE,1),126)
	, [eventDate2] = CONVERT(Nvarchar(23),[inbo].[LCReturnVagueDateGBIF]( SA.VAGUE_DATE_START, SA.VAGUE_DATE_END , SA.VAGUE_DATE_TYPE, 1),126)
	, [samplingProtocol] = CONVERT(Nvarchar(500),ST.SHORT_NAME)
	, [individualCount] = meas.DATA


	--- RECORD ---	
	
	, [type] = N'Event'
	, [language] = N'en'
	, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
	, [rightsHolder] = N'INBO'
	, [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
	, [datasetID] = N'Complete with DOI'
	, [datasetName] = 'Ecologische topologie waterlopen'
	, [institutionCode] = N'INBO'
	, [ownerInstitutionCode] = N'INBO'
	, [basisOfRecord] = N'HumanObservation'
	, [dynamicProperties] = N'{"projectName":"' + S.ITEM_NAME + '"}'

		--- Occurrence---

	,[occurrenceID] = N'INBO:NBN:' + TAO.[TAXON_OCCURRENCE_KEY]
	,[recordedBy] = NAME_KEY
	,[occurrenceStatus] = N'present'
	,[taxonRank] = NS.RECOMMENDED_NAME_RANK_LONG

		--- TAXON ---

	, [scientificName] = RECOMMENDED_SCIENTIFIC_NAME
	, [scientificNameAuthorship] = RECOMMENDED_NAME_AUTHORITY
	, [kingdom] = N'Plantae'

	

/**	, [samplingEffort] =
		CASE
			WHEN SA.DURATION IS NOT NULL THEN '{"trapDurationInMinutes":' + CONVERT(Nvarchar(20),SA.DURATION) + '}' 
			WHEN Durations.CommentContainsDuration = 1 AND DATEDIFF(mi,Convert(time, Durations.StartTime) ,  Convert(time, Durations.EndTime) ) > 0 THEN '{"trapDurationInMinutes":' + CONVERT(Nvarchar(20),DateDiff(mi,CONVERT(Time, Durations.StartTime), CONVERT(Time, Durations.EndTime))) + '}' 
			ELSE NULL
		END **/
	
	
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
	
	/*, [wkt] =
		CASE 
			WHEN SA.SPATIAL_REF IS NULL THEN NULL 
			ELSE 
				Convert(Nvarchar(100),'POINT ( ' + Substring(LTRIM(Rtrim(SUBSTRING(SA.SPATIAL_REF,0,CHARINDEX(',',SA.SPATIAL_REF)))), 1,
				CASE
					WHEN CHARINDEX('.', LTRIM(Rtrim(SUBSTRING(SA.SPATIAL_REF,0,CHARINDEX(',',SA.SPATIAL_REF)))))-1 > 0 
					THEN CHARINDEX('.', LTRIM(Rtrim(SUBSTRING(SA.SPATIAL_REF,0,CHARINDEX(',',SA.SPATIAL_REF)))))-1 
					ELSE LEN (LTRIM(Rtrim(SUBSTRING(SA.SPATIAL_REF,0,CHARINDEX(',',SA.SPATIAL_REF)))))
				END    ) 
		+ ' '  
		+ Substring( RTRIM(LTRIM(SUBSTRING(SA.SPATIAL_REF,CHARINDEX(',',SA.SPATIAL_REF)+1,LEN(SA.SPATIAL_REF)))) , 1, CASE WHEN CHARINDEX('.',  RTRIM(LTRIM(SUBSTRING(SA.SPATIAL_REF,CHARINDEX(',',SA.SPATIAL_REF)+1,LEN(SA.SPATIAL_REF))))) -1 > 0 THEN CHARINDEX('.', RTRIM(LTRIM(SUBSTRING(SA.SPATIAL_REF,CHARINDEX(',',SA.SPATIAL_REF)+1,LEN(SA.SPATIAL_REF))))) -1 ELSE LEN(RTRIM(LTRIM(SUBSTRING(SA.SPATIAL_REF,CHARINDEX(',',SA.SPATIAL_REF)+1,LEN(SA.SPATIAL_REF))))) END ) 
		+ ' ) ' )
		END
	*/  
FROM dbo.Survey S
	
	INNER JOIN [dbo].[Survey_event] SE ON SE.[Survey_Key] = S.[Survey_Key]
	LEFT OUTER JOIN [dbo].[Location] L ON L.[Location_Key] = SE.[Location_key]
	LEFT OUTER JOIN [dbo].[Location_Name] LN ON LN.[Location_Key] = L.[Location_Key] AND LN.[PREFERRED] = 1
	INNER JOIN [dbo].[SAMPLE] SA ON SA.[SURVEY_EVENT_KEY] = SE.[SURVEY_EVENT_KEY]
	LEFT OUTER JOIN [dbo].[SAMPLE_TYPE] ST ON  ST.[SAMPLE_TYPE_KEY] = SA.[SAMPLE_TYPE_KEY]
	INNER JOIN [dbo].[TAXON_OCCURRENCE] TAO ON TAO.[SAMPLE_KEY] = SA.[SAMPLE_KEY]

	LEFT JOIN [dbo].[RECORD_TYPE] RT ON RT.[RECORD_TYPE_KEY] = TAO.[RECORD_TYPE_KEY]
	LEFT JOIN [dbo].[SPECIMEN] SP ON SP.[TAXON_OCCURRENCE_KEY] = TAO.[TAXON_OCCURRENCE_KEY]
	
	LEFT JOIN [dbo].[TAXON_DETERMINATION] TD ON TD.[TAXON_OCCURRENCE_KEY] = TAO.[TAXON_OCCURRENCE_KEY]
	LEFT JOIN [dbo].[INDIVIDUAL] I ON I.[NAME_KEY] = TD.[DETERMINER]
	LEFT JOIN [dbo].[DETERMINATION_TYPE] DT ON DT.[DETERMINATION_TYPE_KEY] = TD.[DETERMINATION_TYPE_KEY]

	
	--Taxon
	LEFT JOIN [dbo].[TAXON_LIST_ITEM] TLI ON TLI.[TAXON_LIST_ITEM_KEY] = TD.[TAXON_LIST_ITEM_KEY]
	LEFT JOIN [dbo].[TAXON_VERSION] TV ON TV.[TAXON_VERSION_KEY] = TLI.[TAXON_VERSION_KEY]
	LEFT JOIN [dbo].[TAXON] T ON T.[TAXON_KEY] = TV.[TAXON_KEY]
	
	INNER JOIN [dbo].[TAXON_RANK] TR ON TR.TAXON_RANK_KEY = TLI.TAXON_RANK_KEY
	--Lijst
	--LEFT JOIN [dbo].[TAXON_LIST_VERSION] TLV ON TLV.TAXON_LIST_VERSION_KEY = TLI.TAXON_LIST_VERSION_KEY
	--LEFT JOIN [dbo].[TAXON_LIST] TL ON TL.TAXON_LIST_KEY =  TLV.TAXON_LIST_KEY

	--Normalizeren Namen 
	--LEFT JOIN [dbo].[NAMESERVER] NS ON NS.INPUT_TAXON_VERSION_KEY = TD.TAXON_LIST_ITEM_KEY
	INNER JOIN [inbo].[NameServer_12] NS ON NS.[INBO_TAXON_VERSION_KEY] = TLI.[TAXON_VERSION_KEY]

	--measurement
		LEFT OUTER JOIN ( SELECT taoMeas.TAXON_OCCURRENCE_KEY 
								, taoMeas.DATA
								, MUMeas.SHORT_NAME as DataShortName
								, MUMeas.LONG_NAME as DataLongName
								, MUMeas.[DESCRIPTION] as DataDescription
 								, MQMeas.SHORT_NAME as QualifierShortName
								, MQMeas.LONG_NAME as QualifierLongName
								, MQMeas.[DESCRIPTION] as QualifierDescription
							FROM [dbo].[TAXON_OCCURRENCE_DATA] taoMeas 
								LEFT JOIN dbo.MEASUREMENT_UNIT MUMeas ON  MUMeas.MEASUREMENT_UNIT_KEY = taoMeas.MEASUREMENT_UNIT_KEY
								LEFT JOIN dbo.MEASUREMENT_QUALIFIER MQMeas ON  MQMeas.MEASUREMENT_QUALIFIER_KEY = taoMeas.MEASUREMENT_QUALIFIER_KEY
								LEFT JOIN dbo.MEASUREMENT_TYPE MTMeas ON  (MTMeas.MEASUREMENT_TYPE_KEY = MQMeas.MEASUREMENT_TYPE_KEY )
							WHERE 1=1
							--AND taoMeas.TAXON_OCCURRENCE_KEY = 'BFN0017900009PCB'
							AND  MTMeas.SHORT_NAME = 'Abundance'
						) Meas on meas.TAXON_OCCURRENCE_KEY = tao.TAXON_OCCURRENCE_KEY 

	--measurement

WHERE
	S.[ITEM_NAME] IN ('Ecologische typologie waterlopen - vegetatieopnamen') 
/**	AND ISNUMERIC(LEFT (SA.SPATIAL_REF, CHARINDEX(',', SA.SPATIAL_REF, 1)-1)) = 1
	AND CHARINDEX (',', SA.SPATIAL_REF, 1) > 5
	AND ISNUMERIC(SUBSTRING (SA.SPATIAL_REF, CHARINDEX(',', SA.SPATIAL_REF, 1 )+1, LEN(SA.SPATIAL_REF))) = 1 **/
--	and ST.SHORT_NAME <> 'Weather' 
		






GO


