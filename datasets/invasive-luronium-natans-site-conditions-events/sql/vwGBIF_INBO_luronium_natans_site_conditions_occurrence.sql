USE [D0017_00_NBNData]
GO

/****** Object:  View [ipt].[vwGBIF_INBO_Luronium natans standplaatsonderzoek_occurrence]    Script Date: 12/10/2020 11:19:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





/**********************************
2018-05-17  Maken generische querie voor TrIAS
2018-12-10  Ecologische waterlopen vegetatie starts DiB
2019-01-20  Finaliseren Query
2020-10-12  Luronium natans
*********************************/

/**ALTER View [ipt].[vwGBIF_INBO_Luronium natans standplaatsonderzoek_occurrence]
AS**/

SELECT 
      --- EVENT ---

	  [eventID]= 'INBO:NBN:' + SA.[SAMPLE_KEY]
	, [parentEventID] ='INBO:NBN:' + SA.[survey_event_key]
		
	
	--- RECORD ---	
	
	, [type] = N'Event'
	, [basisOfRecord] = N'HumanObservation'

		--- Occurrence---

	, [occurrenceID] = N'INBO:NBN:' + TAO.[TAXON_OCCURRENCE_KEY]
	, [recordedBy] = NAME_KEY
	, [organismQuantity] = meas.DATA
					 
	, [organismQuantityType] = CASE DataShortName
								WHEN 'p/a' THEN 'check'
								WHEN 'BB' THEN 'CHECK'
								WHEN 'Tansley' THEN 'Tansley'
								WHEN 'Personal code' THEN 'Personal code'
								WHEN 'Klasse LurNat2' THEN 'CHECK'
								WHEN 'Range' THEN 'check'
								WHEN 'None' THEN 'check'
								WHEN '%' THEN 'check'
								ELSE DataShortName
								END
--	, [occurrenceStatus] = N'present'
	, [taxonRank] = CASE
					 WHEN NS.RECOMMENDED_NAME_RANK_LONG = 'Species' THEN 'species'
					 WHEN NS.RECOMMENDED_NAME_RANK_LONG = 'Species hybrid' THEN 'species'
					 WHEN NS.RECOMMENDED_NAME_RANK_LONG = 'Genus' THEN 'genus'
					ELSE NS.RECOMMENDED_NAME_RANK_LONG
					END
					
	

		--- TAXON ---

	, [scientificName] = RECOMMENDED_SCIENTIFIC_NAME
	, [scientificNameAuthorship] = RECOMMENDED_NAME_AUTHORITY
	, [kingdom] = N'Plantae'

	

	
	
	--- LOCATION ---
	
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
							--AND  MTMeas.SHORT_NAME = 'Abundance'
						) Meas on meas.TAXON_OCCURRENCE_KEY = tao.TAXON_OCCURRENCE_KEY 

	--measurement

WHERE
	S.[ITEM_NAME] IN ('Luronium natans standplaatsonderzoek') 
/**	AND ISNUMERIC(LEFT (SA.SPATIAL_REF, CHARINDEX(',', SA.SPATIAL_REF, 1)-1)) = 1
	AND CHARINDEX (',', SA.SPATIAL_REF, 1) > 5
	AND ISNUMERIC(SUBSTRING (SA.SPATIAL_REF, CHARINDEX(',', SA.SPATIAL_REF, 1 )+1, LEN(SA.SPATIAL_REF))) = 1 **/
--	and ST.SHORT_NAME <> 'Weather' 
	AND meas.DATA > '0'	














GO


