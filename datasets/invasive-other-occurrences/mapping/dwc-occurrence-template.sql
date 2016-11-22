SELECT 
    /* Record */
      [occurrenceID] = 'INBO:NBN:' + TOC.TAXON_OCCURRENCE_KEY
    , [type] =
        CASE
            WHEN RT.SHORT_NAME IN ('auditory record', 'reference/auditory record' ) THEN 'Sound'
            WHEN RT.SHORT_NAME IN ('field record/photographed', '') THEN 'StillImage'
            WHEN RT.SHORT_NAME IN ('Collection/auditory record', 'Collection', 'Collection/field record', 'Collection/reference') THEN 'PhysicalObject'
            WHEN RT.SHORT_NAME IN ('Reference') THEN 'Text'
            WHEN RT.SHORT_NAME IN ('field record', 'None', 'reported to recorder', 'trapped in Malaise trap' ) THEN 'Event'
            ELSE ''
        END    
    , [language] = 'en'
    , [license] = 'http://creativecommons.org/publicdomain/zero/1.0/'
    , [rightsHolder] = 'INBO'
    , [accessRights] = 'http://www.inbo.be/en/norms-for-data-use'
    , [datasetID] = 'http://doi.org/10.15468/1rcpsq'
    , [institutionCode] = 'INBO'
    , [datasetName] = 'invasive-other-occurrences'
    , [ownerInstitutionCode] = 'INBO'
    , [basisOfRecord] =
        CASE
            WHEN RT.SHORT_NAME IN ('Collection/auditory record', 'Collection', 'Collection/field record', 'Collection/reference') THEN 'PreservedSpecimen'
            ELSE 'HumanObservation'
        END

    /* Occurrence */        
    , [recordedBy] =
        CASE
            WHEN inbo.[ufn_RecordersPerSample](SA.[SAMPLE_KEY], ' | ') = 'Unknown' THEN '' 
            ELSE inbo.[ufn_RecordersPerSample](SA.[SAMPLE_KEY], ' | ')
        END
    , [individualCount] = Coalesce(Meas.[individualCount], 0)
    --, [verbatimIndividualCount] = TOCD.DATA

    /* Event */
    , [eventID] = SE.SURVEY_EVENT_KEY
    , [eventDate] = 
        CASE 
            WHEN [inbo].[LCReturnVagueDateGBIF](SA.VAGUE_DATE_START, SA.VAGUE_DATE_END, SA.VAGUE_DATE_TYPE, 1) = 'Unknown' THEN ''
            ELSE [inbo].[LCReturnVagueDateGBIF](SA.VAGUE_DATE_START, SA.VAGUE_DATE_END, SA.VAGUE_DATE_TYPE, 1)
        END
    , [continent] = 'Europe'
    , [countryCode] = 'BE'
    , [decimalLatitude] = CONVERT(Nvarchar(20),CONVERT(decimal(12,5),ROUND(COALESCE(SA.Lat,0),5)))
    , [decimalLongitude] = CONVERT(Nvarchar(20),CONVERT(decimal(12,5),ROUND(COALESCE(SA.Long,0),5)))
    , [geodeticDatum] = 'WGS84'
    , [identifiedBy] = COALESCE(
        CASE
            WHEN LTRIM(RTRIM(COALESCE (RTRIM(LTRIM(I.[FORENAME])), RTRIM(LTRIM(I.[INITIALS])), '') + ' ' + COALESCE (RTRIM(LTRIM(I.[SURNAME])), ''))) = 'Unknown' THEN NULL
            ELSE LTRIM(RTRIM(COALESCE (RTRIM(LTRIM(I.[FORENAME])), RTRIM(LTRIM(I.[INITIALS])) ,'') + ' ' + COALESCE (RTRIM(LTRIM(I.[SURNAME])), ''))) 
        END
        , '')
    , [scientificName] = ns.RECOMMENDED_SCIENTIFIC_NAME    
    , [taxonRank] = LOWER(NS.RECOMMENDED_NAME_RANK_LONG)
    , [scientificNameAuthorship] = NS.RECOMMENDED_NAME_AUTHORITY + ISNULL(' ' + NS.RECOMMENDED_NAME_QUALIFIER , '')
    , [vernacularName] = COALESCE(NormNaam.ITEM_NAME, '')
    --, [nomenclaturalCode] = 'ICZN'        
    
    , [verbatimDatasetName] = S.Item_name
        
    --, S.Item_name as 'Survey'
    --, dbo.LCReturnVagueDateShort(SA.VAGUE_DATE_START,SA.VAGUE_DATE_END,SA.VAGUE_DATE_TYPE) as 'Sample Date'
    --, NS.RECOMMENDED_SCIENTIFIC_NAME as 'recommended nameserver scientific name'
    --, ITN .PREFERRED_NAME as 'project species name'
    --, NS.RECOMMENDED_NAME_RANK as 'rank'
    --, ITN.COMMON_NAME as 'vernacular name'
    --, NS.TAXON_NAME as 'nameserver taxon name'
    , NSR.RECOMMENDED_TAXON_VERSION_KEY
    , S.SURVEY_KEY
    , S.ITEM_NAME
    --, TOCD.DATA as 'Count'
    --, LN.ITEM_NAME as 'Sample Location'
    --, LN.LOCATION_NAME_KEY
    --, L.LONG as 'decimalLongitude'
    --, L.LAT as 'decimalLatitude'
    --,-- L.SPATIAL_REF_SYSTEM as 'spatialRefSystem'
    --, L.SPATIAL_REF as 'spatialref'


FROM [dbo].SURVEY S 
    INNER JOIN [dbo].SURVEY_EVENT SE ON S.SURVEY_KEY = SE.SURVEY_KEY 
    INNER JOIN [dbo].SAMPLE SA ON SA.SURVEY_EVENT_KEY = SE.SURVEY_EVENT_KEY     
    INNER JOIN [dbo].TAXON_OCCURRENCE TOC ON TOC.SAMPLE_KEY = SA.SAMPLE_KEY 
    LEFT JOIN [dbo].TAXON_DETERMINATION TD ON TD.TAXON_OCCURRENCE_KEY = TOC.TAXON_OCCURRENCE_KEY 
    
    LEFT JOIN [dbo].[INDIVIDUAL] I ON I.[NAME_KEY] = TD.[DETERMINER]
    LEFT JOIN [dbo].[RECORD_TYPE] RT ON RT.[RECORD_TYPE_KEY] = TOC.[RECORD_TYPE_KEY]    
        
    INNER JOIN [dbo].INDEX_TAXON_NAME ITN on ITN.TAXON_LIST_ITEM_KEY = TD.TAXON_LIST_ITEM_KEY 
    INNER JOIN [dbo].TAXON_LIST_ITEM tlitd ON tlitd.TAXON_LIST_ITEM_KEY = TD.TAXON_LIST_ITEM_KEY
    INNER JOIN [dbo].[TAXON_RANK] TR ON TR.TAXON_RANK_KEY = tlitd.TAXON_RANK_KEY    
    INNER JOIN [inbo].NAMESERVER_12 NS ON NS.INBO_TAXON_VERSION_KEY = tlitd.TAXON_VERSION_KEY
    INNER JOIN [dbo].NAMESERVER NSR ON NSR.INPUT_TAXON_VERSION_KEY = tlitd.TAXON_VERSION_KEY
    --LEFT JOIN [dbo].TAXON_OCCURRENCE_DATA TOCD ON TOC.TAXON_OCCURRENCE_KEY = TOCD.TAXON_OCCURRENCE_KEY 
    LEFT JOIN [dbo].LOCATION L on SA.LOCATION_KEY = L.LOCATION_KEY 
    LEFT JOIN [dbo].LOCATION_NAME LN on L.LOCATION_KEY = LN.LOCATION_KEY

    LEFT OUTER JOIN (
        SELECT
              tmp.TAXON_OCCURRENCE_KEY
            , [individualCount] =
                SUM(
                    CASE
                        WHEN ISNUMERIC(tmp.DATA) = 1 
                            AND unit = 'Count' 
                            AND NOT tmp.DATA = ','
                        THEN CONVERT(int, ROUND(tmp.DATA, 0))
                        ELSE NULL
                    END
                )
        FROM (
            SELECT
                  taoMeas.TAXON_OCCURRENCE_KEY
                , MUMeas.SHORT_NAME as unit
                , taoMeas.DATA
                , taoMeas.ACCURACY
                , MQMeas.SHORT_NAME as Qualifier
            FROM dbo.TAXON_OCCURRENCE_DATA taoMeas
                LEFT JOIN dbo.MEASUREMENT_UNIT MUMeas ON MUMeas.MEASUREMENT_UNIT_KEY = taoMeas.MEASUREMENT_UNIT_KEY 
                LEFT JOIN dbo.MEASUREMENT_QUALIFIER MQMeas ON MQMeas.MEASUREMENT_QUALIFIER_KEY = taoMeas.MEASUREMENT_QUALIFIER_KEY
                LEFT JOIN dbo.MEASUREMENT_TYPE MTMeas ON MTMeas.MEASUREMENT_TYPE_KEY = MQMeas.MEASUREMENT_TYPE_KEY 
            ) tmp
        GROUP BY tmp.TAXON_OCCURRENCE_KEY
    ) Meas ON Meas.TAXON_OCCURRENCE_KEY = TOC.TAXON_OCCURRENCE_KEY

    -- Normalizing to Vernacular names
    LEFT OUTER JOIN (
        SELECT
              TVen.*
            , ROW_NUMBER() OVER (PARTITION by NS.INPUT_TAXON_VERSION_KEY ORDER BY Tven.ITEM_NAME) as Nbr
            , NS.INPUT_TAXON_VERSION_KEY AS [INBO_TAXON_VERSION_KEY]
        FROM [dbo].[NameServer] NS
             INNER JOIN dbo.TAXON_LIST_ITEM TLIVen ON TLIVen.PREFERRED_NAME = NS.RECOMMENDED_TAXON_LIST_ITEM_KEY
             INNER JOIN dbo.TAXON_VERSION TVVen ON TVVen.TAXON_VERSION_KEY = TLIVen.TAXON_VERSION_KEY
             INNER JOIN dbo.TAXON TVen ON TVVen.TAXON_KEY = TVen.TAXON_KEY
        WHERE TVen.[LANGUAGE] = 'nl'
    ) NormNaam ON NormNaam.[INBO_TAXON_VERSION_KEY] = tlitd.[TAXON_VERSION_KEY] AND NormNaam.Nbr = 1                    

WHERE 1=1
    --AND TOC.TAXON_OCCURRENCE_KEY LIKE 'BFN0017900009PDP'  --duplicates!
    AND TD.PREFERRED = 1
    AND LN.PREFERRED = 1
    --AND ISNUMERIC (SUBSTRING(LN.[ITEM_NAME],2,1)) = 0
    --AND TOC.CONFIDENTIAL = 0
    AND NSR.RECOMMENDED_TAXON_VERSION_KEY IN ({}) -- The list of taxon keys is populated with a Jupyter notebook
    AND S.SURVEY_KEY IN ({}) -- The list of survey keys is populated with a Jupyter notebook
