USE [NBNData_IPT]
GO

/****** Object:  View [ipt].[vwGBIF_INBO_Chinese_mittencrab_occurrences]    Script Date: 03/09/2016 11:43:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [ipt].[vwGBIF_INBO_Chinese_mittencrab_occurrences]
AS

/*********************************************************/
/*
	Changes ON 20160226
		
	Changes ON 20150625
	Modify & update Query 20150806
		add comment as source of data
		remove waarnemingen data
		anonymiseren recorders
		nl vernacularName toevoegen
		functies gebruiken (dbo.[ufn_RecordersPerSample](SA.[SAMPLE_KEY]), en , [comment2] = dbo.[ufn_RtfToPlaintext] (SE.[COMMENT])
	Changes on 20150810
		update & optimize query (get rid of GROUP By)
		remove 0-values
*/
/*********************************************************/

SELECT [survey] = S.ITEM_NAME COLLATE Latin1_General_CI_AI 
	, [occurrenceID] = 'INBO:NBN:' + TAO.TAXON_OCCURRENCE_KEY COLLATE Latin1_General_CI_AI 
	, [modified] = [inbo].[LCReturnVagueDateGBIF]( IdentifiedBy.VAGUE_DATE_START, IdentifiedBy.VAGUE_DATE_END , IdentifiedBy.VAGUE_DATE_TYPE,1 )  COLLATE Latin1_General_CI_AI 
		--[samplingProtocol2] = RT.SHORT_NAME ,  (enkel "none" in waardes)
	, [basisOfRecord] = CONVERT(Nvarchar(20),'HumanObservation') COLLATE Latin1_General_CI_AI 
	, [institutionCode] = CONVERT(Nvarchar(20),'INBO') COLLATE Latin1_General_CI_AI 
	, [datasetName] = 'Invasive species - Chinese_mittencrab (Eriocheir sinensis) in Flanders'  --CONVERT(Nvarchar(200),S.ITEM_NAME) +COLLATE Latin1_General_CI_AI 
	, [dynamicProperties] = '{"projectName":' + dbo.[ufn_RtfToPlaintext] (SE.[COMMENT]) COLLATE Latin1_General_CI_AI + '}'	
	, [eventID] = SA.[survey_event_key] COLLATE Latin1_General_CI_AI 
		
-- Taxonomic Elements --
	--, [originalNameUsage] = T.ITEM_NAME
	, [scientificName] = ns.RECOMMENDED_SCIENTIFIC_NAME  COLLATE Latin1_General_CI_AI    --recommended scientific soort + genus 
	, [scientificNameAuthorship] = NS.RECOMMENDED_NAME_AUTHORITY + ISNULL ( ' ' + NS.RECOMMENDED_NAME_QUALIFIER , '') COLLATE Latin1_General_CI_AI 
	, lower(NS.RECOMMENDED_NAME_RANK_LONG) COLLATE Latin1_General_CI_AI  AS taxonRank  

-- Identification Elements --

	, [recordedBy] = Recorders.NameKeyChain COLLATE Latin1_General_CI_AI 
	--, [recordedBy] = Recorders.Recorders

-- Locality Elements --

	, [countryCode] = CONVERt(Nvarchar(20),'BE') COLLATE Latin1_General_CI_AI 
	, [verbatimEventDate] = [inbo].[LCReturnVagueDateGBIF]( SA.VAGUE_DATE_START, SA.VAGUE_DATE_END , SA.VAGUE_DATE_TYPE,0) COLLATE Latin1_General_CI_AI 
	, [eventDate] = [inbo].[LCReturnVagueDateGBIF]( SA.VAGUE_DATE_START, SA.VAGUE_DATE_END , SA.VAGUE_DATE_TYPE,1) COLLATE Latin1_General_CI_AI 

--	???? other elements
	 

-- Biological Elements --
-- References Elements --
-- Curatorial Extension --
		

	, [identifiedBy] = IdentifiedBy.IdentifiedBy  COLLATE Latin1_General_CI_AI 

-- Geospatial Extension --
		
	, [decimalLatitude]  =CONVERT(Nvarchar(20),convert(decimal(12,5),round(Coalesce(SA.Lat ,0),5)) ) COLLATE Latin1_General_CI_AI 
	, [decimalLongitude] = CONVERT(Nvarchar(20),convert(decimal(12,5),round(Coalesce(SA.Long,0),5)) ) COLLATE Latin1_General_CI_AI 
	, [geodeticDatum] = CONVERT(Nvarchar(10),'WGS84') 
		
	, [coordinateUncertaintyInMeters] = '30' COLLATE Latin1_General_CI_AI  --- to check
      
	, [verbatimCoordinates] = SA.SPATIAL_REF COLLATE Latin1_General_CI_AI 
	, [verbatimCoordinateSystem] = CASE WHEN SA.SPATIAL_REF_SYSTEM = 'BD72' THEN 'Belgium Lambert 72'
										ELSE SA.SPATIAL_REF_SYSTEM 
									END COLLATE Latin1_General_CI_AI 
	, [verbatimSRS] = 'BD72' COLLATE Latin1_General_CI_AI 
		

	, [language] = N'en' COLLATE Latin1_General_CI_AI 
	, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/' COLLATE Latin1_General_CI_AI 
    , [rightsHolder] = N'INBO' COLLATE Latin1_General_CI_AI 
    , [accessRights] = N'http://www.inbo.be/en/norms-for-data-use' COLLATE Latin1_General_CI_AI 
	, [type] = CONVERT(Nvarchar(20), 'event') COLLATE Latin1_General_CI_AI  -->"Dataset" tpye
	, [datasetID] = CONVERT(Nvarchar(100),'http://dataset.inbo.be/invasive-mittencrab-occurrences') COLLATE Latin1_General_CI_AI 
	, [ownerInstitutionCode] = CONVERT(Nvarchar(20),'INBO') COLLATE Latin1_General_CI_AI 

	--, SE.[COMMENT] AS DenEchte /**om den echte te zien**/
	
-- Perqualifier
	/**, [sex] = dbo.Concatenate(1, CASE 
											WHEN MUMeas.SHORT_NAME = 'Count'  THEN CASE 
																					WHEN MQMeas.SHORT_NAME = 'Adult Man' THEN 'Adult Male'  + ': ' + taoMeas.DATA 
																					WHEN MQMeas.SHORT_NAME = 'Adult Vrouw' THEN 'Adult Female'  + ': ' + taoMeas.DATA 
																					ELSE 'undetermined'
																					END
																					
											ELSE NULL 
											END, '; ') 

	, [lifestage] = dbo.Concatenate(1, CASE 
											WHEN MUMeas.SHORT_NAME = 'Count' THEN CASE 
																					WHEN MQMeas.SHORT_NAME = 'Nimf' THEN 'Juvenile'
																					WHEN MQMeas.SHORT_NAME = 'Adult Man' THEN 'Adult Male' 
																					WHEN MQMeas.SHORT_NAME = 'Adult Vrouw' THEN 'Adult Female' 
																					ELSE  MQMeas.SHORT_NAME 
																					END
																					 + ': ' + taoMeas.DATA 
											ELSE NULL 
											END, '; ') **/

	, [individualCount]  = CASE WHEN ISNUMERIC(Meas.DATA) = 1 AND Meas.DATA <> ',' AND Meas.DataShortName = 'Count' THEN CONVERT(int , Meas.DATA) ELSE NULL END  
	
	, [continent] = 'Europe' COLLATE Latin1_General_CI_AI 
	, [INFORMAL GROUP] = NS.[INFORMAL GROUP] COLLATE Latin1_General_CI_AI 
	, [nomenclaturalCode] = CASE WHEN NS.[INFORMAL GROUP] IN ( 'varen' , 'bloemplant', 'levermos', 'mos', 'kranswier', 'paardenstaart' ) 
					THEN 'ICBN'
				WHEN NS.[INFORMAL GROUP] IN ( 'insect - nachtvlinder', 'insect - libel (Odonata)', 'insect - kokerjuffer (Trichoptera)', 'slak (Mollusca)', 'insect - wants, cicade, bladluis (Hemiptera)', 'ringworm', 'schaaldier', 'mijt (Acari)', 'insect - kever (Coleoptera)', 'spin (Araneae)')
					THEN 'ICZN'
				ELSE 'NA'
			END COLLATE Latin1_General_CI_AI 



	, [kingdom]	= CONVERT( nvarchar(50), N'Animalia' ) COLLATE Latin1_General_CI_AI 

	, [verbatimLocality] = COALESCE(CONVERT (Nvarchar(500), LN.ITEM_NAME) + ' ', '' + CONVERT (Nvarchar(4000), Sa.LOCATION_NAME)) COLLATE Latin1_General_CI_AI 

	, [verbatimLocality_new] = COALESCE(CONVERT (Nvarchar(500), LN.ITEM_NAME) + ' ', '') + COALESCE( CONVERT (Nvarchar(4000), Sa.LOCATION_NAME), '') COLLATE Latin1_General_CI_AI 

	, [locality] = CONVERT (Nvarchar(4000), Sa.LOCATION_NAME) COLLATE Latin1_General_CI_AI 
/**	, sa.[location_Name]
	, ln.[item_name]
	, sa.[location_key]
	, ln.[location_key] **/
      --- , [comment] = CONVERT (Nvarchar(500), SE.COMMENT )
	, [locationID] = CONVERT (Nvarchar(4000), Sa.LOCATION_KEY) COLLATE Latin1_General_CI_AI
	, [locationID2] = CONVERT (Nvarchar(4000), LN.LOCATION_KEY) COLLATE Latin1_General_CI_AI  
---	, ln.[item_name]
	
---	, [verbatimLocality_new2] = COALESCE(CONVERT (Nvarchar(500), LN.LOCATION_KEY) + ' ', '') + COALESCE( CONVERT (Nvarchar(4000), Sa.LOCATION_KEY), '') COLLATE Latin1_General_CI_AI 

	
	
	, [references] = dbo.[ufn_RtfToPlaintext] (SE.[COMMENT]) COLLATE Latin1_General_CI_AI
	, [vernacularName] = NormNaam.ITEM_NAME COLLATE Latin1_General_CI_AI 
	, [establishmentMeans] = 'invasive alien'
--	, [comment3] = CONVERT (Nvarchar(500), TAO.COMMENT)
---	, [samplingProtocol] = CONVERT (Nvarchar(500),ST.SHORT_NAME)
	, [samplingProtocol] = 
		CASE CONVERT (Nvarchar(500),ST.SHORT_NAME)
			WHEN 'Schietfuik' THEN 'paired fyke nets'
			WHEN 'enkele fuik' THEN 'single fike'
			ELSE ''
		END COLLATE Latin1_General_CI_AI 
		
FROM dbo.Survey S
	INNER JOIN [dbo].[Survey_event] SE ON SE.[Survey_Key] = S.[Survey_Key]
	LEFT JOIN [dbo].[Location] L ON L.[Location_Key] = SE.[Location_key]
	LEFT JOIN [dbo].[Location_Name] LN ON LN.[Location_Key] = L.[Location_Key] AND LN.[PREFERRED] = 1
	
	INNER JOIN [dbo].[SAMPLE] SA ON SA.[SURVEY_EVENT_KEY] = SE.[SURVEY_EVENT_KEY]
	LEFT JOIN [dbo].[SAMPLE_TYPE] ST ON  ST.[SAMPLE_TYPE_KEY] = SA.[SAMPLE_TYPE_KEY] 
	INNER JOIN [dbo].[TAXON_OCCURRENCE] TAO ON TAO.[SAMPLE_KEY] = SA.[SAMPLE_KEY]
		
	LEFT JOIN [dbo].[RECORD_TYPE] RT ON RT.[RECORD_TYPE_KEY] = TAO.[RECORD_TYPE_KEY]
	LEFT JOIN [dbo].[SPECIMEN] SP ON SP.[TAXON_OCCURRENCE_KEY] = TAO.[TAXON_OCCURRENCE_KEY]
	
	--IdentifiedBy
	LEFT JOIN ( SELECT TD.[TAXON_OCCURRENCE_KEY]
					, dbo.Concatenate(1, COALESCE (I.[FORENAME], I.[INITIALS] ,'') + ' ' + COALESCE (I.[SURNAME], ''), ';')  as identifiedBy
					, DT.SHORT_Name
					, DT.Long_Name
					, TD.TAXON_LIST_ITEM_KEY
					, MAX(TD.VAGUE_DATE_END) as VAGUE_DATE_END
					, MAX(TD.VAGUE_DATE_START) as VAGUE_DATE_START
					, MAX(TD.VAGUE_DATE_TYPE) as VAGUE_DATE_TYPE
				FROM [dbo].[TAXON_DETERMINATION] TD 
					LEFT JOIN [dbo].[INDIVIDUAL] I ON I.[NAME_KEY] = TD.[DETERMINER]
					LEFT JOIN [dbo].[DETERMINATION_TYPE] DT ON DT.[DETERMINATION_TYPE_KEY] = TD.[DETERMINATION_TYPE_KEY]
				WHERE 1=1
				AND TD.PREFERRED = 1 
				--AND TD.[TAXON_OCCURRENCE_KEY] = 'BFN0017900009G7Z'
				GROUP BY TD.TAXON_LIST_ITEM_KEY
					, DT.SHORT_Name
					, DT.Long_Name
					, TD.[TAXON_OCCURRENCE_KEY]
				) IdentifiedBy ON IdentifiedBy.[TAXON_OCCURRENCE_KEY] = TAO.[TAXON_OCCURRENCE_KEY] 

	
	--Taxon
	LEFT JOIN [dbo].[TAXON_LIST_ITEM] TLI ON TLI.[TAXON_LIST_ITEM_KEY] = IdentifiedBy.[TAXON_LIST_ITEM_KEY]
	LEFT JOIN [dbo].[TAXON_VERSION] TV ON TV.[TAXON_VERSION_KEY] = TLI.[TAXON_VERSION_KEY]
	LEFT JOIN [dbo].[TAXON] T ON T.[TAXON_KEY] = TV.[TAXON_KEY]
	INNER JOIN [dbo].[TAXON_RANK] TR ON TR.TAXON_RANK_KEY = TLI.TAXON_RANK_KEY

	--Normalizeren Namen 
	INNER JOIN [inbo].[NameServer_12] NS ON NS.[INBO_TAXON_VERSION_KEY] = TLI.[TAXON_VERSION_KEY]
	LEFT OUTER JOIN ( SELECT TVen.*
						, NS.INPUT_TAXON_VERSION_KEY						AS [INBO_TAXON_VERSION_KEY]
					FROM [dbo].[NameServer] NS
						 INNER JOIN dbo.TAXON_LIST_ITEM TLIVen ON TLIVen.PREFERRED_NAME = NS.RECOMMENDED_TAXON_LIST_ITEM_KEY
						 INNER JOIN dbo.TAXON_VERSION TVVen ON TVVen.TAXON_VERSION_KEY = TLIVen.TAXON_VERSION_KEY
						 INNER JOIN dbo.TAXON TVen ON TVVen.TAXON_KEY = TVen.TAXON_KEY
					WHERE TVen.[LANGUAGE] = 'nl'
				) NormNaam on NormNaam.[INBO_TAXON_VERSION_KEY] = TLI.[TAXON_VERSION_KEY]
		
	--Recorders
	LEFT JOIN ( SELECT SR.[SAMPLE_KEY]
					--, SR.SE_RECORDER_KEY, I.FORENAME, I.INITIALS, I.SURNAME
					, dbo.Concatenate(1, COALESCE(I.[FORENAME],I.[INITIALS],'') + ' ' + COALESCE(I.[SURNAME],'') ,';') as Recorders
					, dbo.Concatenate(1, I.NAME_KEY ,';') as NameKeyChain
					, Count(DISTINCT I.NAME_KEY) as NbrRecorders
				FROM [dbo].[SAMPLE_RECORDER] SR 
					LEFT JOIN [dbo].[SURVEY_EVENT_RECORDER] SER ON SER.[SE_RECORDER_KEY] = SR.[SE_RECORDER_KEY]
					LEFT JOIN dbo.INDIVIDUAL I ON I.NAME_KEY = SER.NAME_KEY
				WHERE 1=1
				--AND SR.[SAMPLE_KEY] = 'BFN0017900002RM8'
				GROUP BY SR.[SAMPLE_KEY]
				) Recorders ON Recorders.[SAMPLE_KEY] = SA.[SAMPLE_KEY]

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

	
WHERE S.[ITEM_NAME] IN ('Wolhandkrab') 

--AND NS.[RECOMMENDED_NAME_RANK] NOT IN ( 'FunGp','Agg','SppGrp' )
---AND DT.[SHORT_NAME] NOT In ('Incorrect','Invalid','Considered Incorrect','Requires Confirmation')
----AND TR.[SEQUENCE] >= 230 
--AND COALESCE(SE.COMMENT, '') <> 'waarnemingen.be (INBODATAVR88)'
--AND (CONVERT(Nvarchar(1000), SE.[COMMENT]) <> N'waarnemingen.be (INBODATAVR88)' OR SE.[COMMENT] IS NULL )
--AND (CONVERT(Nvarchar(1000), SE.[COMMENT]) <> N'VIS') 
--AND (CONVERT(Nvarchar(1000), SE.[COMMENT]) <> N'Datum nog aan te passen')


/**AND (CONVERT(Nvarchar(1000), SE.[COMMENT])  IN ( N'VIS', N'Zeeschelde', N'Diverse Locaties') OR SE.[COMMENT] IS NULL )
AND dbo.[ufn_RtfToPlaintext] (SE.[COMMENT]) NOT IN (N'Datum nog aan te passen')**/


AND (CONVERT(Nvarchar(1000), SE.[COMMENT]) NOT IN ( N'VIS', N'waarnemingen.be (INBODATAVR88)', N'Zeeschelde', N'Diverse Locaties' ) OR SE.[COMMENT] IS NULL )
AND dbo.[ufn_RtfToPlaintext] (SE.[COMMENT]) NOT IN (N'Datum nog aan te passen')

--AND TAO.[TAXON_OCCURRENCE_KEY] = 'BFN0017900009G7Z'
AND [data] <> '0'
--AND (CONVERT(Nvarchar(1000), SE.COMMENT) <> N'VIS' OR SE.COMMENT IS NULL )
--and IdentifiedBy.IdentifiedBy = 'Jan Breine'


UNION ALL

SELECT *
FROM [syno].[vis_dwh_vwGBIF_Wolhandkrab] 

GO



