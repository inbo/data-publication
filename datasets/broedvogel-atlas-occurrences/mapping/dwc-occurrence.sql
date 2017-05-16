USE [BroedvogelAtlas_IPT]
GO

/****** Object:  View [ipt].[vwGBIF_BroedvogelAtlasOccurrence]    Script Date: 19/09/2016 11:34:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER VIEW [ipt].[vwGBIF_BroedvogelAtlasOccurrence]
    AS

-- ATLASHOKONDERZOEK = GEEL FORMULIER = ATLASHOK
--Modif 20150908 => Eventdate to Single date ( no range ), range => [verbatimEventDate]
SELECT
      [occurrenceID] = N'INBO:BROEDVOGELATLAS:AH:' + RIGHT('00000000' + CONVERT(nvarchar(10), tWAS.WaarnemingID), 8) + ':' + tWAS.SoortCode -- occurrenceID = GUID
    , [type] = N'Event'
    , [language] = N'en'
    , [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
    , [rightsHolder] = N'INBO'
    , [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
    , [datasetID] = N'https://doi.org/10.15468/sccg5a'
    , [institutionCode] = N'INBO'
    , [datasetName] = N'Broedvogels - Atlas of the breeding birds in Flanders 2000-2002'
    , [ownerInstitutionCode] = N'INBO'
    , [basisOfRecord] = N'HumanObservation'

    , [recordedBy] = tW.Voornaam + ' ' + tW.Naam + COALESCE(' | ' + REPLACE(tWH.MedeWaarnemers,char(13)+char(10),' | '),'')
    , [individualCount] = tWAS.Aantal * 2
    , [organismQuantity] = tWAS.Aantal
    , [organismQuantityType] = N'breeding pairs'
    , [behavior] =  
        CASE cBZ.Code
            WHEN 1 THEN 'possibly breeding'
            WHEN 2 THEN 'probably breeding'
            WHEN 3 THEN 'confirmed breeding'
            ELSE ''
        END
    , [verbatimEventDate] = CONVERT(varchar(4), tWH.Jaar) + '-02/' + CONVERT(varchar(4), tWH.Jaar) + '-07' -- Een tijdsperiode van februari tot juni
	, [eventDate] = CONVERT(varchar(4), tWH.Jaar) + '-02'  --De startdatum van februari tot juni
    , [samplingProtocol] = N'Bird Census News 2004 1/2 p.36'
    , [samplingEffort] = 
        CASE
            WHEN tWH.AantalBezoekUren IS NOT NULL THEN '{"observationHours":' + CONVERT(nvarchar(20), tWH.AantalBezoekUren) + '}'
            ELSE ''
        END
    , [sampleSizeValue] = N'25'
    , [sampleSizeUnit] = N'square kilometer'

    , [locationID] = tWH.Atlasblok
    , [continent] = N'Europe'
    , [countryCode] = N'BE'
    , [verbatimLocality] = tWH.Regio
    , [decimalLatitude] = CONVERT(decimal(11,5), utm_5.Lat_wgs84)
    , [decimalLongitude] = CONVERT(decimal(11,5), utm_5.Long_wgs84)
    , [geodeticDatum] = 
        CASE
            WHEN utm_5.Lat_wgs84 + utm_5.Long_wgs84 IS NOT NULL THEN N'WGS84'
        END
    , [coordinateUncertaintyInMeters] =
        CASE
            WHEN utm_5.Lat_wgs84 + utm_5.Long_wgs84 IS NOT NULL THEN 3536
        END
    , [verbatimCoordinates] = '31U' + tWH.Atlasblok
    , [verbatimCoordinateSystem] = N'MGRS'
    , [verbatimSRS] = N'ED50'
    , [georeferenceRemarks] = 
        CASE
            WHEN utm_5.Lat_wgs84 + utm_5.Long_wgs84 IS NOT NULL THEN N'coordinates are centroid of 5x5km grid square'
        END
    
    , [identifiedBy] = tW.Voornaam + ' ' + tW.Naam
        
    , [taxonID] = 'euring:' + euring.Code
    , [scientificName] = euring.NietSoepEend
    , [kingdom] = N'Animalia'
    , [phylum] = N'Chordata'
    , [class] = N'Aves'
    , [taxonRank] = lower(euring.Rank)
    , [scientificNameAuthorship] = euring.Authority
    , [vernacularName] = euring.NederlandseNaam
    , [nomenclaturalCode] = N'ICZN'

FROM dbo.tblWaarnemingHoofd tWH
    INNER JOIN tblWaarnemingAtlasSoort tWAS ON tWAS.WaarnemingID = tWH.ID
    INNER JOIN dbo.tblSoort tS ON tS.Code = tWAS.SoortCode
    INNER JOIN dbo.cdeAtlasblok cAB ON cAB.Code = tWH.Atlasblok
    INNER JOIN dbo.tblWaarnemer tW ON tW.Code = tWH.WaarnemerCode
    LEFT OUTER JOIN dbo.cdeBroedzekerheid cBZ ON cBZ.Code = tWAS.BroedzekerheidCode 
    LEFT OUTER JOIN shp.Locatie_utm5_vl utm_5 ON utm_5.TAG = tWH.Atlasblok COLLATE SQL_Latin1_General_CP1_CI_AI
    LEFT OUTER JOIN (
        SELECT
              T.ITEM_NAME AS NietSoepEend
            , T1.ITEM_NAME AS NederlandseNaam
            , T.Authority
            , TR.Long_name AS Rank
            , cli.Code
        FROM NBNData.inbo.Code_list cl 
            INNER JOIN NBNData.inbo.Code_list_item cli ON cli.Code_List_Key = cl.Code_List_Key
            INNER JOIN NBNData.dbo.TAXON_LIST_ITEM TLI ON TLI.TAXON_LIST_ITEM_KEY = cli.Taxon_List_Item_Key
            INNER JOIN NBNData.dbo.TAXON_COMMON_NAME TCN ON TCN.TAXON_LIST_ITEM_KEY = TLI.TAXON_LIST_ITEM_KEY COLLATE SQL_Latin1_General_CP1_CI_AI
            INNER JOIN NBNData.dbo.TAXON_VERSION TV1 ON TV1.TAXON_VERSION_KEY = TCN.TAXON_VERSION_KEY COLLATE SQL_Latin1_General_CP1_CI_AI
            INNER JOIN NBNData.dbo.Taxon T1 ON T1.TAXON_KEY = TV1.TAXON_KEY COLLATE SQL_Latin1_General_CP1_CI_AI
            INNER JOIN NBNData.dbo.Taxon_rank TR on TR.taxon_rank_key = TLI.taxon_rank_Key
            INNER JOIN NBNData.dbo.NAMESERVER NS ON NS.INPUT_TAXON_VERSION_KEY = TLI.TAXON_VERSION_KEY 
            INNER JOIN NBNData.dbo.TAXON_VERSION TV ON TV.TAXON_VERSION_KEY = NS.RECOMMENDED_TAXON_VERSION_KEY
            INNER JOIN NBNData.dbo.TAXON T ON T.TAXON_KEY = TV.TAXON_KEY
        WHERE cl.item_name = 'euring') euring ON euring.Code = tS.Code COLLATE SQL_Latin1_General_CP1_CI_AI
WHERE 1=1

UNION ALL

-- KILOMETERHOKONDERZOEK = BLAUW FORMULIER = STEEKPROEFHOKJES - SOORTEN
SELECT
      [occurrenceID] = N'INBO:BROEDVOGELATLAS:KM:' + RIGHT('00000000' + CONVERT(nvarchar(10), tWKDS.WaarnemingID), 8) + ':' + RIGHT('00000000' + CONVERT(nvarchar(10), tWKDS.WaarnemingTeller), 8) + ':' + tWKDS.SoortCode + ':' + tWKDS.KilometerHok  -- occurrenceID = GUID
    , [type] = N'Event'
    , [language] = N'en'
    , [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
    , [rightsHolder] = N'INBO'
    , [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
    , [datasetID] = N'https://doi.org/10.15468/sccg5a'
    , [institutionCode] = N'INBO'
    , [datasetName] = N'Broedvogels - Atlas of the breeding birds in Flanders 2000-2002'
    , [ownerInstitutionCode] = N'INBO'
    , [basisOfRecord] = N'HumanObservation'

    , [recordedBy] = tW.Voornaam + ' ' + tW.Naam + COALESCE(' | ' + REPLACE(tWH.MedeWaarnemers,char(13)+char(10),' | '),'')
    , [individualCount] = tWKDS.Aantal * 2
    , [organismQuantity] = tWKDS.Aantal
    , [organismQuantityType] = N'breeding pairs'
    , [behavior] = Null -- Geen broedzekerheid voor dit onderzoek

    , [verbatimEventDate] = NULL
	, [eventDate] = CONVERT(Nvarchar(10), tWKD.Datum, 120)
    , [samplingProtocol] = N'Bird Census News 2004 1/2 p.36'
    , [samplingEffort] = N'{"observationMinutes":55}'
    , [sampleSizeValue] = N'1'
    , [sampleSizeUnit] = N'square kilometer'

    , [locationID] = tWH.Atlasblok
    , [continent] = N'Europe'
    , [countryCode] = N'BE'
    , [verbatimLocality] = tWH.Regio
    , [decimalLatitude] = CONVERT(decimal(11,5), utm_1.Lat_wgs84)
    , [decimalLongitude] = CONVERT(decimal(11,5), utm_1.Long_wgs84)
    , [geodeticDatum] = 
        CASE
            WHEN utm_1.Lat_wgs84 + utm_1.Long_wgs84 IS NOT NULL THEN N'WGS84'
        END
    , [coordinateUncertaintyInMeters] =
        CASE
            WHEN utm_1.Lat_wgs84 + utm_1.Long_wgs84 IS NOT NULL THEN 1414
        END
    , [verbatimCoordinates] = '31U' + tWKD.KilometerHok
    , [verbatimCoordinateSystem] = N'MGRS'
    , [verbatimSRS] = N'ED50'
    , [georeferenceRemarks] = 
        CASE
            WHEN utm_1.Lat_wgs84 + utm_1.Long_wgs84 IS NOT NULL THEN N'coordinates are centroid of 1x1km grid square'
        END

    , [identifiedBy] = tW.Voornaam + ' ' + tW.Naam

    , [taxonID] = 'euring:' + euring.Code
    , [scientificName] = euring.NietSoepEend
    , [kingdom] = N'Animalia'
    , [phylum] = N'Chordata'
    , [class] = N'Aves'
    , [taxonRank] = lower(euring.Rank)
    , [scientificNameAuthorship] = euring.Authority
    , [vernacularName] = Euring.NederlandseNaam
    , [nomenclaturalCode] = N'ICZN'

FROM dbo.tblWaarnemingHoofd tWH
    INNER JOIN dbo.tblWaarnemingKmDatum tWKD ON tWKD.WaarnemingID = tWH.ID
    INNER JOIN dbo.tblWaarnemingKmDatumSoort tWKDS ON tWKDS.WaarnemingID = tWKD.WaarnemingID 
        AND tWKDS.WaarnemingTeller = tWKD.WaarnemingTeller 
        AND tWKDS.KilometerHok = tWKD.KilometerHok
    INNER JOIN dbo.tblSoort tS ON tS.Code = tWKDS.SoortCode
    INNER JOIN dbo.cdeKilometerhok cKH ON cKH.Code = tWKD.KilometerHok
    INNER JOIN dbo.tblWaarnemer tW ON tW.Code = tWH.WaarnemerCode
    LEFT OUTER JOIN shp.Locatie_utm1_vl utm_1 ON utm_1.TAG = tWKD.KilometerHok COLLATE SQL_Latin1_General_CP1_CI_AI
    LEFT OUTER JOIN (
        SELECT
              T.ITEM_NAME AS NietSoepEend
            , T1.ITEM_NAME AS NederlandseNaam
            , T.Authority
            , TR.Long_name AS Rank
            , cli.Code
        FROM NBNData.inbo.Code_list cl 
            INNER JOIN NBNData.inbo.Code_list_item cli ON cli.Code_List_Key = cl.Code_List_Key
            INNER JOIN NBNData.dbo.TAXON_LIST_ITEM TLI ON TLI.TAXON_LIST_ITEM_KEY = cli.Taxon_List_Item_Key
            INNER JOIN NBNData.dbo.TAXON_COMMON_NAME TCN ON TCN.TAXON_LIST_ITEM_KEY = TLI.TAXON_LIST_ITEM_KEY COLLATE SQL_Latin1_General_CP1_CI_AI
            INNER JOIN NBNData.dbo.TAXON_VERSION TV1 ON TV1.TAXON_VERSION_KEY = TCN.TAXON_VERSION_KEY COLLATE SQL_Latin1_General_CP1_CI_AI
            INNER JOIN NBNData.dbo.Taxon T1 ON T1.TAXON_KEY = TV1.TAXON_KEY COLLATE SQL_Latin1_General_CP1_CI_AI
            INNER JOIN NBNData.dbo.Taxon_rank TR on TR.taxon_rank_key = TLI.taxon_rank_Key
            INNER JOIN NBNData.dbo.NAMESERVER NS ON NS.INPUT_TAXON_VERSION_KEY = TLI.TAXON_VERSION_KEY 
            INNER JOIN NBNData.dbo.TAXON_VERSION TV ON TV.TAXON_VERSION_KEY = NS.RECOMMENDED_TAXON_VERSION_KEY
            INNER JOIN NBNData.dbo.TAXON T ON T.TAXON_KEY = TV.TAXON_KEY
        WHERE cl.item_name = 'euring') euring ON euring.Code = tS.Code COLLATE SQL_Latin1_General_CP1_CI_AI
WHERE 1=1

UNION ALL

-- PUNTTELING = ROZE FORMULIER = STEEKPROEFHOKJES - PUNTTELLINGEN
SELECT
      [occurrenceID] = N'INBO:BROEDVOGELATLAS:PT:' + RIGHT('00000000' + CONVERT(nvarchar(10), tWPDS.WaarnemingID), 8) + ':' + RIGHT('00000000' + CONVERT(nvarchar(10), tWPDS.WaarnemingTeller), 8) + ':' + tWPDS.SoortCode + ':' + tWPDS.KilometerHok -- occurrenceID = GUID
    , [type] = N'Event'
    , [language] = N'en'
    , [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
    , [rightsHolder] = N'INBO'
    , [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
    , [datasetID] = N'https://doi.org/10.15468/sccg5a'
    , [institutionCode] = N'INBO'
    , [datasetName] = N'Broedvogels - Atlas of the breeding birds in Flanders 2000-2002'
    , [ownerInstitutionCode] = N'INBO'
    , [basisOfRecord] = N'HumanObservation'

    , [recordedBy] = tW.Voornaam + ' ' + tW.Naam + COALESCE(' | ' + REPLACE(tWH.MedeWaarnemers,char(13)+char(10),' | '),'')
    , [individualCount] = Null -- Geen aantallen voor dit onderzoek
    , [organismQuantity] = Null
    , [organismQuantityType] = Null
    , [behavior] = Null -- Geen broedzekerheid voor dit onderzoek

	, [verbatimEventDate] = NULL
    , [eventDate] = CONVERT(Nvarchar(10), tWPD.Datum, 120)
    , [samplingProtocol] = N'Bird Census News 2004 1/2 p.36'
    , [samplingEffort] = N'{"observationMinutes":5}'
    , [sampleSizeValue] = N'1'
    , [sampleSizeUnit] = N'square kilometer'

    , [locationID] = tWH.Atlasblok
    , [continent] = N'Europe'
    , [countryCode] = N'BE'
    , [verbatimLocality] = tWH.Regio
    , [decimalLatitude] = CONVERT(decimal(11,5), utm_5.Lat_wgs84)
    , [decimalLongitude] = CONVERT(decimal(11,5), utm_5.Long_wgs84)
    , [geodeticDatum] = 
        CASE
            WHEN utm_5.Lat_wgs84 + utm_5.Long_wgs84 IS NOT NULL THEN N'WGS84'
        END
    , [coordinateUncertaintyInMeters] =
        CASE
            WHEN utm_5.Lat_wgs84 + utm_5.Long_wgs84 IS NOT NULL THEN 1414
        END
    , [verbatimCoordinates] = '31U' + tWPD.KilometerHok
    , [verbatimCoordinateSystem] = N'MGRS'
    , [verbatimSRS] = N'ED50'
    , [georeferenceRemarks] = 
        CASE
            WHEN utm_5.Lat_wgs84 + utm_5.Long_wgs84 IS NOT NULL THEN N'coordinates are centroid of 1x1km grid square'
        END

    , [identifiedBy] = tW.Voornaam + ' ' + tW.Naam

    , [taxonID] = 'euring:' + euring.Code
    , [scientificName] = euring.NietSoepEend
    , [kingdom] = N'Animalia'
    , [phylum] = N'Chordata'
    , [class] = N'Aves'
    , [taxonRank] = lower(euring.Rank)
    , [scientificNameAuthorship] = euring.Authority
    , [vernacularName] = euring.NederlandseNaam
    , [nomenclaturalCode] = N'ICZN'

FROM dbo.tblWaarnemingHoofd tWH
    INNER JOIN dbo.tblWaarnemingPuntDatum tWPD ON tWPD.WaarnemingID = tWH.ID
    INNER JOIN dbo.tblWaarnemingPuntDatumSoort tWPDS ON tWPDS.WaarnemingID = tWPD.WaarnemingID 
        AND tWPDS.WaarnemingTeller = tWPD.WaarnemingTeller
        AND tWPDS.KilometerHok = tWPD.KilometerHok
    INNER JOIN dbo.tblSoort tS ON tS.Code = tWPDS.SoortCode
    INNER JOIN dbo.cdeKilometerhok cKH ON cKH.Code = tWPD.KilometerHok
    INNER JOIN dbo.tblWaarnemer tW ON tW.Code = tWH.WaarnemerCode
    LEFT OUTER JOIN shp.Locatie_utm1_vl utm_5 ON utm_5.TAG = tWPD.KilometerHok COLLATE SQL_Latin1_General_CP1_CI_AI
    LEFT OUTER JOIN (
        SELECT
              T.ITEM_NAME AS NietSoepEend
            , T1.ITEM_NAME AS NederlandseNaam
            , T.Authority
            , TR.Long_name AS Rank
            , cli.Code
        FROM NBNData.inbo.Code_list cl
            INNER JOIN NBNData.inbo.Code_list_item cli ON cli.Code_List_Key = cl.Code_List_Key
            INNER JOIN NBNData.dbo.TAXON_LIST_ITEM TLI ON TLI.TAXON_LIST_ITEM_KEY = cli.Taxon_List_Item_Key
            INNER JOIN NBNData.dbo.TAXON_COMMON_NAME TCN ON TCN.TAXON_LIST_ITEM_KEY = TLI.TAXON_LIST_ITEM_KEY COLLATE SQL_Latin1_General_CP1_CI_AI
            INNER JOIN NBNData.dbo.TAXON_VERSION TV1 ON TV1.TAXON_VERSION_KEY = TCN.TAXON_VERSION_KEY COLLATE SQL_Latin1_General_CP1_CI_AI
            INNER JOIN NBNData.dbo.Taxon T1 ON T1.TAXON_KEY = TV1.TAXON_KEY COLLATE SQL_Latin1_General_CP1_CI_AI
            INNER JOIN NBNData.dbo.Taxon_rank TR on TR.taxon_rank_key = TLI.taxon_rank_Key
            INNER JOIN NBNData.dbo.NAMESERVER NS ON NS.INPUT_TAXON_VERSION_KEY = TLI.TAXON_VERSION_KEY 
            INNER JOIN NBNData.dbo.TAXON_VERSION TV ON TV.TAXON_VERSION_KEY = NS.RECOMMENDED_TAXON_VERSION_KEY
            INNER JOIN NBNData.dbo.TAXON T ON T.TAXON_KEY = TV.TAXON_KEY
        WHERE cl.item_name = 'euring') euring ON euring.Code = tS.Code COLLATE SQL_Latin1_General_CP1_CI_AI
WHERE 1=1

UNION ALL

-- LOSSE WAARNEMINGEN
SELECT
      [occurrenceID] = N'INBO:BROEDVOGELATLAS:LW:' + RIGHT('00000000' + CONVERT(nvarchar(10), tWL.ID), 8) + ':' + tWL.SoortCode -- occurrenceID = GUID
    , [type] = N'Event'
    , [language] = N'en'
    , [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
    , [rightsHolder] = N'INBO'
    , [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
    , [datasetID] = N'https://doi.org/10.15468/sccg5a'
    , [institutionCode] = N'INBO'
    , [datasetName] = N'Broedvogels - Atlas of the breeding birds in Flanders 2000-2002'
    , [ownerInstitutionCode] = N'INBO'
    , [basisOfRecord] = N'HumanObservation'

    , [recordedBy] = tW.Voornaam + ' ' + tW.Naam -- Geen medewaarnemers
    , [individualCount] = tWL.Aantal * 2
    , [organismQuantity] = tWL.Aantal
    , [organismQuantityType] = N'breeding pairs'
    , [behavior] =  
        CASE cBZ.Code
            WHEN 1 THEN 'possibly breeding'
            WHEN 2 THEN 'probably breeding'
            WHEN 3 THEN 'confirmed breeding'
            ELSE ''
        END

    , [verbatimEventDate] = CONVERT(varchar(4), tWL.Jaar) + '-02/' + CONVERT(varchar(4), tWL.Jaar) + '-07'
	, [eventDate] = CONVERT(varchar(4), tWL.Jaar) + '-02'
    , [samplingProtocol] = 'loose observations'
    , [samplingEffort] = N'' -- Geen effort voor dit onderzoek
    , [sampleSizeValue] = N'25'
    , [sampleSizeUnit] = N'square kilometer'

    , [locationID] = tWL.Atlasblok
    , [continent] = N'Europe'
    , [countryCode] = N'BE'
    , [verbatimLocality] = tWL.PlaatsOmschrijving
    , [decimalLatitude] = CONVERT(decimal(11,5), utm_5.Lat_wgs84)
    , [decimalLongitude] = CONVERT(decimal(11,5), utm_5.Long_wgs84)
    , [geodeticDatum] = 
        CASE
            WHEN utm_5.Lat_wgs84 + utm_5.Long_wgs84 IS NOT NULL THEN N'WGS84'
        END
    , [coordinateUncertaintyInMeters] = 
        CASE
            WHEN utm_5.Lat_wgs84 + utm_5.Long_wgs84 IS NOT NULL THEN 3536
        END
    , [verbatimCoordinates] = '31U' + tWL.Atlasblok -- KilometerHok is available in this table, but only populated for 18 records => We use Atlashok for all Losse Waarnemingen records
    , [verbatimCoordinateSystem] = N'MGRS'
    , [verbatimSRS] = N'ED50'
    , [georeferenceRemarks] = 
        CASE
            WHEN utm_5.Lat_wgs84 + utm_5.Long_wgs84 IS NOT NULL THEN N'coordinates are centroid of 5x5km grid square'
        END

    , [identifiedBy] = tW.Voornaam + ' ' + tW.Naam
    , [taxonID] = 'euring:' + euring.Code
    , [scientificName] = euring.NietSoepEend
    , [kingdom] = N'Animalia'
    , [phylum] = N'Chordata'
    , [class] = N'Aves'
    , [taxonRank] = lower(euring.Rank)
    , [scientificNameAuthorship] = euring.Authority
    , [vernacularName] = euring.NederlandseNaam
    , [nomenclaturalCode] = N'ICZN'
    
FROM dbo.tblWaarnemingLos tWL
    INNER JOIN dbo.tblSoort tS ON tS.Code = tWL.SoortCode
    INNER JOIN dbo.tblWaarnemer tW ON tW.Code = tWL.WaarnemerCode
    LEFT OUTER JOIN tblWaarnemingAtlasSoort tWAS ON tWAS.WaarnemingID = tWL.ID AND tWAS.SoortCode = tS.Code
    LEFT OUTER JOIN cdeBroedzekerheid cBZ ON cBZ.Code = tWAS.BroedzekerheidCode
    LEFT OUTER JOIN shp.locatie_utm5_vl utm_5 ON utm_5.TAG = tWL.Atlasblok COLLATE SQL_Latin1_General_CP1_CI_AI
    LEFT OUTER JOIN (
        SELECT
              T.ITEM_NAME AS NietSoepEend
            , T1.ITEM_NAME AS NederlandseNaam
            , T.Authority
            , TR.Long_name AS Rank
            , cli.Code
        FROM NBNData.inbo.Code_list cl 
            INNER JOIN NBNData.inbo.Code_list_item cli ON cli.Code_List_Key = cl.Code_List_Key
            INNER JOIN NBNData.dbo.TAXON_LIST_ITEM TLI ON TLI.TAXON_LIST_ITEM_KEY = cli.Taxon_List_Item_Key
            INNER JOIN NBNData.dbo.TAXON_COMMON_NAME TCN ON TCN.TAXON_LIST_ITEM_KEY = TLI.TAXON_LIST_ITEM_KEY COLLATE SQL_Latin1_General_CP1_CI_AI
            INNER JOIN NBNData.dbo.TAXON_VERSION TV1 ON TV1.TAXON_VERSION_KEY = TCN.TAXON_VERSION_KEY COLLATE SQL_Latin1_General_CP1_CI_AI
            INNER JOIN NBNData.dbo.Taxon T1 ON T1.TAXON_KEY = TV1.TAXON_KEY COLLATE SQL_Latin1_General_CP1_CI_AI
            INNER JOIN NBNData.dbo.Taxon_rank TR on TR.taxon_rank_key = TLI.taxon_rank_Key
            INNER JOIN NBNData.dbo.NAMESERVER NS ON NS.INPUT_TAXON_VERSION_KEY = TLI.TAXON_VERSION_KEY 
            INNER JOIN NBNData.dbo.TAXON_VERSION TV ON TV.TAXON_VERSION_KEY = NS.RECOMMENDED_TAXON_VERSION_KEY
            INNER JOIN NBNData.dbo.TAXON T ON T.TAXON_KEY = TV.TAXON_KEY
        WHERE cl.item_name = 'euring') euring ON euring.Code = tS.Code COLLATE SQL_Latin1_General_CP1_CI_AI
    WHERE 1=1






GO


