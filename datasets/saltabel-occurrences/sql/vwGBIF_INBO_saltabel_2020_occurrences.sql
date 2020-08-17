USE [D0017_00_NBNData]
GO

/****** Object:  View [ipt].[vwGBIF_Saltabel_2020]    Script Date: 17/08/2020 11:30:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--SELECT * FROM Survey WHERE ITEM_NAME LIKE '%Saltabel%'


/**ALTER VIEW [ipt].[vwGBIF_Saltabel_2020]
AS**/


/*********************************************************/
/*
	Changes ON 20130807
	
	20130910 => remove Confidential data
	20130911 => Opmerkingen van den Dimi
			  => Type afhankelijk van RT.SHORT_
			  => CoordinatenUncertaintyInMeters => depending on original UTM square-size
	20130918 => RecordedBy with a custom separator char
			  => Corrected Typo's
	20131001 => Rights Changed to "http://creativecommons.org/publicdomain/zero/1.0/ & http://www.canadensys.net/norms"
	20140206 => Collectiereferenties toegevoegd.
	20150813 => accesrights, licence, occurrenceID

	-- Modif 20150908 => Eventdate to Single date ( no range ), range => [verbatimEventDate]

	20200731 => Refresh query
		no [modified]
		re order
		fix datasetID


*/
/*********************************************************/


SELECT  

   ---RECORD ---

		  [occurrenceID] = 'INBO:NBN:' + TAO.TAXON_OCCURRENCE_KEY
			

		
		, [Type] = CASE WHEN RT.SHORT_NAME  IN ('auditory record', 'reference/auditory record' ) THEN 'sound'
						WHEN RT.SHORT_NAME  IN ( 'field record/photographed', '' ) THEN 'stillImage'
						WHEN RT.SHORT_NAME  IN ( 'Collection/auditory record', 'Collection', 'Collection/field record', 'Collection/reference') THEN 'physicalObject'
						WHEN RT.SHORT_NAME  IN ( 'Reference' ) THEN 'text'
						WHEN RT.SHORT_NAME  IN ( 'field record', 'None', 'reported to recorder', 'trapped in Malaise trap' ) THEN 'event'
						ELSE 'Unknown' END 
        , [Language] = CONVERT(Nvarchar(20),'en')
		, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
		, [RightsHolder] =  CONVERT(Nvarchar(20),'INBO')
		, [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
	    , [DatasetID] = CONVERT(Nvarchar(100),'https://doi.org/10.15468/1rcpsq')
	    , [DatasetName] = CONVERT(Nvarchar(200),S.ITEM_NAME) + ' - Orthoptera in Belgium' 
		, [InstitutionCode] = CONVERT(Nvarchar(20),'INBO') 
		, [dataGeneralizations] = CONVERT(Nvarchar(100),'Coordinate Uncertainty In Meters depends on original UTM1 or UTM5 squares.')

		

		---EVENT---	

		, [BasisOfRecord] = CASE  WHEN RT.SHORT_NAME  IN ('Collection', 'Collection/auditory record', 'Collection/field record', 'Collection/reference' ) THEN 'preservedSpecimen'
						  WHEN RT.SHORT_NAME  IN ('field record', 'field record/photographed', 'None' ) THEN 'humanObservation'
						  ELSE 'HumanObservation' 
						  END
		, [EventDate] = [inbo].[LCReturnVagueDateGBIF]( SA.VAGUE_DATE_START, SA.VAGUE_DATE_END , SA.VAGUE_DATE_TYPE, 1) 
		, [verbatimEventDate] = [inbo].[LCReturnVagueDateGBIF]( SA.VAGUE_DATE_START, SA.VAGUE_DATE_END , SA.VAGUE_DATE_TYPE, 0)
		--, [eventRemarks] = 'nog iets zinnigs toe te voegen?' 
		
---- LOCATION -----
		
		, [continent] = N'Europe'
	    , [countryCode] = N'BE'
		, [Municipality] = CONVERT (Nvarchar(500), LN.ITEM_NAME)
		, [decimalLatitude]  =CONVERT(Nvarchar(20),convert(decimal(12,5),round(Coalesce(SA.Lat ,0),5)) ) 
		, [decimalLongitude] = CONVERT(Nvarchar(20),convert(decimal(12,5),round(Coalesce(SA.Long,0),5)) )
		, [geodeticDatum] = CONVERT(Nvarchar(10),'WGS84') 
		, [verbatimSRS] = N'WGS84'
		, [REFgrid] = SA.SPATIAL_REF_QUALIFIER
	    , [CoordinateUncertaintyInMeters] = convert(nvarchar(5),coalesce(case
																	WHEN SA.SPATIAL_REF_QUALIFIER = 'Centrd UTM5 x dgmnte' THEN '3536'
																	WHEN SA.SPATIAL_REF_QUALIFIER='Centroïd deelgemnte' THEN '3536'
																	WHEN SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 1 km' THEN '707.1'
																	WHEN SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 5 km' THEN '3536'
																	WHEN SA.SPATIAL_REF_QUALIFIER='XY from original rec' THEN '30'
                                                                    when SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 100m' then '70.71'
                                                                    when SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 1km' then '707.1'
                                                                    when SA.SPATIAL_REF_QUALIFIER='centroïd UTM 5km' then '3536'
                                                                    when SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 10km' then '7071'
                                                                    when SA.SPATIAL_REF_QUALIFIER='XY from original rec' then '30'
                                                                    else null
                                                                    end,'70.71')) 
		, [georeferenceRemarks] =  SA.SPATIAL_REF_QUALIFIER + ' square'

---- OCCURRENCE ---
        , [CatalogNumber] = TAO.TAXON_OCCURRENCE_KEY 
        , [recordedBy] = CASE WHEN inbo.[ufn_RecordersPerSample](SA.[SAMPLE_KEY], ' | ') = 'Unknown' THEN NULL 
							ELSE inbo.[ufn_RecordersPerSample](SA.[SAMPLE_KEY], ' | ')
							END  
		, [IndividualCount]  = SUM (CASE WHEN ISNUMERIC(taoMeas.DATA) = 1 AND MUMeas.SHORT_NAME = 'Count' THEN CONVERT(int , taoMeas.DATA) ELSE NULL END ) 
		, [sex] = dbo.Concatenate(1, CASE 
										WHEN MUMeas.SHORT_NAME = 'Count'  THEN CASE 
																			WHEN MQMeas.SHORT_NAME IN ('Adult Man', 'Man') THEN 'male'  --+ ': ' + taoMeas.DATA 
																			WHEN MQMeas.SHORT_NAME IN ('Adult Vrouw', 'Vrouw') THEN 'female' -- + ': ' + taoMeas.DATA 
																			ELSE NULL
																			END
																					
											ELSE NULL 
											END, ' | ')
	    , [Lifestage] = dbo.Concatenate(1, CASE 
											WHEN MUMeas.SHORT_NAME = 'Count' THEN CASE 
																				WHEN MQMeas.SHORT_NAME in ('Nimf', 'juviniel', 'juveniel') THEN 'juvenile'
																				WHEN MQMeas.SHORT_NAME in ('Nimf', 'juveniel') THEN 'nymph'
																				WHEN MQMeas.SHORT_NAME IN ('Vrouw', 'Man', 'none', 'Adult Vrouw', 'Adult Man') THEN 'adult' 
																				WHEN MQMeas.SHORT_NAME IN ('none') THEN NULL 
																				ELSE  MQMeas.SHORT_NAME 
																				END
																					-- + ': ' + taoMeas.DATA
											ELSE NULL 
											END, ' | ')


-----Identification----

		, [IdentifiedBy] = CASE WHEN LTRIM(RTRIM(COALESCE (RTRIM(LTRIM(I.[FORENAME])), RTRIM(LTRIM(I.[INITIALS])) ,'') + ' ' + COALESCE (RTRIM(LTRIM(I.[SURNAME])), ''))) = 'Unknown' THEN NULL
							ELSE LTRIM(RTRIM(COALESCE (RTRIM(LTRIM(I.[FORENAME])), RTRIM(LTRIM(I.[INITIALS])) ,'') + ' ' + COALESCE (RTRIM(LTRIM(I.[SURNAME])), ''))) 
							END

---- Taxonomic Elements --
		
		--[originalNameUsage] = T.ITEM_NAME,
		, [ScientificName] = ns.RECOMMENDED_SCIENTIFIC_NAME     --recommended scientific soort + genus 
		, [scientificNameAuthorship] = NS.RECOMMENDED_NAME_AUTHORITY + ISNULL ( ' ' + NS.RECOMMENDED_NAME_QUALIFIER , '') 
		, lower(NS.RECOMMENDED_NAME_RANK_LONG) AS taxonRank  
		, [Kingdom]	= CONVERT( nvarchar(50), N'Animalia' )
	    , [Phylum]	= CONVERT( nvarchar(50), N'Arthropoda' )
	    , [Class]	= CONVERT( nvarchar(50), N'Insecta' )
	    , [Order]	= CONVERT( nvarchar(50), N'Ortopthera' )
		, [NomenclaturalCode] = 'ICZN'
		
	
-- Perqualifier
	
		
	
	
	
	
	
	, Case WHEN ( Left(Convert(Varchar(max), [TAO].COMMENT),7) = '{\rtf1\') THEN dbo.ufn_RtfToPlaintext(Convert(Varchar(max), [TAO].COMMENT))  
		ELSE Convert(Varchar(max), [TAO].COMMENT) 
		END as Comment
	, LTRIM(RTRIM(TAOC.[Collection])) as collectionCode


FROM dbo.Survey S
	INNER JOIN [dbo].[Survey_event] SE ON SE.[Survey_Key] = S.[Survey_Key]
	LEFT JOIN [dbo].[Location] L ON L.[Location_Key] = SE.[Location_key]
	LEFT JOIN [dbo].[Location_Name] LN ON LN.[Location_Key] = L.[Location_Key] 
	
	INNER JOIN [dbo].[SAMPLE] SA ON SA.[SURVEY_EVENT_KEY] = SE.[SURVEY_EVENT_KEY]
	LEFT JOIN [dbo].[SAMPLE_TYPE] ST ON  ST.[SAMPLE_TYPE_KEY] = SA.[SAMPLE_TYPE_KEY] 
	INNER JOIN [dbo].[TAXON_OCCURRENCE] TAO ON TAO.[SAMPLE_KEY] = SA.[SAMPLE_KEY]
	LEFT OUTER JOIN (SELECT TAOC.TAXON_OCCURRENCE_KEY
										, RTRIM(LTRIM(spl.Value)) as [TrimmedComment]
										, Substring(RTRIM(LTRIM(spl.Value)), CHARINDEX(':', spl.Value, 1) + 1, LEN(spl.Value)) as [Collection]
									FROM dbo.TAXON_OCCURRENCE TAOC
										OUTER APPLY [inbo].[udf_SplitString] (COALESCE(Case WHEN ( Left(Convert(Varchar(max), [TAOC].COMMENT),7) = '{\rtf1\') THEN dbo.ufn_RtfToPlaintext(Convert(Varchar(max), [TAOC].COMMENT))  
																												ELSE Convert(Varchar(max), [TAOC].COMMENT) 
																												END,'') , '||', 2000)  as spl
									WHERE 1=1
									AND RTRIM(LTRIM(spl.Value)) <> ''
									AND LEFT(spl.Value, LEN('Collection')) = 'Collection') TAOC ON TAOC.[TAXON_OCCURRENCE_KEY] = TAO.[TAXON_OCCURRENCE_KEY]


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
	
	-->Common name nog opzoeken...
	
	--Recorders
	--LEFT JOIN [dbo].[SAMPLE_RECORDER] SR ON SR.[SAMPLE_KEY] = SA.[SAMPLE_KEY]

	    LEFT JOIN [dbo].[TAXON_OCCURRENCE_DATA] taoMeas ON  taoMeas.TAXON_OCCURRENCE_KEY = tao.TAXON_OCCURRENCE_KEY
        
        LEFT JOIN dbo.MEASUREMENT_UNIT MUMeas ON  MUMeas.MEASUREMENT_UNIT_KEY = taoMeas.MEASUREMENT_UNIT_KEY 
											AND MUMeas.SHORT_NAME = 'Count' --> individualcount
        LEFT JOIN dbo.MEASUREMENT_QUALIFIER MQMeas ON  MQMeas.MEASUREMENT_QUALIFIER_KEY = taoMeas.MEASUREMENT_QUALIFIER_KEY
        LEFT JOIN dbo.MEASUREMENT_TYPE MTMeas ON  (MTMeas.MEASUREMENT_TYPE_KEY = MQMeas.MEASUREMENT_TYPE_KEY 
											AND  MTMeas.SHORT_NAME = 'Abundance') -- 
	
WHERE S.[ITEM_NAME] =  'Saltabel'

AND ISNUMERIC (Substring(LN.[ITEM_NAME],2,1)) = 0
AND TD.[PREFERRED] = 1
AND NS.[RECOMMENDED_NAME_RANK] NOT IN ( 'FunGp','Agg','SppGrp' )
AND DT.[SHORT_NAME] NOT In ('Incorrect','Invalid','Considered Incorrect','Requires Confirmation')
AND TR.[SEQUENCE] >= 230 
	AND ISNUMERIC(LEFT ( SA.SPATIAL_REF , CHARINDEX ( ',',  SA.SPATIAL_REF , 1 )-1))=1
		AND CHARINDEX ( ',',  SA.SPATIAL_REF , 1 ) > 5
	AND ISNUMERIC(SUBSTRING ( SA.SPATIAL_REF , CHARINDEX ( ',',  SA.SPATIAL_REF , 1 )+1 , LEN (SA.SPATIAL_REF ))) =1
--AND dbo.[ufn_RecordersPerSample](SA.[SAMPLE_KEY]) <> 'Jo Packet'
AND LN.PREFERRED = 1
AND TAO.CONFIDENTIAL = 0 
GROUP BY TAO.[TAXON_OCCURRENCE_KEY]		
		, LN.[ITEM_NAME]
		, RT.[SHORT_NAME]
		, CONVERT(Nvarchar(200),S.[ITEM_NAME]) 
		, T.[ITEM_NAME] 
		, NS.[RECOMMENDED_SCIENTIFIC_NAME] 
		, NS.RECOMMENDED_NAME_AUTHORITY + ISNULL ( ' ' + NS.RECOMMENDED_NAME_QUALIFIER , '')
		, NS.[RECOMMENDED_NAME_RANK] 
		, NS.[RECOMMENDED_NAME_RANK_LONG] 
		, RT.[SHORT_NAME] 
		, SA.[VAGUE_DATE_START], SA.[VAGUE_DATE_END] , SA.[VAGUE_DATE_TYPE]
		, SA.[SAMPLE_KEY]
		, COALESCE (RTRIM(LTRIM(I.[FORENAME])), RTRIM(LTRIM(I.[INITIALS])) ,'') + ' ' + COALESCE (RTRIM(LTRIM(I.[SURNAME])), '')  
		, CONVERT(Nvarchar(20),convert(decimal(12,5),round(Coalesce(SA.Lat ,0),5)) ) 
		, CONVERT(Nvarchar(20),convert(decimal(12,5),round(Coalesce(SA.Long,0),5)) )
		, SA.SPATIAL_REF
		, CASE WHEN SA.SPATIAL_REF_SYSTEM = 'BD72' THEN 'Lambert 72'
										ELSE SA.SPATIAL_REF_SYSTEM 
									END
		, CONVERT (Nvarchar(500), LN.ITEM_NAME)
		, SA.SPATIAL_REF_QUALIFIER
		, convert(nvarchar(5),coalesce(case
                                                                      when SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 100m' then '70.71'
                                                                      when SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 1km' then '707.1'
                                                                      when SA.SPATIAL_REF_QUALIFIER='centroïd UTM 5km' then '3536'
                                                                      when SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 10km' then '7071'
                                                                      when SA.SPATIAL_REF_QUALIFIER='XY from original rec' then '30'
                                                                      else null
                                                                  end,'70.71'))
		, Case WHEN ( Left(Convert(Varchar(max), [TAO].COMMENT),7) = '{\rtf1\') THEN dbo.ufn_RtfToPlaintext(Convert(Varchar(max), [TAO].COMMENT))  
		ELSE Convert(Varchar(max), [TAO].COMMENT) 
		END 
		, TAOC.[Collection]
--ORDER BY dbo.[ufn_RecordersPerSample](SA.[SAMPLE_KEY])

;



/*
SELECT * 
FROM SURVEY where ITEM_NAME lIKE '%Loop%'

SELECT * FROM [ipt].[vwGBIF_Saltabel]

SELECT * FROM dbo.SAMPLE WHERE Sample_KEY = 'BFN00179000025XV'

SELECT * FROM dbo.TAXON_OCCURRENCE WHERE TAXON_OCCURRENCE_KEY = 'BFN0017900007XT2'

*/























GO


