USE [NBNData_IPT]
GO

/****** Object:  View [ipt].[vwGBIF_DepletionFishingNeteMeasurement]    Script Date: 19/09/2016 12:12:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [ipt].[vwGBIF_DepletionFishingNeteMeasurement]
AS
 
SELECT  [occurrenceID] = 'INBO:NBN:' + Tao.Taxon_occurrence_key
	, [MeasurementId] = 'INBO:MEAS:' + taoMeas.TAXON_OCCURRENCE_DATA_KEY
	, [MeasurementMethod] = 'Depletion Fishing (Laurent & Lamarque 1975, De Lury depletion model)'
	, [MeasurementType] = CASE  
			WHEN MTMeas.SHORT_NAME = 'Lengte' THEN 'length'
			WHEN MTMeas.SHORT_NAME = 'Gewicht' THEN 'weight'
			WHEN MTMeas.SHORT_NAME = 'Abundance' THEN 'abundance'
			ELSE MTMeas.SHORT_NAME
			END 
	, [MeasurementValue] = CASE  WHEN TAOMeas.ACCURACY = 'Exact' THEN TAOMeas.DATA
								ELSE CONVERT(nvarchar(10), ROUND (CONVERT(Decimal(12,1), TAOMeas.DATA),1))
								END
	, [MeasurementAccuracy] = LOWER( TAOMeas.ACCURACY )
	, [MeasurementUnit] =  CASE WHEN MTMeas.SHORT_NAME = 'abundance' THEN 'individualCount / ' + Traject.[Length] + 'm'
			WHEN MTMeas.SHORT_NAME = 'Gewicht' THEN 'g / ' + Traject.[Length] + 'm'
			ELSE MUMeas.SHORT_NAME 
			END
	, Traject.[Length] as [TrajectLength]
FROM  Dbo.Survey S
        INNER JOIN [Dbo].[Survey_event] Se ON  Se.[Survey_key] = S.[Survey_key]
        LEFT JOIN [Dbo].[Location] L ON  L.[Location_key] = Se.[Location_key]
        LEFT JOIN [Dbo].[Location_name] Ln ON  Ln.[Location_key] = L.[Location_key]
        LEFT JOIN [Dbo].[Sample] Sa ON  Sa.[Survey_event_key] = Se.[Survey_event_key]
        LEFT JOIN (SELECT SD.SAMPLE_KEY
							--, CONVERT(DECIMAL (12,0), SD.DATA ) as [Length]
							,  SD.DATA as [Length]
							, SD.ACCURACY
							--, mq.Short_Name 
							, mt.SHORT_NAME
						FROM SAMPLE_DATA SD
							INNER JOIN dbo.MEASUREMENT_QUALIFIER mq ON mq.MEASUREMENT_QUALIFIER_KEY = SD.MEASUREMENT_QUALIFIER_KEY
							INNER JOIN dbo.MEASUREMENT_TYPE mt ON mt.MEASUREMENT_TYPE_KEY = mq.MEASUREMENT_TYPE_KEY
						WHERE 1=1
						--AND SAMPLE_KEY = 'BFN0017900000PMV'
						AND mq.SHORT_NAME = 'Traject'
						AND mt.SHORT_NAME = 'Lengte') Traject ON Traject.SAMPLE_KEY = SA.SAMPLE_KEY
        
        LEFT JOIN [Dbo].[Sample_type] St ON  St.[Sample_type_key] = Sa.[Sample_type_key]
        LEFT JOIN [Dbo].[Taxon_occurrence] Tao ON  Tao.[Sample_key] = Sa.[Sample_key]
        LEFT JOIN [Dbo].[Record_type] Rt ON  Rt.[Record_type_key] = Tao.[Record_type_key]
        LEFT JOIN [Dbo].[Specimen] Sp ON  Sp.[Taxon_occurrence_key] = Tao.[Taxon_occurrence_key]
        LEFT JOIN [Dbo].[Taxon_determination] Td ON  Td.[Taxon_occurrence_key] = Tao.[Taxon_occurrence_key]
        LEFT JOIN [Dbo].[Individual] I ON  I.[Name_key] = Td.[Determiner]
        LEFT JOIN [Dbo].[Determination_type] Dt ON  Dt.[Determination_type_key] = Td.[Determination_type_key]
                                                    --Taxon
                                                    
        LEFT JOIN [Dbo].[Taxon_list_item] Tli ON  Tli.[Taxon_list_item_key] = Td.[Taxon_list_item_key]
        LEFT JOIN [Dbo].[Taxon_version] Tv ON  Tv.[Taxon_version_key] = Tli.[Taxon_version_key]
        LEFT JOIN [Dbo].[Taxon] T ON  T.[Taxon_key] = Tv.[Taxon_key]
        LEFT JOIN [Dbo].[Taxon_rank] Tr ON  Tr.Taxon_rank_key = Tli.Taxon_rank_key
                                             --Lijst
                                             --LEFT JOIN [dbo].[TAXON_LIST_VERSION] TLV ON TLV.TAXON_LIST_VERSION_KEY = TLI.TAXON_LIST_VERSION_KEY
                                             --LEFT JOIN [dbo].[TAXON_LIST] TL ON TL.TAXON_LIST_KEY =  TLV.TAXON_LIST_KEY
                                             --Normalizeren Namen 
                                             --LEFT JOIN [dbo].[NAMESERVER] NS ON NS.INPUT_TAXON_VERSION_KEY = TD.TAXON_LIST_ITEM_KEY
                                             
        LEFT JOIN [Inbo].[Nameserver_12] Ns ON  Ns.[Inbo_taxon_version_key] = Tli.[Taxon_version_key]
                                                 -->Common name nog opzoeken...
                                                 --Recorders                                            
   
        LEFT JOIN [dbo].[TAXON_OCCURRENCE_DATA] taoMeas ON  taoMeas.TAXON_OCCURRENCE_KEY = tao.TAXON_OCCURRENCE_KEY
        
        LEFT JOIN dbo.MEASUREMENT_UNIT MUMeas ON  MUMeas.MEASUREMENT_UNIT_KEY = taoMeas.MEASUREMENT_UNIT_KEY
        LEFT JOIN dbo.MEASUREMENT_QUALIFIER MQMeas ON  MQMeas.MEASUREMENT_QUALIFIER_KEY = taoMeas.MEASUREMENT_QUALIFIER_KEY
        LEFT JOIN dbo.MEASUREMENT_TYPE MTMeas ON  MTMeas.MEASUREMENT_TYPE_KEY = MQMeas.MEASUREMENT_TYPE_KEY
		
WHERE  S.[Item_name] = 'Depletie-afvissingen Grote en Kleine Nete'
  --     AND Isnumeric( Substring(  Ln.[Item_name]
    --                            , 2
      --                          , 1)) = 0
       AND Td.[Preferred] = 1
       AND Ns.[Recommended_name_rank] NOT IN(  'FunGp'
                                             , 'Agg'
                                             , 'SppGrp')
       AND Dt.[Short_name] NOT IN(  'Incorrect'
                                  , 'Invalid'
                                  , 'Considered Incorrect'
                                  , 'Requires Confirmation')
       AND Tr.[Sequence] >= 230
       AND Isnumeric( LEFT( Sa.Spatial_ref, Charindex(  ','
                                                      , Sa.Spatial_ref
                                                      , 1) - 1)) = 1
       AND Charindex(  ','
                     , Sa.Spatial_ref
                     , 1) > 5
       AND Isnumeric( Substring(  Sa.Spatial_ref
                                , Charindex(  ','
                                            , Sa.Spatial_ref
                                            , 1) + 1
                                , Len( Sa.Spatial_ref))) = 1
       --AND dbo.[ufn_RecordersPerSample](SA.[SAMPLE_KEY]) <> 'Jo Packet'
       
       --AND MTMeas.SHORT_NAME IN ('Count', 'Gewicht')
       --AND tao.Taxon_occurrence_key = 'BFN0017900003094'
       
       --AND TAOMeas.DATA <> '0' presence or abscense in occurence data

		-- No Abscent records
		 AND TAOMeas.DATA <> '0'
       
GROUP BY  Tao.[Taxon_occurrence_key]
        , Ln.[Item_name]
        , Rt.[Short_name]
        , St.Short_name
        , CONVERT( NVARCHAR(40), S.Item_name)
        , T.[Item_name]
        , Ns.[Recommended_scientific_name]
        , Ns.[Recommended_name_rank]
        , Ns.[Recommended_name_rank_long]
        , Rt.[Short_name]
        , Sa.[Vague_date_start]
        , Sa.[Vague_date_end]
        , Sa.[Vague_date_type]
        , Sa.[Sample_key]
        , COALESCE(  I.[Forename]
                   , I.[Initials]
                   , '') + ' ' + COALESCE( I.[Surname], '')
     
        , MTMeas.SHORT_NAME 
		, TAOMeas.DATA
		, MUMeas.SHORT_NAME
		, taoMeas.TAXON_OCCURRENCE_DATA_KEY
		, Traject.[Length]
		, TAOMeas.ACCURACY
		;























/****** Object:  View [ipt].[vwGBIF_TrekVis]    Script Date: 07/04/2012 15:45:17 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

GO


