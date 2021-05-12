USE [W0001_00_Vis]
GO

/****** Object:  View [ipt].[vwGBif_VIS_non_native_fish_event]    Script Date: 12/05/2021 11:53:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









-- 20150909 added verbatimEventDate  changed EventDate to singeDate
-- 2021_05_05 pick up again


ALTER VIEW [ipt].[vwGBif_VIS_non_native_fish_event]
	AS

SELECT
	
--	 [occurrenceID] = N'INBO:VIS:Occ:' + Right( N'000000000' + CONVERT(nvarchar(20), [fm].[MetingID]), 8) 
	 [eventID] = N'INBO:VIS:Ev:' + Right( N'000000000' + CONVERT(nvarchar(20), [dw].[WaarnemingKey]), 8)
    , [type] = N'Event'
    , [language] = N'en'
    , [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
    , [rightsHolder] = N'INBO'
    , [accessRights] = N'https://www.vlaanderen.be/inbo/en-gb/norms-for-data-use/'
    , [datasetID] = N'to complete'
    , [institutionCode] = N'INBO'
    , [datasetName] = N'VIS - Non-native Fish in Flanders, Belgium'
    , [informationWithheld] = 'Length and weight measurements available upon request.'
	, [habitat] = N'stream or river'
		/**CASE
			WHEN dp.Projectnaam = 'Referentiemeetnet' THEN  'stream, river'
			WHEN dp.Projectnaam = 'Visbestand stilstaande waters' THEN 'enclosed water'
			ELSE ''
		END **/
    , [samplingProtocol] = 
        CASE dm.Methodenaam
            WHEN 'Elektrisch boot' THEN 'electrofishing'
            WHEN 'Elektrisch boot 1 elektrode' THEN 'electrofishing with 1 anode by boat'
            WHEN 'Elektrisch boot 2 elektrodes' THEN 'electrofishing with 2 anodes by boat'
            WHEN 'Elektrisch boot 3 elektrodes' THEN 'electrofishing with 3 anodes by boat'
            WHEN 'Elektrovisserij' THEN 'electrofishing'
            WHEN 'Elektrisch wadend' THEN 'electrofishing by wading'
            WHEN 'Elektrisch wadend 1 elektrode' THEN 'electrofishing with 1 anode by wading'
            WHEN 'Elektrisch wadend 2 elektrodes' THEN 'electrofishing with 2 anodes by wading'
            WHEN 'Elektrisch wadend 3 elektrodes' THEN 'electrofishing with 3 anodes by wading'
            WHEN 'Elektrisch wadend 4 elektrodes' THEN 'electrofishing with 4 anodes by wading'
            WHEN 'Hokfuik' THEN 'pound nets'
            WHEN 'Kieuwnet' THEN 'gill net'
            WHEN 'Kuilvisserij' THEN 'anchor netting'
            WHEN 'Niet gevist' THEN 'no fishing'
            WHEN 'Palingfuik' THEN 'eel fyke'
            WHEN 'Schietfuik' THEN 'paired fyke nets'
            WHEN 'Schepnetje' THEN 'dipnet'
            WHEN 'Sleepnet' THEN 'seine netting'
			WHEN 'Hengel' THEN 'angling'
            ELSE 'dm.Methodenaam'
        END
	--, dm.Methodenaam
    , [samplingEffort] = 
        CASE
            WHEN dm.Methodenaam = 'Hengel' THEN '{"timeEffortInHours":1,"squareMeters":1}' 
			WHEN Coalesce( AantalDagen,0) = 0 AND COALESCE (AantalFuiken, 0 ) = 0 THEN '{"trajectLengthInMeters":' + Convert(nvarchar(20), Convert(int,dw.LengteTraject)) /**+' , ' +'"depletiontrack":' + Convert(nvarchar(20), Convert(int,AfVisbeurtNR))+**/ + '}'
			WHEN AantalDagen <> 0 AND AantalFuiken = 0 THEN N'{"numberOfDays":' + Convert(nvarchar(20), Convert(int,AantalDagen)) + '}'
            WHEN AantalDagen = 0 AND AantalFuiken <> 0 THEN N'{"numberOfFykes":' + Convert(nvarchar(20), Convert(int,AantalFuiken)) + '}'
            WHEN AantalDagen <> 0 AND AantalFuiken <> 0 THEN N'{"numberOfFykes":' + Convert(nvarchar(20), Convert(int,AantalFuiken)) + N' , "numberOfDays":' +  Convert(nvarchar(20), AantalDagen) + '}'
            WHEN AantalDagen IS NULL OR AantalFuiken IS NULL THEN 'depletionFishing'
			ELSE ''
        END 
	--, dw.LengteTraject
	--, AantalDagen
	--, AantalFuiken
	--, AfVisbeurtnr 
    , [eventDate] = CONVERT(Nvarchar(10), dw.Begindatum, 120) + N'/' + CONVERT(Nvarchar(10), dw.Einddatum, 120)
	, [verbatimEventDate] = CONVERT(Nvarchar(10), dw.Begindatum, 120) + N'/' + CONVERT(Nvarchar(10), dw.Einddatum, 120)
	, [locationID] = N'visbestanden:' + dg.Gebiedcode
    , [continent] = N'Europe'
    , [waterBody] = dg.VHAG
    , [countryCode] = N'BE'
    , [verbatimLocality] = dg.Gebiednaam
    , [decimalLatitude] = dg.Lat
    , [decimalLongitude] = dg.Long
    , [geodeticDatum] = N'WGS84'
    , [coordinateUncertaintyInMeters] = CONVERT(int, 250)
    , [verbatimLatitude] = CONVERT(INT,Round(dg.LambertY, 0))
    , [verbatimLongitude] = CONVERT(INT,Round(dg.LambertX, 0))
    , [verbatimCoordinateSystem] = N'Belgium Lambert 72'
    , [verbatimSRS] = N'Belgium Datum 1972'
    
 --   , [identifiedBy] = N'Gerlinde Van Thuyne'

/**	, [scientificName] =
        CASE 
            WHEN ns.INBO_TAXON_VERSION_KEY IS NULL THEN dt.WetenschappelijkeNaam
            ELSE ns.TAXON_NAME COLLATE Latin1_General_CI_AI 
        END
    , [kingdom] = N'Animalia'
    , [taxonRank] =
        CASE
            WHEN ns.INBO_TAXON_VERSION_KEY IS NULL THEN ''
            ELSE LOWER(Ns.Recommended_name_rank_long) COLLATE Latin1_General_CI_AI 
        END
    , [scientificNameAuthorship] = 
        CASE
            WHEN ns.INBO_TAXON_VERSION_KEY IS NULL THEN ''
            ELSE  ns.TAXON_AUTHORITY COLLATE Latin1_General_CI_AI 
        END
    , [vernacularName] = dt.Soort
    , [nomenclaturalCode] = N'ICZN' **/
    
    -- , dt.TaxonKey
    -- , dt.NBN_VERSIONKEY
    -- , dw.WaarnemingID
    -- , dp.Projectcode
    -- , dp.Projectnaam

/**FROM dbo.DimProject dp
	INNER JOIN dbo.DimWaarneming dw ON dw.ProjectKey = dp.ProjectKey
	INNER JOIN dbo.DimGebied dg ON dg.GebiedKey = dw.GebiedKey
	INNER JOIN dbo.DimMethode dm ON dm.MethodeKey = dw.MethodeKey
	INNER JOIN dbo.FactMeting fm ON fm.WaarnemingKey = dw.WaarnemingKey
	INNER JOIN dbo.DimVariabele dv ON dv.Variabelecode = 'TAXONAANTAL' AND dv.VariabeleKey = fm.VariabeleKey
	LEFT OUTER JOIN dbo.DimTaxon dt ON dt.TaxonKey = fm.TaxonKey
	LEFT OUTER JOIN  NBNData.inbo.Nameserver_12 ns ON   NS.INBO_TAXON_VERSION_KEY = dt.NBN_VERSIONKEY COLLATE Latin1_General_CI_AI 
	inner join dbo.DimAfvisbeurtNR paf ON paf.AfVisbeurtNRKey = fm.AfVisbeurtNrKey 
WHERE 
	dp.Projectnaam IN ('Referentiemeetnet')
	AND dt.WetenschappelijkeNaam <> '-'
--AND AfVisbeurtNR > 1 **/

--SELECT *
FROM dbo.DimProject dp
	INNER JOIN dbo.DimWaarneming dw ON dw.ProjectKey = dp.ProjectKey
	INNER JOIN dbo.DimGebied dg ON dg.GebiedKey = dw.GebiedKey
	INNER JOIN dbo.DimMethode dm ON dm.MethodeKey = dw.MethodeKey
--	INNER JOIN dbo.FactMeting fm ON fm.WaarnemingKey = dw.WaarnemingKey
--	INNER JOIN dbo.DimVariabele dv ON dv.Variabelecode = 'TAXONAANTAL' AND dv.VariabeleKey = fm.VariabeleKey
--	LEFT OUTER JOIN dbo.DimTaxon dt ON dt.TaxonKey = fm.TaxonKey
--	LEFT OUTER JOIN  NBNData.inbo.Nameserver_12 ns ON   NS.INBO_TAXON_VERSION_KEY = dt.NBN_VERSIONKEY COLLATE Latin1_General_CI_AI 
--	inner join dbo.DimAfvisbeurtNR paf ON paf.AfVisbeurtNRKey = fm.AfVisbeurtNrKey 
WHERE 
	dp.Projectnaam IN ('Niet-inheemse vissoorten')
AND CONVERT(Nvarchar(10), dw.Begindatum, 120) < '2021-01-01'
AND dm.Methodenaam not like 'Niet gevist'	











GO


