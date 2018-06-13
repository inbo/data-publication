USE [NBNData_IPT]
GO

/****** Object:  View [ipt].[vwGBIF_INBO_Rosse_Stekelstaart_events]    Script Date: 18/05/2018 15:39:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









/**********************************
2018-05-17  Maken generische querie voor TrIAS
*********************************/

CREATE View [ipt].[vwGBIF_INBO_Muntjak_events]
AS

SELECT 
	  [eventID]= SA.[SAMPLE_KEY]

	--- RECORD ---	
	, [type] = N'Event'
	, [language] = N'en'
	, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
	, [rightsHolder] = N'INBO'
	, [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
	, [datasetID] = N'Complete with DOI'
	, [datasetName] = 'datasetName - Ruddy duck in Flanders, Belgium'
	, [institutionCode] = N'INBO'
	, [ownerInstitutionCode] = N'INBO'
	, [dynamicProperties] = N'{"projectName":"' + S.ITEM_NAME + '"}'

	--- EVENT ---
	, [parentEventID] = SA.[survey_event_key]
	, [samplingProtocol] = 
		CASE CONVERT(Nvarchar(500),ST.SHORT_NAME)
			WHEN 'Afvangst' THEN 'Capture'
			WHEN 'Afschot' THEN 'culling - shooting'
			WHEN 'Field observation' THEN 'casual observation'
			WHEN 'Afvangst' THEN 'culling - moult capture'
			WHEN 'Weather' THEN 'Weather report'
			ELSE ST.SHORT_NAME
		END 
--, [samplingProtocol] = CONVERT(Nvarchar(500),ST.SHORT_NAME)
/**	, [samplingEffort] =
		CASE
			WHEN SA.DURATION IS NOT NULL THEN '{"trapDurationInMinutes":' + CONVERT(Nvarchar(20),SA.DURATION) + '}' 
			WHEN Durations.CommentContainsDuration = 1 AND DATEDIFF(mi,Convert(time, Durations.StartTime) ,  Convert(time, Durations.EndTime) ) > 0 THEN '{"trapDurationInMinutes":' + CONVERT(Nvarchar(20),DateDiff(mi,CONVERT(Time, Durations.StartTime), CONVERT(Time, Durations.EndTime))) + '}' 
			ELSE NULL
		END **/
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
/**	LEFT OUTER JOIN (
		SELECT
			-- Extract startTime-endTime from comment field
			  SA1.SAMPLE_KEY
			, Rtrim(Ltrim(Substring ([dbo].[ufn_RtfToPlaintext](SA1.COMMENT) ,CHARINDEX('-', [dbo].[ufn_RtfToPlaintext](SA1.COMMENT)) + 6 , 8000))) AS Comment
			, [CommentContainsDuration] = 
				CASE 
					WHEN CHARINDEX('-', [dbo].[ufn_RtfToPlaintext](SA1.COMMENT)) > 5
					AND Substring([dbo].[ufn_RtfToPlaintext](SA1.COMMENT), 1, CHARINDEX('-', [dbo].[ufn_RtfToPlaintext](SA1.COMMENT))) LIKE '[0123456789][0123456789]:[0123456789][0123456789]-'
					AND Substring([dbo].[ufn_RtfToPlaintext](SA1.COMMENT), CHARINDEX('-', [dbo].[ufn_RtfToPlaintext](SA1.COMMENT))+1,5) LIKE '[0123456789][0123456789]:[0123456789][0123456789]'
					THEN 1
					ELSE NULL
				END
			, [StartTime] = 
				CASE
					WHEN CHARINDEX('-', [dbo].[ufn_RtfToPlaintext](SA1.COMMENT))-1 > 1 THEN Substring([dbo].[ufn_RtfToPlaintext](SA1.COMMENT), 1,CHARINDEX('-', [dbo].[ufn_RtfToPlaintext](SA1.COMMENT))-1) + ':00'
					ELSE NULL
				END
			, [EndTime] = 
				Substring([dbo].[ufn_RtfToPlaintext](SA1.COMMENT), CHARINDEX('-', [dbo].[ufn_RtfToPlaintext](SA1.COMMENT))+1,5)  + ':00'
		FROM dbo.SAMPLE SA1
		) Durations ON Durations.SAMPLE_KEY = SA.SAMPLE_KEY 
		AND Durations.CommentContainsDuration = 1
	LEFT OUTER JOIN (
		SELECT
			  SA2.SAMPLE_KEY
			, Rtrim(Ltrim(Substring([dbo].[ufn_RtfToPlaintext] (SA2.COMMENT) , Len('CodeGans:')+1, 10))) as Code
		FROM dbo.SAMPLE SA2
		WHERE
			[dbo].[ufn_RtfToPlaintext] (COMMENT) LIKE 'CodeGans:%'
	) CodeGanzen ON CodeGanzen.SAMPLE_KEY = SA.SAMPLE_KEY
	INNER JOIN shp.Locatie_UTM1_vl shp ON 
		shp.UTM1_vl.STContains(geometry::Point( CONVERT( DECIMAL (12,3) ,
		LEFT ( SA.SPATIAL_REF , CHARINDEX ( ',',  SA.SPATIAL_REF , 1 )-1)), 
		CONVERT( DECIMAL (12,3) ,
		SUBSTRING ( SA.SPATIAL_REF , CHARINDEX ( ',',  SA.SPATIAL_REF , 1 )+1 , LEN (SA.SPATIAL_REF )) 
		),0) )= 1 **/

WHERE
--	S.[ITEM_NAME] IN ('Rosse Stekelstaart')
	S.SURVEY_KEY in ('BFN001790000004K','BFN0017900000044') 
	AND ISNUMERIC(LEFT (SA.SPATIAL_REF, CHARINDEX(',', SA.SPATIAL_REF, 1)-1)) = 1
	AND CHARINDEX (',', SA.SPATIAL_REF, 1) > 5
	AND ISNUMERIC(SUBSTRING (SA.SPATIAL_REF, CHARINDEX(',', SA.SPATIAL_REF, 1 )+1, LEN(SA.SPATIAL_REF))) = 1
	and ST.SHORT_NAME <> 'Weather'
		


GO


