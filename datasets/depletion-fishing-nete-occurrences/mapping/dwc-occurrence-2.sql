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
      , [Modified] = MAX([inbo].[LCReturnVagueDateGBIF](  Td.Vague_date_start
                                                   , Td.Vague_date_end
                                                   , Td.Vague_date_type
												   ,0))
      --		tMt.METI_USR_CRE_DTE,
      --		tMt.METI_USR_UPD_DTE ,
      --		tW.WRNG_USR_CRE_DTE,
      --		tW.WRNG_USR_UPD_DTE,
      
      --, [Verbatimlocality] = Ln.Item_name
      --, [Samplingprotcol] = CASE
      --                          WHEN St.Short_name = 'Elektrovisserij' THEN 'Electro Fishing'
      --                          WHEN St.Short_name = 'Fuik' THEN 'Fyke'
      --                          WHEN St.Short_name = 'schietfuik' THEN 'Fyke'
      --                          ELSE St.Short_name
      --                      END
      --, [Institutioncode] = CONVERT( NVARCHAR(20), 'INBO')
      -->		CONVERT(Nvarchar(20),'FloWER') AS ownerInstitutionCode, 
      
      --, [Collectioncode] = CONVERT( NVARCHAR(40), S.Item_name)
      --, [Language] = CONVERT( NVARCHAR(20), 'Dutch')
      --Right( '000000000' + CONVERT(nvarchar(20),tMt.METI_ID),8) 
      
      --, [Catalognumber] = Tao.Taxon_occurrence_key
      ---		NULL::text AS InformationWithheld,
      ---		NULL::text AS Remarks,
      -- Taxonomic Elements --
      
      --, [Basisofrecord] = CASE
      --                        WHEN RT.[SHORT_NAME] = 'Collection' THEN 'PreservedSpecimen'
      --                        ELSE 'HumanObservation'
      --                    END
                          --case
                          --                       when RT.[SHORT_NAME]='None' and ST.SHORT_NAME = 'Field Observation' then 'HumanObservation'
                          --                       when RT.[SHORT_NAME]='None' and ST.SHORT_NAME <> 'Field Observation' then 'Unknown'
                          --                       when RT.[SHORT_NAME]='Collection' then 'PreservedSpecimen'
                          --                       else RT.[SHORT_NAME]
                          --                   end
                          
      --, [Originalnameusage] = T.Item_name
      --, [Scientificname] = Ns.Recommended_scientific_name
      --recommended scientific soort + genus 
      ---		NULL::text AS HigherTaxon,
      ---		NULL::text AS Kingdom,
      --- 	NULL::text AS Phylum, 
      ---		tc.name::text AS Class, 
      ---		NULL::text AS Order, 
      ---		tf.name::text AS Family, 
      ---		tg.name::text AS Genus, 
      ---		ts.name::text AS SpecificEpithet, 
      
      --, [Verbatimtaxonrank] = Ns.Recommended_name_rank
      -- recomended rank 
      
      --, [Taxonrank] = Ns.Recommended_name_rank_long
      ---		NULL::text AS InfraSpecificEpithet,
      --		NS.RECOMMENDED_NAME_AUTHORITY + ISNULL ( ' ' + NS.RECOMMENDED_NAME_QUALIFIER , '')  AS AuthorYearOfScientificName,	-- recommended auth 
      --CONVERT(Nvarchar(20),'ICBN') AS NomenclaturalCode, 
      --tT.TAXN_NAM_WET , -debugging
      -- Identification Elements --
      ---		specimen.identif_qualifier::text AS IdentificationQualifier,
      -- Locality Elements --
      ---		NULL::text AS HigherGeography, 
      ---		NULL::text AS Continent, 
      ---		NULL::text AS WaterBody, 
      ---		NULL::text AS IslandGroup, 
      ---		NULL::text AS Island, 
      
      --, [Countrycode] = CONVERT( NVARCHAR(20), 'BE')
      ---		NULL::text AS StateProvince, 
      ---		NULL::text AS County, 
      --CONVERT(Nvarchar(20),area.toponym) AS Locality, 
      ---		nullif(specimen.altitude,0)::text AS MinimumElevationInMeters, 
      ---		nullif(specimen.altitude,0)::text AS MaximumElevationInMeters, 
      ---		NULL::text AS MinimumDepthInMeters, 
      ---		NULL::text AS MaximumDepthInMeters, 
      -- Collecting Event Elements --
      ---		as EarliestDateCollected
      ---		as LatestDateCollected
      
      --, [Eventdate] = CONVERT(  NVARCHAR(10)
      --                        , CONVERT(  DATETIME
      --                                  , Dbo.Lcreturnvaguedateshort(  Sa.Vague_date_start
      --                                                               , Sa.Vague_date_end
      --                                                               , Sa.Vague_date_type)
      --                                  , 103)
      --                        , 120)
      --CONVERT(Nvarchar(12) , tW.WRNG_BEG_DTE , 120)  + '/' + CONVERT(Nvarchar(12) , tW.WRNG_END_DTE , 120) AS EventDate ,
      ---		NULL::text as DayOfYear,
      --ISNULL(ISNULL(P.PERS_NAM_FRT,'')+ P.PERS_NAM_LST,PERS_CDE) 
      --dbo.[ufn_RecordersPerSample](SA.[SAMPLE_KEY]) AS recordedBy, 
      -- Biological Elements --
      ---		NULL::text AS Sex, 
      ---		NULL::text AS LifeStage, 
      ---		NULL::text AS Attributes,
      -- References Elements --
      ---		NULL::text AS ImageURL,
      --cB.BRON_DES AS occurrenceDetails, 
      -- Curatorial Extension --
      --tMt.METI_ID AS CatalogNumberNumeric,
      ---		coalesce(identifier.family_name ||', '||identifier.first_name, '')::text AS IdentifiedBy, 
      
      --, [Identifiedby] = COALESCE(  I.[Forename]
      --                            , I.[Initials]
      --                            , '') + ' ' + COALESCE( I.[Surname], '')
      ---		specimen.identified_date::text AS DateIdentified, 
      ---		specimen.collection_num::text AS CollectorNumber, 
      ---		coalesce(specimen.label,'')::text AS FieldNumber, 
      ---		specimen.station::text AS FieldNotes, 
      ---		NULL::text as VerbatimCollectingDate,
      ---		NULL::text AS VerbatimElevation, 
      ---		NULL::text AS VerbatimDepth, 
      ---		NULL::text AS Preparations, 
      ---		specimen.type_status::text AS TypeStatus,
      ---		NULL::text AS GenBankNumber, 
      ---		NULL::text AS OtherCatalogNumbers, 
      ---		NULL::text AS RelatedCatalogedItems,
      ---		specimen.disposition AS Disposition,
      ---		NULL::text AS IndividualCount, 
      -- Geospatial Extension --
      --CONVERT(Nvarchar(20),convert(decimal(12,3),round(SA.[LAT],3)) )AS DecimalLatitude, -> Org coordinates
      --CONVERT(Nvarchar(20),convert(decimal(12,3),round(SA.[LONG],3)) )AS DecimalLongitude, -> org coordinates
      
      --, [Decimallatitude] = CONVERT( NVARCHAR(20), CONVERT( DECIMAL( 12, 3), Round( COALESCE( Shp.Lat_wgs84, 0), 3)))
      --, [Decimallongitude] = CONVERT( NVARCHAR(20), CONVERT( DECIMAL( 12, 3), Round( COALESCE( Shp.Long_wgs84, 0), 3)))
      --, [Geodeticdatum] = CONVERT( NVARCHAR(10), 'WGS84')
      --CONVERT(Nvarchar(10),ROUND(tIH.IFBL_COR_Y,3)) AS verbatimLatitude, 
      --CONVERT(Nvarchar(10),ROUND(tIH.IFBL_COR_X,3)) AS verbatimLongitude, 
      --CONVERT(Nvarchar(10),'EPSG:31370') AS verbatimCoordinateSystem, 
      
      --, [CoordinateUncertaintyInMeters] = '707'
      ---		NULL::text AS PointRadiusSpatialFit,
      
      --, [Verbatimcoordinates] = Shp.Tag
      ---		specimen.orig_lat::text AS VerbatimLatitude, 
      ---		specimen.orig_long::text AS VerbatimLongitude
      -->	CONVERT(Nvarchar(20),'IFBL 1km') AS VerbatimCoordinateSystem	---gjhfgjhfgj
      /*   CASE 
			WHEN LEN([tIH].[IFBL_CDE]) > 5 THEN 'IFBL 1km'
			ELSE 'IFBL 4km'
		END */
      
      --, [Verbatimcoordinatesystem] = 'UTM 1km (wgs84)'
      ---		NULL::text AS GeoreferenceProtocol, 
      ---		NULL::text AS GeoreferenceSources,
      ---		NULL::text AS GeoreferenceVerificationStatus,
      ---		NULL::text AS GeoreferenceRemarks, 
      ---		NULL::text AS FootprintWKT, 
      ---		NULL::text AS FootprintSpatialFit
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


