USE [W0001_00_Vis]
GO

/****** Object:  View [ipt].[vwGBif_VIS_non_native-fish_occurrence]    Script Date: 12/05/2021 10:29:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











-- 20150909 added verbatimEventDate  changed EventDate to singeDate
-- 2021_04_15 arrange query


ALTER VIEW [ipt].[vwGBif_VIS_non_native-fish_occurrence]
	AS

SELECT
	  [occurrenceID] = N'INBO:VIS:EXO:' + Right( N'000000000' + CONVERT(nvarchar(20), [fm].[MetingID]), 8)
	, [eventID] = N'INBO:VIS:Ev:' + Right( N'000000000' + CONVERT(nvarchar(20), [dw].[WaarnemingKey]), 8)
	, [collectionCode] = 'VIS'
	, [recordedBy] = N'Hugo Verreycken'
    , [basisOfRecord] = N'HumanObservation'
	, [individualCount] = CONVERT(int, fm.Waarde)
--	, [occurrenceRemarks] = N'{"depletionRun":' + ', ' + Convert(nvarchar(20), Convert(int,AfVisbeurtNR)) + '}'
    , [identifiedBy] = N'Hugo Verreycken'
	, [scientificName] =
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
    , [nomenclaturalCode] = N'ICZN'
	, [occurrenceStatus] = CASE
	                  WHEN CONVERT(int, fm.Waarde) > 0 THEN 'Present'
					  ELSE 'absent'
					  END
    
    -- , dt.TaxonKey
    -- , dt.NBN_VERSIONKEY
    -- , dw.WaarnemingID
	-- , [fm].[MetingID]
	-- , [dw].[WaarnemingKey]
    -- , dp.Projectcode
    -- , dp.Projectnaam

--SELECT *
FROM dbo.DimProject dp
	INNER JOIN dbo.DimWaarneming dw ON dw.ProjectKey = dp.ProjectKey
	INNER JOIN dbo.DimGebied dg ON dg.GebiedKey = dw.GebiedKey
	INNER JOIN dbo.DimMethode dm ON dm.MethodeKey = dw.MethodeKey
	INNER JOIN dbo.FactMeting fm ON fm.WaarnemingKey = dw.WaarnemingKey
	INNER JOIN dbo.DimVariabele dv ON dv.Variabelecode = 'TAXONAANTAL' AND dv.VariabeleKey = fm.VariabeleKey
	LEFT OUTER JOIN dbo.DimTaxon dt ON dt.TaxonKey = fm.TaxonKey
	LEFT OUTER JOIN  syno.Nameserver_12 ns ON   NS.INBO_TAXON_VERSION_KEY = dt.NBN_VERSIONKEY COLLATE Latin1_General_CI_AI 
	inner join dbo.DimAfvisbeurtNR paf ON paf.AfVisbeurtNRKey = fm.AfVisbeurtNrKey 
	
WHERE 
	dp.Projectnaam IN ('Niet-inheemse vissoorten')
	AND dt.WetenschappelijkeNaam <> '-'
	AND CONVERT(int, fm.Waarde) > 0
	AND CONVERT(Nvarchar(10), dw.Begindatum, 120) < '2021-01-01'
	AND dm.Methodenaam not like 'Niet gevist'
--AND AfVisbeurtNR > 1












GO


