USE [D0017_00_NBNData]
GO

/****** Object:  View [ipt].[vwGBIF_Saltabel_2020]    Script Date: 9/09/2020 9:56:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





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
		ADD UTM squares
		ADD verbatimLAt verbatim long
		Deleted 4 records (doubles, only different UTM square)

	20200828 => remove group by on total query, todo solve the sex - count distinct problem  
*/
/*********************************************************/


SELECT  

   ---RECORD ---

		  [occurrenceID] = 'INBO:NBN:' + TAO.TAXON_OCCURRENCE_KEY
			

		
		, [type] = CASE WHEN RT.SHORT_NAME  IN ('auditory record', 'reference/auditory record' ) THEN 'Sound'
						WHEN RT.SHORT_NAME  IN ( 'field record/photographed', '' ) THEN 'StillImage'
						WHEN RT.SHORT_NAME  IN ( 'Collection/auditory record', 'Collection', 'Collection/field record', 'Collection/reference') OR TAOC.[Collection] is not NULL THEN 'PhysicalObject'
						WHEN RT.SHORT_NAME  IN ( 'Reference' ) THEN 'Text'
						WHEN RT.SHORT_NAME  IN ( 'field record', 'None', 'reported to recorder', 'trapped in Malaise trap' ) THEN 'Event'
						ELSE 'Unknown' END 
        , [language] = CONVERT(Nvarchar(20),'en')
		, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
		, [rightsHolder] =  CONVERT(Nvarchar(20),'INBO')
		, [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
	    , [datasetID] = CONVERT(Nvarchar(100),'https://doi.org/10.15468/1rcpsq')
	    , [datasetName] = CONVERT(Nvarchar(200),S.ITEM_NAME) + ' - Orthoptera in Belgium' 
		, [institutionCode] = CONVERT(Nvarchar(20),'INBO') 
			

		---EVENT---	

		, [basisOfRecord] = CASE	WHEN RT.SHORT_NAME  IN ('Collection', 'Collection/auditory record', 'Collection/field record', 'Collection/reference' )  OR TAOC.[Collection] is not NULL THEN 'PreservedSpecimen'
									WHEN RT.SHORT_NAME  IN ('field record', 'field record/photographed', 'None' ) THEN 'HumanObservation'
									ELSE 'HumanObservation' 
									END
		, [eventDate] = CASE  [inbo].[LCReturnVagueDateGBIF]( SA.VAGUE_DATE_START, SA.VAGUE_DATE_END , SA.VAGUE_DATE_TYPE, 0)  --1 changed to 0 for dateranges
								WHEN 'unknown' then NULL
								ELSE [inbo].[LCReturnVagueDateGBIF]( SA.VAGUE_DATE_START, SA.VAGUE_DATE_END , SA.VAGUE_DATE_TYPE, 0)
								END
	
			
---- LOCATION -----
		
		, [continent] = N'Europe'
	    , [countryCode] = N'BE'
		, [municipality] = CONVERT (Nvarchar(500), LN.ITEM_NAME)
		, [decimalLatitude]  =CONVERT(Nvarchar(20),convert(decimal(12,5),round(Coalesce(SA.Lat ,0),5)) ) 
		, [decimalLongitude] = CONVERT(Nvarchar(20),convert(decimal(12,5),round(Coalesce(SA.Long,0),5)) )
		, [geodeticDatum] = CONVERT(Nvarchar(10),'WGS84') 
		, [verbatimcoordinates] = CASE SA.SPATIAL_REF_QUALIFIER  
							WHEN 'Centrd UTM5 x dgmnte' THEN NULL                --sa.SPATIAL_REF
							WHEN 'Centroïd deelgemnte'  THEN NULL --sa.SPATIAL_REF  --  THEN CONVERT(Nvarchar(20),ROUND(sa.SPATIAL_REF,2))
							WHEN 'Centroïd UTM 1 km' THEN '31U' + SDA.DATA
							WHEN 'Centroïd UTM 5 km' THEN '31U' + SDA.DATA
							WHEN 'Imported' THEN NULL -- sa.SPATIAL_REF
							WHEN 'XY from original rec' THEN NULL --sa.SPATIAL_REF
							ELSE SA.SPATIAL_REF
							END
		, [verbatimLongitude] = CASE  SA.SPATIAL_REF_QUALIFIER 
							WHEN 'Centrd UTM5 x dgmnte' THEN ROUND (substring(sa.spatial_REF, 1,charindex(',',sa.SPATIAL_REF)-1),0)                --sa.SPATIAL_REF
							WHEN 'Centroïd deelgemnte'  THEN ROUND (substring(sa.spatial_REF, 1,charindex(',',sa.SPATIAL_REF)-1),0)                --sa.SPATIAL_REF  --  THEN CONVERT(Nvarchar(20),ROUND(sa.SPATIAL_REF,2))
							WHEN 'Centroïd UTM 1 km'    THEN NULL  --SDA.DATA
							WHEN 'Centroïd UTM 5 km'    THEN NULL  --SDA.DATA
							WHEN 'Imported'             THEN ROUND (substring(sa.spatial_REF, 1,charindex(',',sa.SPATIAL_REF)-1),0)               -- sa.SPATIAL_REF
							WHEN 'XY from original rec' THEN ROUND (substring(sa.spatial_REF, 1,charindex(',',sa.SPATIAL_REF)-1),0)               --sa.SPATIAL_REF
							ELSE SA.SPATIAL_REF
							END					
		, [verbatimLatitude] = CASE  SA.SPATIAL_REF_QUALIFIER 
							WHEN 'Centrd UTM5 x dgmnte' THEN ROUND ((substring(sa.spatial_REF, charindex(',',sa.SPATIAL_REF) +1 ,11)),0)           --sa.SPATIAL_REF
							WHEN 'Centroïd deelgemnte'  THEN ROUND ((substring(sa.spatial_REF, charindex(',',sa.SPATIAL_REF) +1 ,11)),0)           --sa.SPATIAL_REF  --  THEN CONVERT(Nvarchar(20),ROUND(sa.SPATIAL_REF,2))
							WHEN 'Centroïd UTM 1 km'    THEN NULL  --SDA.DATA
							WHEN 'Centroïd UTM 5 km'    THEN NULL  --SDA.DATA
							WHEN 'Imported'             THEN ROUND ((substring(sa.spatial_REF, charindex(',',sa.SPATIAL_REF) +1 ,11)),0)           -- sa.SPATIAL_REF
							WHEN 'XY from original rec' THEN ROUND ((substring(sa.spatial_REF, charindex(',',sa.SPATIAL_REF) +1 ,11)),0)           --sa.SPATIAL_REF
							ELSE SA.SPATIAL_REF
							END
		--, [verbatimcoordinatesCheck] = CASE SA.SPATIAL_REF_QUALIFIER  
		--					WHEN 'Centrd UTM5 x dgmnte' THEN sa.SPATIAL_REF
		--					WHEN 'Centroïd deelgemnte'  THEN sa.SPATIAL_REF  --  THEN CONVERT(Nvarchar(20),ROUND(sa.SPATIAL_REF,2))
		--					WHEN 'Centroïd UTM 1 km' THEN '31U' + SDA.DATA
		--					WHEN 'Centroïd UTM 5 km' THEN '31U' + SDA.DATA
		--					WHEN 'Imported' THEN sa.SPATIAL_REF
		--					WHEN 'XY from original rec' THEN sa.SPATIAL_REF
		--					ELSE SA.SPATIAL_REF
		--					END	
		
		, [verbatimcoordinateSystem] = CASE SA.SPATIAL_REF_QUALIFIER  
							WHEN 'Centrd UTM5 x dgmnte' THEN 'Lambert coordinates'
							WHEN 'Centroïd deelgemnte' THEN 'Lambert coordinates'
							WHEN 'Centroïd UTM 1 km' THEN 'UTM 1km'
							WHEN 'Centroïd UTM 5 km' THEN 'UTM 5km'
							WHEN 'Imported' THEN 'Lambert coordinates'
							WHEN 'XY from original rec' THEN 'Lambert coordinates'
							ELSE SA.SPATIAL_REF_QUALIFIER
							END

		, [verbatimSRS] = CASE SA.SPATIAL_REF_QUALIFIER  
							WHEN 'Centrd UTM5 x dgmnte' THEN 'Belgian Datum 1972'
							WHEN 'Centroïd deelgemnte' THEN 'Belgian Datum 1972'
							WHEN 'Centroïd UTM 1 km' THEN 'WGS84'
							WHEN 'Centroïd UTM 5 km' THEN 'WGS84'
							WHEN 'Imported' THEN 'Belgian Datum 1972'
							WHEN 'XY from original rec' THEN 'Belgian Datum 1972'
							ELSE SA.SPATIAL_REF_QUALIFIER
							END

	   , [coordinateUncertaintyInMeters] = convert(nvarchar(5),coalesce(case
																	WHEN SA.SPATIAL_REF_QUALIFIER = 'Centrd UTM5 x dgmnte' THEN '3536'
																	WHEN SA.SPATIAL_REF_QUALIFIER='Centroïd deelgemnte' THEN '3536'
																	WHEN SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 1 km' THEN '707'
																	WHEN SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 5 km' THEN '3536'
																	WHEN SA.SPATIAL_REF_QUALIFIER='XY from original rec' THEN '30'
                                                                    when SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 100m' then '71'
                                                                    when SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 1km' then '707'
                                                                    when SA.SPATIAL_REF_QUALIFIER='centroïd UTM 5km' then '3536'
                                                                    when SA.SPATIAL_REF_QUALIFIER='Centroïd UTM 10km' then '7071'
                                                                    when SA.SPATIAL_REF_QUALIFIER='XY from original rec' then '30'
                                                                    else null
                                                                    end,'71')) 

		, [georeferenceRemarks] = CASE SA.SPATIAL_REF_QUALIFIER  
							WHEN 'Centrd UTM5 x dgmnte' THEN 'coordinates are centroid of 5km grid square and municipality intersection'
							WHEN 'Centroïd deelgemnte' THEN 'coordinates are centroid of municipality'
							WHEN 'Centroïd UTM 1 km' THEN 'coordinates are centroid of 1km grid square'
							WHEN 'Centroïd UTM 5 km' THEN 'coordinates are centroid of 5km grid square'
							WHEN 'Imported' THEN 'coordinates are centroid of 100m grid square'
							WHEN 'XY from original rec' THEN 'coordinates are original point coordinates'
							ELSE SA.SPATIAL_REF_QUALIFIER
							END

										

---- OCCURRENCE ---
        
        , [recordedBy] = CASE WHEN inbo.[ufn_RecordersPerSample](SA.[SAMPLE_KEY], ' | ') = 'Unknown' THEN NULL 
							ELSE inbo.[ufn_RecordersPerSample](SA.[SAMPLE_KEY], ' | ')
							END  
		, [individualCount]  = LifestageMeas.individualCount
		, [organismQuantity]  = CASE LifestageMeas.individualNotCount
									WHEN 'schaars' THEN 'rare'
									WHEN 'talrijk' THEN 'frequent'
									WHEN 'zeer talrijk' THEN 'abundant'
									ELSE NULL
									END
		, [organismQuantityType] = CASE LifestageMeas.individualNotCount
									WHEN 'schaars' THEN 'abundance'
									WHEN 'talrijk' THEN 'abundance'
									WHEN 'zeer talrijk' THEN 'abundance'
									ELSE NULL
									END
		 
		, [lifeStage] = CASE LifestageMeas.lifeStage
							WHEN 'adult' THEN 'adult'
							WHEN 'adult | juvenile' THEN 'adult | juvenile'
							WHEN 'juvenile' THEN 'juvenile'
							WHEN 'juvenile | adult' THEN 'adult | juvenile'
							ELSE NULL
							END
		, [behavior] = CASE behaviour
		                  WHEN 'adult | Vleugel | Zangpost' THEN 'stridulating'
						  WHEN 'adult | Zangpost' THEN 'stridulating'
						  WHEN 'Zangpost' THEN 'stridulating'
						  ELSE NULL
						  END
	
	    , [sex] = CASE sexNoCount
							WHEN 'male' THEN 'male'
							WHEN 'female' THEN 'female'
							WHEN 'female | male' THEN 'female | male'
							WHEN 'male | female' THEN 'female | male'
							ELSE NULL
							END
						
 
		, [occurrenceRemarks] = COALESCE(SexMeas.sex, '') + 
			Case when COALESCE(SexMeas.sex, '') <> '' AND COALESCE(LifestageMeas.lifeStage, '') <> ''  THEN ' | ' ELSE NULL END +
			COALESCE ( LifestageMeas.lifeStage5, '' ) 
		
	
-----Identification----

		, [identifiedBy] = CASE WHEN LTRIM(RTRIM(COALESCE (RTRIM(LTRIM(I.[FORENAME])), RTRIM(LTRIM(I.[INITIALS])) ,'') + ' ' + COALESCE (RTRIM(LTRIM(I.[SURNAME])), ''))) = 'Unknown' THEN NULL
							ELSE LTRIM(RTRIM(COALESCE (RTRIM(LTRIM(I.[FORENAME])), RTRIM(LTRIM(I.[INITIALS])) ,'') + ' ' + COALESCE (RTRIM(LTRIM(I.[SURNAME])), ''))) 
							END

---- Taxonomic Elements --
		
		
		, [scientificName] = ns.RECOMMENDED_SCIENTIFIC_NAME     --recommended scientific soort + genus 
		, [scientificNameAuthorship] = NS.RECOMMENDED_NAME_AUTHORITY + ISNULL ( ' ' + NS.RECOMMENDED_NAME_QUALIFIER , '') 
		, [taxonRank] = lower(NS.RECOMMENDED_NAME_RANK_LONG)   
		, [kingdom]	  = CONVERT( nvarchar(50), N'Animalia' )
	    , [phylum]	  = CONVERT( nvarchar(50), N'Arthropoda' )
	    , [class]	  = CONVERT( nvarchar(50), N'Insecta' )
	    , [order]	  = CONVERT( nvarchar(50), N'Orthoptera' )
		, [nomenclaturalCode] = 'ICZN'
		
	
-- Perqualifier
	
		
	, Case WHEN ( Left(Convert(Varchar(max), [TAO].COMMENT),7) = '{\rtf1\') THEN dbo.ufn_RtfToPlaintext(Convert(Varchar(max), [TAO].COMMENT))  
		ELSE Convert(Varchar(max), [TAO].COMMENT) 
		END as Comment
	, collectionCode = LTRIM(RTRIM(TAOC.[Collection]))  


FROM dbo.Survey S
	INNER JOIN [dbo].[Survey_event] SE ON SE.[Survey_Key] = S.[Survey_Key]
	LEFT JOIN [dbo].[Location] L ON L.[Location_Key] = SE.[Location_key]
	LEFT JOIN [dbo].[Location_Name] LN ON LN.[Location_Key] = L.[Location_Key] 
	
	INNER JOIN [dbo].[SAMPLE] SA ON SA.[SURVEY_EVENT_KEY] = SE.[SURVEY_EVENT_KEY]
--	inner join [dbo].[SAMPLE_DATA] SDA on SDA.[SAMPLE_KEY]=SA.[SAMPLE_KEY]
	LEFT JOIN [dbo].[SAMPLE_TYPE] ST ON  ST.[SAMPLE_TYPE_KEY] = SA.[SAMPLE_TYPE_KEY] 
	LEFT JOIN [dbo].[TAXON_OCCURRENCE] TAO ON TAO.[SAMPLE_KEY] = SA.[SAMPLE_KEY]   -- LEFT or INNER JOIN
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
	
	--Lifestage Measurements
	LEFT OUTER JOIN ( SELECT lifeStage.TAXON_OCCURRENCE_KEY
						, [lifeStage] = dbo.Concatenate(1, lifeStage.[lifeStage_ind] , ' | ' )
						, [lifeStage5] = dbo.Concatenate(1, lifeStage.[lifeStage_ind] + ':' + CONVERT(nvarchar(20), lifeStage.[individualCount]), ' | ' )
						, [individualCount] = sum(lifeStage.[individualCount])
						, [individualNotCount] = dbo.Concatenate(1, CASE WHEN LTRIM(RTRIM(lifeStage.[individualNotCount])) = '' THEN NULL ELSE lifeStage.[individualNotCount] END  , ' | ' )
						, [rauw] = dbo.Concatenate(1, lifeStage.rauw, ' | ' ) 
					FROM ( SELECT taoMeas.TAXON_OCCURRENCE_KEY
											, [lifeStage_ind] = CASE WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME in ('juviniel', 'juveniel') THEN 'juvenile'
																	WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME in ('Nimf') THEN 'nymph'
																	WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME IN ('Vrouw', 'Man', 'Adult Vrouw', 'Adult Man', 'zangpost') THEN 'adult' 
																	WHEN MQMeas.SHORT_NAME IN ('none','Vleugel') THEN NULL
																	ELSE NULL  
																	END
											, [individualCount]  = sum( CASE WHEN ISNUMERIC(taoMeas.DATA) = 1 AND MUMeas.SHORT_NAME = 'Count' THEN CONVERT(int , taoMeas.DATA) ELSE NULL END )
											, [individualNotCount]  = dbo.Concatenate(1 , CASE WHEN dbo.isReallyNumeric(taoMeas.DATA) = 0  THEN taoMeas.DATA ELSE NULL END , ',' )
											, rauw = dbo.Concatenate(1, MQMeas.SHORT_NAME + ' (' + taoMeas.DATA + ';' + taoMeas.ACCURACY + ')' , ' | ' )
											FROM [dbo].[TAXON_OCCURRENCE_DATA] taoMeas 
											LEFT JOIN dbo.MEASUREMENT_UNIT MUMeas ON  MUMeas.MEASUREMENT_UNIT_KEY = taoMeas.MEASUREMENT_UNIT_KEY 
																					AND MUMeas.SHORT_NAME = 'Count' --> individualcount
										        LEFT JOIN dbo.MEASUREMENT_QUALIFIER MQMeas ON  MQMeas.MEASUREMENT_QUALIFIER_KEY = taoMeas.MEASUREMENT_QUALIFIER_KEY
										        LEFT JOIN dbo.MEASUREMENT_TYPE MTMeas ON  (MTMeas.MEASUREMENT_TYPE_KEY = MQMeas.MEASUREMENT_TYPE_KEY 
																					AND  MTMeas.SHORT_NAME = 'Abundance') --
											WHERE 1=1
											--AND taoMeas.TAXON_OCCURRENCE_KEY = 'BFN0017900008HFS'
											GROUP BY taoMeas.TAXON_OCCURRENCE_KEY
											    
												, CASE WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME in ('juviniel', 'juveniel') THEN 'juvenile'
																	WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME in ('Nimf') THEN 'nymph'
																	WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME IN ('Vrouw', 'Man', 'Adult Vrouw', 'Adult Man', 'zangpost') THEN 'adult' 
																	WHEN MQMeas.SHORT_NAME IN ('none','Vleugel') THEN NULL
																	ELSE NULL  
																	END
												
											) lifeStage
					GROUP BY  lifeStage.TAXON_OCCURRENCE_KEY
					) lifeStageMeas ON lifeStageMeas.TAXON_OCCURRENCE_KEY= tao.TAXON_OCCURRENCE_KEY

---BEHAVIOUR.... HIER BEN IK AAN T PROBEREN TE PRULLEN

LEFT OUTER JOIN ( SELECT behaviour.TAXON_OCCURRENCE_KEY
						, [behaviour] = dbo.Concatenate(1, behaviour.[lifeStage_ind] , ' | ' )
						, [behaviour5] = dbo.Concatenate(1, behaviour.[lifeStage_ind] + ':' + CONVERT(nvarchar(20), behaviour.[individualCount]), ' | ' )
						, [individualCount] = sum(behaviour.[individualCount])
						, [individualNotCount] = dbo.Concatenate(1, CASE WHEN LTRIM(RTRIM(behaviour.[individualNotCount])) = '' THEN NULL ELSE behaviour.[individualNotCount] END  , ' | ' )
						, [rauw] = dbo.Concatenate(1, behaviour.rauw, ' | ' ) 
					FROM ( SELECT taoMeas.TAXON_OCCURRENCE_KEY
											, [lifeStage_ind] = CASE WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME in ('juviniel', 'juveniel') THEN 'juvenile'
																	WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME in ('Nimf') THEN 'nymph'
																	WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME IN ('Vrouw', 'Man', 'Adult Vrouw', 'Adult Man') THEN 'adult' 
																	WHEN MQMeas.SHORT_NAME IN ('none') THEN NULL
																	ELSE MQMeas.SHORT_NAME  
																	END
											, [individualCount]  = sum( CASE WHEN ISNUMERIC(taoMeas.DATA) = 1 AND MUMeas.SHORT_NAME = 'Count' THEN CONVERT(int , taoMeas.DATA) ELSE NULL END )
											, [individualNotCount]  = dbo.Concatenate(1 , CASE WHEN dbo.isReallyNumeric(taoMeas.DATA) = 0  THEN taoMeas.DATA ELSE NULL END , ',' )
											, rauw = dbo.Concatenate(1, MQMeas.SHORT_NAME + ' (' + taoMeas.DATA + ';' + taoMeas.ACCURACY + ')' , ' | ' )
											FROM [dbo].[TAXON_OCCURRENCE_DATA] taoMeas 
											LEFT JOIN dbo.MEASUREMENT_UNIT MUMeas ON  MUMeas.MEASUREMENT_UNIT_KEY = taoMeas.MEASUREMENT_UNIT_KEY 
																					AND MUMeas.SHORT_NAME = 'Count' --> individualcount
										        LEFT JOIN dbo.MEASUREMENT_QUALIFIER MQMeas ON  MQMeas.MEASUREMENT_QUALIFIER_KEY = taoMeas.MEASUREMENT_QUALIFIER_KEY
										        LEFT JOIN dbo.MEASUREMENT_TYPE MTMeas ON  (MTMeas.MEASUREMENT_TYPE_KEY = MQMeas.MEASUREMENT_TYPE_KEY 
																					AND  MTMeas.SHORT_NAME = 'Abundance') --
											WHERE 1=1
											--AND taoMeas.TAXON_OCCURRENCE_KEY = 'BFN0017900008HFS'
											GROUP BY taoMeas.TAXON_OCCURRENCE_KEY
											    
												, CASE WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME in ('juviniel', 'juveniel') THEN 'juvenile'
																	WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME in ('Nimf') THEN 'nymph'
																	WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME IN ('Vrouw', 'Man', 'Adult Vrouw', 'Adult Man') THEN 'adult' 
																	WHEN MQMeas.SHORT_NAME IN ('none') THEN NULL
																	ELSE MQMeas.SHORT_NAME  
																	END
												
											) behaviour
					GROUP BY  behaviour.TAXON_OCCURRENCE_KEY
					) behaviourMeas ON behaviourMeas.TAXON_OCCURRENCE_KEY= tao.TAXON_OCCURRENCE_KEY
	 
	--Sex Measurements
	LEFT OUTER JOIN ( SELECT sex.TAXON_OCCURRENCE_KEY
							, [sex] = dbo.Concatenate(1, sex.[sex_ind] + ':' + CONVERT(nvarchar(20), sex.[individualCount]), ' | ') 
							, [sexNoCount] = dbo.Concatenate(1, sex.[sex_ind], ' | ')
							, [individualCount] = sum(sex.[individualCount])
							, [individualNotCount] = dbo.Concatenate(1, CASE WHEN LTRIM(RTRIM(sex.[individualNotCount]))  = '' THEN NULL ELSE sex.[individualNotCount] END  , ' | ' )
							, [rauw] = dbo.Concatenate(1, sex.rauw , ' | ' ) 
						FROM ( SELECT TAXON_OCCURRENCE_KEY
								, [sex_ind] =  CASE WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME IN ('Adult Man', 'Man') THEN 'male'  
											WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME IN ('Adult Vrouw', 'Vrouw') THEN 'female'  
											--ELSE 'ArmeWeeskens'   
											END
																						 
								, [individualCount]  = sum( CASE WHEN ISNUMERIC(taoMeas.DATA) = 1 AND MUMeas.SHORT_NAME = 'Count' THEN CONVERT(int , taoMeas.DATA) ELSE NULL END )
								, [individualNotCount]  = dbo.Concatenate(1 , CASE WHEN dbo.isReallyNumeric(taoMeas.DATA) = 0 THEN taoMeas.DATA ELSE NULL END , ',' )
								, rauw = dbo.Concatenate(1, MQMeas.SHORT_NAME + ' (' + taoMeas.DATA + ';' + taoMeas.ACCURACY + ')' , ' | ' )
							FROM [dbo].[TAXON_OCCURRENCE_DATA] taoMeas 
							LEFT JOIN dbo.MEASUREMENT_UNIT MUMeas ON  MUMeas.MEASUREMENT_UNIT_KEY = taoMeas.MEASUREMENT_UNIT_KEY 
																	AND MUMeas.SHORT_NAME = 'Count' --> individualcount
							    LEFT JOIN dbo.MEASUREMENT_QUALIFIER MQMeas ON  MQMeas.MEASUREMENT_QUALIFIER_KEY = taoMeas.MEASUREMENT_QUALIFIER_KEY
							    LEFT JOIN dbo.MEASUREMENT_TYPE MTMeas ON  (MTMeas.MEASUREMENT_TYPE_KEY = MQMeas.MEASUREMENT_TYPE_KEY 
																	AND  MTMeas.SHORT_NAME = 'Abundance') --
							WHERE 1=1
							--AND taoMeas.TAXON_OCCURRENCE_KEY = 'BFN0017900008HFS'
							GROUP BY TAXON_OCCURRENCE_KEY
								, CASE WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME IN ('Adult Man', 'Man') THEN 'male'  
										WHEN MUMeas.SHORT_NAME = 'Count' AND MQMeas.SHORT_NAME IN ('Adult Vrouw', 'Vrouw') THEN 'female'  
										--ELSE 'ArmeWeeskens'
										END
						) sex
						GROUP BY  sex.TAXON_OCCURRENCE_KEY
					)SexMeas ON SexMeas.TAXON_OCCURRENCE_KEY = tao.TAXON_OCCURRENCE_KEY
		LEFT OUTER join [dbo].[SAMPLE_DATA] SDA on SDA.[SAMPLE_KEY]=SA.[SAMPLE_KEY]			

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
AND TAO.TAXON_OCCURRENCE_KEY NOT IN ('BFN0017900007ZKN','BFN0017900008DLI', 'BFN0017900008FNM','BFN0017900008RG5')







GO


