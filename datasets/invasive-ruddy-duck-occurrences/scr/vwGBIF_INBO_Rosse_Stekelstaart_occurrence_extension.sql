USE [NBNData_IPT]
GO

/****** Object:  View [ipt].[vwGBIF_INBO_Rosse_stekelstaart_occurrences_extension]    Script Date: 22/06/2018 15:42:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








ALTER VIEW [ipt].[vwGBIF_INBO_Rosse_stekelstaart_occurrences_extension]
AS

SELECT 
top 100
	  

	--- RECORD ---	
	  [type] = event_core.[type]
/**	, [language] = event_core.[language]
	, [license] = event_core.[license]
	, [rightsHolder] = event_core.[rightsHolder]
	, [accessRights] = event_core.[accessRights]
	, [datasetID] = event_core.[datasetID]
	, [datasetName] = event_core.[datasetName]
	, [institutionCode] = event_core.[institutionCode]
	, [ownerInstitutionCode] = event_core.[ownerInstitutionCode]**/
	, [basisOfRecord] = N'HumanObservation'


	--- OCCURRENCE ---
	, [occurrenceID] = N'INBO:NBN:' + TAO.TAXON_OCCURRENCE_KEY
	, [recordedBy] = Recorders.NameKeyChain -- Is anonymous. If names are required, use: Recorders.Recorders
	, [individualCount] = calculatedIndividualCount
	, summaryIndividualCount
	, [sex] = 
		CASE
			WHEN calculatedSex != '' THEN '{' + calculatedSex + '}'
		END
	, [lifestage] = 
		CASE
			WHEN calculatedLifestage != '' THEN '{' + calculatedLifestage + '}'
		END
	 ,[occurrenceStatus] =
		CASE
			WHEN calculatedIndividualCount = '0' THEN 'absent'
			ELSE 'present'
		END 
	,[samplingProtocol] = event_core.[samplingProtocol]
	
	---Event
	, [eventID]= 'INBO:NBN:' + SA.[SAMPLE_KEY]
	
	--- IDENTIFICATION ---
	, [identifiedBy] = I.[NAME_KEY] -- Is anonymous. If names are required, use: IdentifiedBy.IdentifiedBy

	--- TAXON ---
 --   , [taxonID] = 
	, [scientificName] = ns.RECOMMENDED_SCIENTIFIC_NAME
	, [kingdom]	= N'Animalia'
	, [phylum] = N'Chordata'
	, [class] = N'Aves'
	, [taxonRank] = N'species'
/**	, [taxonRank] = 
		CASE
			WHEN ns.RECOMMENDED_SCIENTIFIC_NAME = 'Invasieve zomergans' THEN 'family'
			ELSE LOWER(NS.RECOMMENDED_NAME_RANK_LONG)
		END **/
	, [scientificNameAuthorship] = NS.RECOMMENDED_NAME_AUTHORITY + ISNULL ( ' ' + NS.RECOMMENDED_NAME_QUALIFIER , '') 
/**	, [nomenclaturalCode] = 
		CASE
			WHEN ns.RECOMMENDED_SCIENTIFIC_NAME = 'Invasieve zomergans' THEN ''
			ELSE N'ICZN'
		END **/
	, [vernacularName] = NormNaam.ITEM_NAME
	, [nomenclaturalCode] = 'ICZN'


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
	LEFT OUTER JOIN ( SELECT SR.[SAMPLE_KEY]
					--, SR.SE_RECORDER_KEY, I.FORENAME, I.INITIALS, I.SURNAME
					, dbo.Concatenate(1, COALESCE(I.[FORENAME],I.[INITIALS],'') + ' ' + COALESCE(I.[SURNAME],'') ,';') as Recorders
					, dbo.Concatenate(1, I.NAME_KEY ,' | ') as NameKeyChain
					, Count(DISTINCT I.NAME_KEY) as NbrRecorders
				FROM [dbo].[SAMPLE_RECORDER] SR 
					LEFT JOIN [dbo].[SURVEY_EVENT_RECORDER] SER ON SER.[SE_RECORDER_KEY] = SR.[SE_RECORDER_KEY]
					LEFT JOIN dbo.INDIVIDUAL I ON I.NAME_KEY = SER.NAME_KEY
				WHERE 1=1
				--AND SR.[SAMPLE_KEY] = 'BFN0017900002RM8'
				GROUP BY SR.[SAMPLE_KEY]
				) Recorders ON Recorders.[SAMPLE_KEY] = SA.[SAMPLE_KEY]
     --LEFT JOIN [dbo].[SAMPLE_RECORDER] SR ON SR.[SAMPLE_KEY] = SA.[SAMPLE_KEY]
	 
	 LEFT JOIN [dbo].[TAXON_DETERMINATION] TD ON TD.[TAXON_OCCURRENCE_KEY] = TAO.[TAXON_OCCURRENCE_KEY]
	 LEFT JOIN [dbo].[INDIVIDUAL] I ON I.[NAME_KEY] = TD.[DETERMINER]
	 LEFT JOIN [dbo].[DETERMINATION_TYPE] DT ON DT.[DETERMINATION_TYPE_KEY] = TD.[DETERMINATION_TYPE_KEY]


	--measurement
/**		LEFT OUTER JOIN ( SELECT taoMeas.TAXON_OCCURRENCE_KEY 
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
						) Meas on meas.TAXON_OCCURRENCE_KEY = tao.TAXON_OCCURRENCE_KEY **/

	--measurement
	LEFT OUTER JOIN (
		SELECT
			  tmp.TAXON_OCCURRENCE_KEY 
			, tmp.DataShortName
			, dbo.Concatenate (0,tmp.QualifierShortName + ':' + tmp.DATA, ';') as Data
			, dbo.Concatenate (0,
				'"' +
				CASE tmp.QualifierShortName 
					WHEN 'Gevangen' THEN 'caught' 
					WHEN 'niet Gevangen' THEN 'not caught' 
					
					ELSE tmp.QualifierShortName
				END
				+ '":' + tmp.DATA ,', ')
				AS summaryIndividualCount
			, dbo.Concatenate (0,
				'"' + 
				CASE tmp.QualifierShortName 
					WHEN 'adult man' THEN 'male' 
					WHEN 'adult vrouw' THEN 'female' 
					WHEN 'man' THEN 'male' 
					WHEN 'vrouw' THEN 'female' 
				END 
				+ '":' + tmp.DATA ,', ')
				AS calculatedSex
			, dbo.Concatenate (0,
				'"' +
				CASE tmp.QualifierShortName 
					WHEN 'Pulli' THEN 'pulli' 
					WHEN 'adult man' THEN 'adult' 
					WHEN 'adult vrouw' THEN 'adult' 
					WHEN 'subadult' THEN 'subadult'
					WHEN 'juveniel' THEN 'juvenile'
					WHEN 'Adult' THEN 'adult' 
					WHEN 'ei' THEN 'egg'
				END
				+ '":' + tmp.DATA , ', ')
				AS calculatedLifestage
			, dbo.Concatenate (0,
				'"' +
				CASE tmp.QualifierShortName 
					WHEN 'gevangen' THEN 'individualsCaught' 
					WHEN 'niet gevangen' THEN 'individualsNotCaught'
					WHEN 'nest' THEN 'numberOfNests'												 
				END
				+ '":' + tmp.DATA, ', ' )
				AS calculatedDynamicProperties

			, CASE WHEN SUM(Convert(decimal, tmp.CountGevangen)) IS NULL THEN SUM(( COALESCE(Convert(decimal, CountAdult),0) + COALESCE(Convert(decimal, CountAdultMan),0) + COALESCE(Convert(decimal, CountAdultVrouw),0) + COALESCE(Convert(decimal, CountPulli),0) + COALESCE(Convert(decimal, CountSubAdult),0) + COALESCE(Convert(decimal, CountJuveniel),0) ))
									ELSE SUM(Convert(decimal, tmp.CountGevangen)) END 
							+ SUM(COALESCE (Convert(decimal, CountNietGevangen), 0))
							+ SUM(COALESCE (Convert(decimal, CountEi), 0)) 
							+ SUM(COALESCE (Convert(decimal, CountNone), 0)) 
							as calculatedIndividualCount

						FROM ( SELECT taoMeas.TAXON_OCCURRENCE_KEY 
								, taoMeas.DATA
								, MUMeas.SHORT_NAME as DataShortName
								, MUMeas.LONG_NAME as DataLongName
								, MUMeas.[DESCRIPTION] as DataDescription
 								, MQMeas.SHORT_NAME as QualifierShortName
								, MQMeas.LONG_NAME as QualifierLongName
								, MQMeas.[DESCRIPTION] as QualifierDescription
								, Case WHEN dbo.isReallyNumeric(taoMeas.DATA) = 1 AND MQMeas.SHORT_NAME IN ('Gevangen', 'Gevangen AM', 'Gevangen AV') THEN taoMeas.DATA ELSE NULL END CountGevangen
								, Case WHEN dbo.isReallyNumeric(taoMeas.DATA) = 1 AND MQMeas.SHORT_NAME IN ('Niet Gevangen', 'Niet gevangen AV') THEN taoMeas.DATA ELSE NULL END CountNietGevangen
								, Case WHEN dbo.isReallyNumeric(taoMeas.DATA) = 1 AND MQMeas.SHORT_NAME = 'Nest' THEN taoMeas.DATA ELSE NULL END CountNest
								, Case WHEN dbo.isReallyNumeric(taoMeas.DATA) = 1 AND MQMeas.SHORT_NAME = 'None' THEN taoMeas.DATA ELSE NULL END CountNone
								, Case WHEN dbo.isReallyNumeric(taoMeas.DATA) = 1 AND MQMeas.SHORT_NAME = 'Adult' THEN taoMeas.DATA ELSE NULL END CountAdult
								, Case WHEN dbo.isReallyNumeric(taoMeas.DATA) = 1 AND MQMeas.SHORT_NAME = 'Adult Man' THEN taoMeas.DATA ELSE NULL END CountAdultMan
								, Case WHEN dbo.isReallyNumeric(taoMeas.DATA) = 1 AND MQMeas.SHORT_NAME = 'Adult Vrouw' THEN taoMeas.DATA ELSE NULL END CountAdultVrouw
								, Case WHEN dbo.isReallyNumeric(taoMeas.DATA) = 1 AND MQMeas.SHORT_NAME = 'Pulli' THEN taoMeas.DATA ELSE NULL END CountPulli
								, Case WHEN dbo.isReallyNumeric(taoMeas.DATA) = 1 AND MQMeas.SHORT_NAME = 'SubAdult' THEN taoMeas.DATA ELSE NULL END CountSubAdult
								, Case WHEN dbo.isReallyNumeric(taoMeas.DATA) = 1 AND MQMeas.SHORT_NAME IN ( 'Juveniel', 'Juveniel Vrouw', 'Juveniel Man') THEN taoMeas.DATA ELSE NULL END CountJuveniel
								, Case WHEN dbo.isReallyNumeric(taoMeas.DATA) = 1 AND MQMeas.SHORT_NAME = 'EI' THEN taoMeas.DATA ELSE NULL END CountEi

							FROM [dbo].[TAXON_OCCURRENCE_DATA] taoMeas 
								LEFT JOIN dbo.MEASUREMENT_UNIT MUMeas ON  MUMeas.MEASUREMENT_UNIT_KEY = taoMeas.MEASUREMENT_UNIT_KEY
								LEFT JOIN dbo.MEASUREMENT_QUALIFIER MQMeas ON  MQMeas.MEASUREMENT_QUALIFIER_KEY = taoMeas.MEASUREMENT_QUALIFIER_KEY
								LEFT JOIN dbo.MEASUREMENT_TYPE MTMeas ON  (MTMeas.MEASUREMENT_TYPE_KEY = MQMeas.MEASUREMENT_TYPE_KEY  )
							WHERE 1=1
							--AND tao.TAXON_OCCURRENCE_KEY = taoMeas.TAXON_OCCURRENCE_KEY
							---AND taoMeas.TAXON_OCCURRENCE_KEY IN ('BFN0017900009E2Q', 'BFN0017900009E4D','BFN0017900007NXQ','BFN0017900001YCV','BFN0017900004RE8')
							AND  MTMeas.SHORT_NAME = 'Abundance'
							)tmp
							GROUP BY tmp.TAXON_OCCURRENCE_KEY , tmp.DataShortName
						) Meas on meas.TAXON_OCCURRENCE_KEY = tao.TAXON_OCCURRENCE_KEY 
	
	INNER JOIN ipt.vwGBIF_INBO_Rosse_stekelstaart_events event_core ON event_core.eventID =  'INBO:NBN:' + SA.[SAMPLE_KEY]
	
WHERE 
S.[ITEM_NAME] IN ('Rosse Stekelstaart') 
--AND TD.[PREFERRED] = 1
--AND NS.[RECOMMENDED_NAME_RANK] NOT IN ( 'FunGp','Agg','SppGrp' )
--AND DT.[SHORT_NAME] NOT In ('Incorrect','Invalid','Considered Incorrect','Requires Confirmation')
----AND TR.[SEQUENCE] >= 230 
--AND SE.COMMENT NOT LIKE 'waarnemingen.be (INBODATAVR88)'
--AND TAO.[TAXON_OCCURRENCE_KEY] = 'BFN00179000023M5'
--AND [data] <> '0'
AND TD.[PREFERRED] = 1
--AND NS.RECOMMENDED_NAME_RANK_LONG like 'functional group'

---AND NS.RECOMMENDED_NAME_RANK_LONG like 'species hybrid'
---AND ns.RECOMMENDED_SCIENTIFIC_NAME like 'invasieve zomergans'
---AND TAO.TAXON_OCCURRENCE_KEY  in ('BFN00179000025SE', 'BFN0017900002OH3')
AND calculatedIndividualCount > 0
--Don't try to make Coordinates without numbers
AND ISNUMERIC(LEFT ( SA.SPATIAL_REF , CHARINDEX ( ',',  SA.SPATIAL_REF , 1 )-1))=1
AND CHARINDEX ( ',',  SA.SPATIAL_REF , 1 ) > 5
AND ISNUMERIC(SUBSTRING ( SA.SPATIAL_REF , CHARINDEX ( ',',  SA.SPATIAL_REF , 1 )+1 , LEN (SA.SPATIAL_REF ))) =1
-- AND ST.SHORT_NAME NOT IN ('Nestcontrole', 'nest beschrijving') **/





GO


