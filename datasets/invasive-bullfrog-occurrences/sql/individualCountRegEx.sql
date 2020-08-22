SELECT  TOP 100
      MeasureLong
	 ,[lifestage]  = SUBSTRING (MeasureLong , CHARINDEX(':', measureLong), + 2)
	 ,[individualCount1] = SUBSTRING(MeasureLong, PATINDEX('%[0-9]%', MeasureLong), LEN(MeasureLong))
	 ,[individualCount3] = right(MeasureLong, charindex(':', MeasureLong) - 1)
	 ,[individualCount] = SUBSTRING(MeasureLong, (PATINDEX('%[A-Z]-[0-9][0-9][0-9][0-9][0-9]%',[MeasureLong])),7) 
	 ,[individualCount5] = SUBSTRING (MeasureLong,0,CHARINDEX(':',MeasureLong))
	 ,[individualCount6] = SUBSTRING(MeasureLong,CHARINDEX(':',MeasureLong)+1,LEN(MeasureLong))
	  

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
						 INNER JOIN taxon_common_name TCN on TCN.taxon_list_item_key = TLIVen.taxon_list_item_key
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
---  LEFT JOIN [dbo].[SAMPLE_RECORDER] SR ON SR.[SAMPLE_KEY] = SA.[SAMPLE_KEY]
	 
	 LEFT JOIN [dbo].[TAXON_DETERMINATION] TD ON TD.[TAXON_OCCURRENCE_KEY] = TAO.[TAXON_OCCURRENCE_KEY]
	 LEFT JOIN [dbo].[INDIVIDUAL] I ON I.[NAME_KEY] = TD.[DETERMINER]
	 LEFT JOIN [dbo].[DETERMINATION_TYPE] DT ON DT.[DETERMINATION_TYPE_KEY] = TD.[DETERMINATION_TYPE_KEY]

	--measurement
		LEFT OUTER JOIN ( select  taoMeas.TAXON_OCCURRENCE_KEY
					 , dbo.Concatenate(0,COALESCE(CASE  
												---	WHEN  MQMeas.LONG_NAME LIKE 'Groeiklasse %' THEN REPLACE (MQMeas.LONG_NAME,'Groeiklasse','growth class') 
													WHEN  MQMeas.LONG_NAME LIKE 'Groeiklasse 1' THEN 'lenght < 5 cm'
													WHEN  MQMeas.LONG_NAME LIKE 'Groeiklasse 2' THEN 'lenght:5-10 cm'
													WHEN  MQMeas.LONG_NAME LIKE 'Groeiklasse 3' THEN 'lenght:10-15 cm'
													WHEN  MQMeas.LONG_NAME LIKE 'Groeiklasse 4' THEN 'lenght:15-20 cm'
													WHEN  MQMeas.LONG_NAME LIKE 'Groeiklasse 5' THEN 'lenght:20-25 cm'
													WHEN  MQMeas.LONG_NAME LIKE 'Groeiklasse 6' THEN 'lenght:25-30 cm'
													WHEN  MQMeas.LONG_NAME LIKE 'Groeiklasse 7' THEN 'lenght>30cm'
													    WHEN  MQMeas.LONG_NAME LIKE 'Larvaal stadium 00' THEN 'smallest larvae < 5cm no legs'
													   WHEN  MQMeas.LONG_NAME LIKE 'Larvaal stadium 0' THEN 'larvae no legs'
													   WHEN  MQMeas.LONG_NAME LIKE 'Larvaal stadium 1' THEN 'larvae with hind legs < 1cm'
													   WHEN  MQMeas.LONG_NAME LIKE 'Larvaal stadium 2' THEN 'larvae with hind legs > 1cm'
													   WHEN  MQMeas.LONG_NAME LIKE 'Larvaal stadium M1' THEN 'metamorph with tail'
													   WHEN  MQMeas.LONG_NAME LIKE 'Larvaal stadium M2' THEN 'metamorph without tail'
													   WHEN  MQMeas.LONG_NAME LIKE 'M1' THEN 'metamorph with tail'
													   WHEN  MQMeas.LONG_NAME LIKE 'Metamorfose 1'THEN 'metamorph with tail' 
													   WHEN  MQMeas.LONG_NAME LIKE 'Metamorfose 2'THEN 'metamorph without tail'
													 --WHEN  MQMeas.LONG_NAME LIKE 'Larvaal stadium%'THEN REPLACE (MQMeas.LONG_NAME,'Larvaal stadium', 'larval stadium') 
												     --WHEN  MQMeas.LONG_NAME LIKE 'Metamorfose 1'THEN REPLACE (MQMeas.LONG_NAME,'Metamorfose', 'metamorph with tail') 
													 --WHEN  MQMeas.LONG_NAME LIKE 'Metamorfose 2'THEN REPLACE (MQMeas.LONG_NAME,'Metamorfose', 'metamorph without tail') 
													WHEN  MQMeas.LONG_NAME LIKE 'Adult Vrouw%'THEN REPLACE (MQMeas.LONG_NAME,'Adult vrouw', 'adult female') 
													WHEN  MQMeas.LONG_NAME LIKE 'Adult Man%'THEN REPLACE (MQMeas.LONG_NAME,'Adult man', 'adult male') 
													WHEN  MQMeas.LONG_NAME LIKE 'Adult%'THEN REPLACE (MQMeas.LONG_NAME,'Adult', 'adult') 
													WHEN  MQMeas.LONG_NAME LIKE 'M'THEN REPLACE (MQMeas.LONG_NAME,'M', 'metamorph') 
													WHEN  MQMeas.LONG_NAME LIKE 'M 2'THEN REPLACE (MQMeas.LONG_NAME,'M', 'metamorph without tail') 
													WHEN  MQMeas.LONG_NAME LIKE 'None%'THEN REPLACE (MQMeas.LONG_NAME,'None', 'unknown') 
													WHEN  MQMeas.LONG_NAME LIKE 'Larve%'THEN REPLACE (MQMeas.LONG_NAME,'Larve', 'larvae') 
													WHEN  MQMeas.LONG_NAME LIKE 'Formaat onbekend%'THEN REPLACE (MQMeas.LONG_NAME,'Formaat onbekend', 'unknown')
													WHEN  MQMeas.LONG_NAME LIKE '-'THEN REPLACE (MQMeas.LONG_NAME,'Formaat onbekend', 'unknown')
													WHEN  MQMeas.LONG_NAME LIKE 'Nimf%'THEN REPLACE (MQMeas.LONG_NAME,'Nimf', 'nimph') 
													WHEN  MQMeas.LONG_NAME LIKE 'Pop%'THEN REPLACE (MQMeas.LONG_NAME,'pop', 'pupae')  
													ELSE MQMeas.LONG_NAME + 'oops' END + ':' + taoMeas.DATA, ''),' ; ') as MeasureLong
					 
					, dbo.Concatenate(0,COALESCE(MQMeas.short_NAME + ':' + taoMeas.DATA, ''),';') as Measureshort
							 from  [dbo].[TAXON_OCCURRENCE_DATA] taoMeas
				 				 
				 
				 left join dbo.MEASUREMENT_UNIT MUMeas on  MUMeas.MEASUREMENT_UNIT_KEY=taoMeas.MEASUREMENT_UNIT_KEY
				 left join dbo.MEASUREMENT_QUALIFIER MQMeas on  MQMeas.MEASUREMENT_QUALIFIER_KEY=taoMeas.MEASUREMENT_QUALIFIER_KEY
				 left join dbo.MEASUREMENT_TYPE MTMeas on  (MTMeas.MEASUREMENT_TYPE_KEY=MQMeas.MEASUREMENT_TYPE_KEY)
									
						
						where  1=1 
				--	and taoMeas.TAXON_OCCURRENCE_KEY='BFN00179000029AO' 
					and MTMeas.SHORT_NAME='Abundance'
					AND taoMeas.DATA <> '0' -- geen null occurrences

					/**AND MQMeas.LONG_NAME NOT like 'groeiklasse%'
					AND MQMeas.LONG_NAME NOT like 'Larvaal stadium%'
					AND MQMeas.LONG_NAME NOT like 'Metamorfose%'
					AND MQMeas.LONG_NAME NOT like 'Adult Vrouw%'
					AND MQMeas.LONG_NAME NOT like 'Adult Man%'
					AND MQMeas.LONG_NAME NOT like 'Adult %'
					AND MQMeas.LONG_NAME NOT IN ('M', 'None', 'Larve', 'Formaat onbekend' )**/




					GROUP BY taoMeas.TAXON_OCCURRENCE_KEY
				) Meas on meas.TAXON_OCCURRENCE_KEY = tao.TAXON_OCCURRENCE_KEY
				
				--LEFT OUTER JOIN ( SELECT taoMeas.TAXON_OCCURRENCE_KEY    --(probeersel vr de individual count er terug bij te krijgen)
				--				, taoMeas.DATA
				--				, MUMeas.SHORT_NAME as DataShortName
				--				, MUMeas.LONG_NAME as DataLongName
				--				, MUMeas.[DESCRIPTION] as DataDescription
 			--					, MQMeas.SHORT_NAME as QualifierShortName
				--				, MQMeas.LONG_NAME as QualifierLongName
				--				, MQMeas.[DESCRIPTION] as QualifierDescription 
				--			FROM [dbo].[TAXON_OCCURRENCE_DATA] taoMeas 
				--				LEFT JOIN dbo.MEASUREMENT_UNIT MUMeas ON  MUMeas.MEASUREMENT_UNIT_KEY = taoMeas.MEASUREMENT_UNIT_KEY
				--				LEFT JOIN dbo.MEASUREMENT_QUALIFIER MQMeas ON  MQMeas.MEASUREMENT_QUALIFIER_KEY = taoMeas.MEASUREMENT_QUALIFIER_KEY
				--				LEFT JOIN dbo.MEASUREMENT_TYPE MTMeas ON  (MTMeas.MEASUREMENT_TYPE_KEY = MQMeas.MEASUREMENT_TYPE_KEY )
				--			WHERE 1=1
				--			--AND taoMeas.TAXON_OCCURRENCE_KEY = 'BFN0017900009PCB'
				--			AND  MTMeas.SHORT_NAME = 'Abundance'
				--		) Meast on meas.TAXON_OCCURRENCE_KEY = tao.TAXON_OCCURRENCE_KEY 
	
WHERE S.[ITEM_NAME] IN  ('INBO - Stierkikker', 'Post - INVEXO - Stierkikker', 'INVEXO - Amerikaanse brulkikker') ----('INVEXO - Amerikaanse brulkikker')     
--AND NS.[RECOMMENDED_NAME_RANK] NOT IN ( 'FunGp','Agg','SppGrp' )
---AND DT.[SHORT_NAME] NOT In ('Incorrect','Invalid','Considered Incorrect','Requires Confirmation')
----AND TR.[SEQUENCE] >= 230 
--AND SE.COMMENT NOT LIKE 'waarnemingen.be (INBODATAVR88)'
--AND TAO.[TAXON_OCCURRENCE_KEY] in ('BFN001790000BJHA','BFN001790000BJDL','BFN001790000BJHQ','BFN001790000BJCC','BFN001790000BILV','BFN001790000BJHK','BFN001790000BISG','BFN001790000BJGF','BFN001790000BISB','BFN001790000BJHG','BFN001790000BIM0')

--AND meast.[data] <> '0'
AND (dbo.[ufn_RtfToPlaintext] (SE.[COMMENT]) NOT IN ('HYLA, Project: stierkikker 2012', 'HYLA, Project: stierkikkerproject 2010','HYLA, Project: brulkikker','HYLA, Project: stierkikker 2010', 'HYLA', 'HYLA, Project: stierkikker 2011 ', 'HYLA, Project: stierkikker 2013 ','waarnemingen.be || Precisie: 10 m ','waarnemingen.be || Precisie: 100 m ','waarnemingen.be || Precisie: 1000 m ','waarnemingen.be || Precisie: 5 m ','waarnemingen.be || Precisie: 50 m ','waarnemingen.be || Precisie: 657 m ','waarnemingen.be || Precisie: 999 m ') 
OR SE.COMMENT IS NULL)
--AND preferred_name like 'Rana%'
AND TD.PREFERRED = 1
--AND ns.RECOMMENDED_SCIENTIFIC_NAME like 'Lithobates catesbeianus'



/* GVS, 14/07/2015, no need to join with spatial
	AND ISNUMERIC(LEFT ( SA.SPATIAL_REF , CHARINDEX ( ',',  SA.SPATIAL_REF , 1 )-1))=1
		AND CHARINDEX ( ',',  SA.SPATIAL_REF , 1 ) > 5
	AND ISNUMERIC(SUBSTRING ( SA.SPATIAL_REF , CHARINDEX ( ',',  SA.SPATIAL_REF , 1 )+1 , LEN (SA.SPATIAL_REF ))) =1
*/

/*
GROUP BY 

	 TAO.[TAXON_OCCURRENCE_KEY]	
	    , SE.survey_key
		, S. [ITEM_NAME] 	
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
		, COALESCE (I.[FORENAME], I.[INITIALS] ,'') + ' ' + COALESCE (I.[SURNAME], '') 
		, CONVERT(Nvarchar(20),convert(decimal(12,5),round(Coalesce(SA.Lat ,0),5)) ) 
		, CONVERT(Nvarchar(20),convert(decimal(12,5),round(Coalesce(SA.Long,0),5)) )

		, SA.SPATIAL_REF
		, CASE WHEN SA.SPATIAL_REF_SYSTEM = 'BD72' THEN 'Belgium Lambert 72'
										ELSE SA.SPATIAL_REF_SYSTEM 
									END
		, CONVERT (Nvarchar(500), LN.ITEM_NAME)
		, CONVERT (Nvarchar(4000), Sa.LOCATION_NAME )
	--	, SE.COMMENT
		, dbo.[ufn_RtfToPlaintext] (SE.[COMMENT])
		, I.[NAME_KEY]
		, TVen.ITEM_NAME
		, CONVERT (Nvarchar(500), SE.COMMENT )
		, CONVERT (Nvarchar(500), TAO.COMMENT )
		, CONVERT (Nvarchar(500),ST.SHORT_NAME)
		, Recorders.NameKeyChain 
		, Recorders.Recorders 
*/
--ORDER BY dbo.[ufn_RecordersPerSample](SA.[SAMPLE_KEY])

;
































GO
