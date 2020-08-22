USE [D0017_00_NBNData]
GO

/****** Object:  View [ipt].[vwGBIF_INBO_visschade_pompgemalen_occurrences]    Script Date: 25/01/2019 16:45:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [ipt].[vwGBIF_INBO_visschade_pompgemalen_occurrences]
AS


/*********************************************************/
/*
	Changes on 20170505
	forked from Odonata occurrences
	
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
	Info: Based on Chinese Mitten Crab Query
	Updated on 20170115
	finished on 20170116
	2019-01_25 Adapt to pompgemalen   
*/
/*********************************************************/

SELECT  
	  
	  [eventID] = SA.[SAMPLE_KEY] COLLATE Latin1_General_CI_AI 

--Record level

	, [type] = CONVERT(Nvarchar(20), 'event') COLLATE Latin1_General_CI_AI  -->"Dataset" tpye
	, [language] = N'en' COLLATE Latin1_General_CI_AI 
	, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/' COLLATE Latin1_General_CI_AI 
    , [rightsHolder] = N'INBO' COLLATE Latin1_General_CI_AI 
    , [accessRights] = N'http://www.inbo.be/en/norms-for-data-use' COLLATE Latin1_General_CI_AI 
	
	, [datasetID] = CONVERT(Nvarchar(100),'http://dataset.inbo.be/PINK-amphibia-occurrences') COLLATE Latin1_General_CI_AI 
	, [institutionCode] = CONVERT(Nvarchar(20),'INBO') COLLATE Latin1_General_CI_AI 
	, [datasetName] = 'PINK-permanent inventarisation of coastal areas: Amphibia'  --CONVERT(Nvarchar(200),S.ITEM_NAME) +COLLATE Latin1_General_CI_AI 
	, [ownerInstitutionCode] = CONVERT(Nvarchar(20),'INBO') COLLATE Latin1_General_CI_AI 
	, [basisOfRecord] = CONVERT(Nvarchar(20),'HumanObservation') COLLATE Latin1_General_CI_AI 
	

--Occurrence
	
	, [occurrenceID] =  CONVERT(Nvarchar(500),'INBO:NBN:' + TAO.TAXON_OCCURRENCE_KEY )COLLATE Latin1_General_CI_AI 
---	, [occurrenceRemarks] = CONVERT (Nvarchar(500), TAO.COMMENT) COLLATE Latin1_General_CI_AI
	
	                      /**CASE WHEN 
	                         CONVERT (Nvarchar(500), TAO.COMMENT)='Tandems gezien, niet geteld' THEN 'mating wheel observed, not counted'
							ELSE CONVERT (Nvarchar(500), TAO.COMMENT)
							END **/ 
	
	, [recordedBy] = Recorders.NameKeyChain COLLATE Latin1_General_CI_AI 
	--, Meas2.[individualCount] 
	, Meas.[Data] as individualCount
	 
/**	, [sex2]
	, Meas2.individualCount
	
	
	, [lifestage] = sex
	, [behaviour] = CASE WHEN 
	                         CONVERT (Nvarchar(500), TAO.COMMENT)='Tandems gezien, niet geteld' THEN 'mating wheel observed, not counted'
							ELSE CONVERT (Nvarchar(500), TAO.COMMENT)
							END **/
	, [occurrenceStatus] = 'present'
	, [lifestage] = CASE WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'Larve' THEN 'larvae'
						 WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'Ei' THEN 'egg'	
						 WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'Adult Man' THEN 'Adult'
						 WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'Adult Vrouw' THEN 'Adult'
						 WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'Juveniel' THEN 'juvenile'
						 WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'None' THEN 'unknown'		
							ELSE CONVERT (Nvarchar(500), Meas.QualifierShortName)
							END 

	, [sex] = CASE WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'Larve' THEN 'unknown'
						 WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'Ei' THEN 'unknown'	
						 WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'Adult Man' THEN 'male'
						 WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'Adult Vrouw' THEN 'female'
						 WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'Juveniel' THEN 'unknown'
						 WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'Adult' THEN 'unknown'
						 WHEN CONVERT (Nvarchar(500), Meas.QualifierShortName) = 'None' THEN 'unknown'		
							ELSE CONVERT (Nvarchar(500), Meas.QualifierShortName)
							END 
						
		
-- Organism --
	
	, [identifiedBy] = IdentifiedBy.IdentifiedBy  COLLATE Latin1_General_CI_AI 
	, [scientificName] = ns.RECOMMENDED_SCIENTIFIC_NAME  COLLATE Latin1_General_CI_AI    --recommended scientific soort + genus 
	, [kingdom]	= CONVERT( nvarchar(50), N'Animalia' ) COLLATE Latin1_General_CI_AI 
	, [taxonRank] = lower(NS.RECOMMENDED_NAME_RANK_LONG) COLLATE Latin1_General_CI_AI  
	, [scientificNameAuthorship] = NS.RECOMMENDED_NAME_AUTHORITY + ISNULL ( ' ' + NS.RECOMMENDED_NAME_QUALIFIER , '') COLLATE Latin1_General_CI_AI 
	, [nomenclaturalCode] = CASE WHEN NS.[INFORMAL GROUP] IN ( 'varen' , 'bloemplant', 'levermos', 'mos', 'kranswier', 'paardenstaart' ) 
					THEN 'ICBN'
				WHEN NS.[INFORMAL GROUP] IN ('beenvis (Actinopterygii)' ,'insect - nachtvlinder', 'amfibie', 'insect - libel (Odonata)', 'insect - kokerjuffer (Trichoptera)', 'slak (Mollusca)', 'insect - wants, cicade, bladluis (Hemiptera)', 'ringworm', 'schaaldier', 'mijt (Acari)', 'insect - kever (Coleoptera)', 'spin (Araneae)')
					THEN 'ICZN'
				ELSE 'NA'
			END COLLATE Latin1_General_CI_AI 
    , [vernacularName] = NormNaam.ITEM_NAME COLLATE Latin1_General_CI_AI 
    , NS.[INFORMAL GROUP]
 	

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
/*
      INNER JOIN (SELECT taoMeas.TAXON_OCCURRENCE_KEY 
					, dbo.Concatenate (1, Coalesce ( MUMeas.SHORT_NAME + ':' + taoMeas.DATA + '(' + MQMeas.SHORT_NAME + ')', ''), ';') as IetCompleetFerkiët
					, dbo.Concatenate (1, Coalesce (CASE MQMeas.SHORT_NAME 
										WHEN 'Adult Vrouw' then 'adult female'
										WHEN 'Adult Man' then 'adult male'
										WHEN 'Adult' then 'adult'
										WHEN 'None' then 'not known'
										ELSE 'undetermined' 
										END , '')+ ':' + taoMeas.DATA , '; ') as sex2
					, SUM ( CONVERT(integer, CASE WHEN [dbo].[udf_isReallyInteger] ( taoMeas.DATA) = 1 then taoMeas.DATA else null end ) ) as individualCount
							FROM [dbo].[TAXON_OCCURRENCE_DATA] taoMeas 
								INNER JOIN dbo.MEASUREMENT_UNIT MUMeas ON  MUMeas.MEASUREMENT_UNIT_KEY = taoMeas.MEASUREMENT_UNIT_KEY
								INNER JOIN dbo.MEASUREMENT_QUALIFIER MQMeas ON  MQMeas.MEASUREMENT_QUALIFIER_KEY = taoMeas.MEASUREMENT_QUALIFIER_KEY
								INNER JOIN dbo.MEASUREMENT_TYPE MTMeas ON  (MTMeas.MEASUREMENT_TYPE_KEY = MQMeas.MEASUREMENT_TYPE_KEY )
							WHERE 1=1
							--AND taoMeas.TAXON_OCCURRENCE_KEY = 'BFN0017900009PCB'
							--AND TAXON_OCCURRENCE_KEY IN ('BFN001790000A60F', 'BFN001790000A60G', 'BFN001790000A60J', 'BFN001790000A60N')
							AND  MTMeas.SHORT_NAME = 'Abundance'
							GROUP BY taoMeas.TAXON_OCCURRENCE_KEY 
							) Meas2 on meas2.TAXON_OCCURRENCE_KEY = tao.TAXON_OCCURRENCE_KEY 
		*/
	
WHERE S.[ITEM_NAME] IN ('Visschade pompgemalen') 


--AND Meas2.individualCount <> '0'

---AND TAO.COMMENT not like 'NULL' 


--debiugging :-)
--AND  TAO.TAXON_OCCURRENCE_KEY IN ('BFN001790000A60F', 'BFN001790000A60G', 'BFN001790000A60J', 'BFN001790000A60N')
--ORDER BY  TAO.TAXON_OCCURRENCE_KEY
;



-- ChangeDate : 20130807
-- MOdif : New VagueDatum calculation up closer to Iso Standard
-- Modif 20150908 => Eventdate to Single date ( no range ), range => [verbatimEventDate]
















GO


