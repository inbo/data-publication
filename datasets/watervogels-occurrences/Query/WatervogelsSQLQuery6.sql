USE [W0004_00_Waterbirds]
GO

/****** Object:  View [iptdev].[vwGBIF_INBO_Watervogels_new_occurrences]    Script Date: 22/03/2018 10:36:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**ALTER VIEW [iptdev].[vwGBIF_INBO_Watervogels_new_occurrences]
AS **/

SELECT  TOP 1000
	  [eventID ] = N'INBO:WATERVOGELS:Se:' + Right( N'000000000' + CONVERT(nvarchar(20) ,ds.SampleKey),10)  
	, [type] = N'Event'
	, [language] = N'en'
	, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
	, [rightsHolder] = N'INBO'
	, [accessRights] = N'https://github.com/LifeWatchINBO/norms-for-data-use'
	, [datasetID] = N'http://doi.org/10.15468/lj0udq'
	, [institutionCode] = N'INBO'
	, [datasetName] = N'Watervogels - Wintering waterbirds in Flanders, Belgium'
	, [ownerInstitutionCode] = N'INBO'
	, [basisOfRecord] = N'HumanObservation'
	, [occurrenceID] = N'INBO:WATERVOGELS:Occ:' + Right( N'000000000' + CONVERT(nvarchar(20) ,fta.OccurrenceKey),10)
	, ds.PrimaryRecorderNaam 
	, ds.IceCoverDescription 
	, '<!!> ' as SplitOccurence
	, fta.OccurrenceKey
	, fta.TaxonCount as 'individualCount'
	, '<!!> ' as SplitTaxon
	, dt.LijstNaam
	, dt.Author
	, dt.TaxonNaam
	, dt.TaxonRank
	, dt.TaxonLanguage
	, '<!!>' as SplitTaxonWV
	, dtw.euringcode
	, '<!!>' as SplitLocationWV
	, lwv.LocationWVNaam
	, lwv.LocationGeometry.STCentroid() as LocCenter

	, [eventRemarks] = 
		'{'
		+
		CASE samplecondition
			WHEN 'FAVORABLE' THEN '"samplingConditions":"favourable", ' -- Gunstig / normaal
			WHEN 'UNFAVORABLE' THEN '"samplingConditions":"unfavourable", ' -- Ongunstig
			ELSE '' 
		END
		+
		CASE CoverageCode
			WHEN 'V' THEN '"samplingCoverage":"complete", ' -- Volledig
			WHEN 'O' THEN '"samplingCoverage":"incomplete", ' -- Onvolledig
			WHEN 'N' THEN '' -- Niet geteld;  -> should return no data, as we select on having a scientificName
			WHEN 'X' THEN '' -- Geteld, geen vogels -> should return no data, as we select on having a scientificName
			ELSE ''
		END
		+
		CASE SnowCoverCode 
			WHEN 'N' THEN '"snow":"none", ' -- Geen
			WHEN 'E' THEN '"snow":"everywhere", ' -- Overal
			WHEN 'L' THEN '"snow":"locally", ' -- Plaatselijk
			ELSE ''
		END
		+ CASE IceCoverCode
			WHEN 'N' THEN '"ice":"0%", ' -- Geen
			WHEN 'M' THEN '"ice":">50%", ' -- < 50 %
			WHEN 'L' THEN '"ice":"<50%", ' -- > 50 %
			WHEN 'F' THEN '"ice":"100%", ' -- 100%
			ELSE ''
		END
		+ CASE WaterLevelCode
			WHEN 'N' THEN '"waterLevel":"normal"' -- Normaal
			WHEN 'L' THEN '"waterLevel":"low"' -- Laag
			WHEN 'H' THEN '"waterLevel":"high"' -- Hoog
			ELSE ''
		END
		+
		'}'

--	, [scientificName] = isnull(ITEM_NAME, tS.SPEC_NAM_WET)  --originale wet naam terug nemen
--	, [originalScientificName] = TaxonNaam
	, [kingdom] = N'Animalia'
	, [phylum] = N'Chordata'
	, [class] = N'Aves'
--	, [taxonRank] = N'species'
	, [scientificNameAuthorship] = AUTHOR
	, [vernacularName] = commonname
--	, [vernacularNameEN] = tS.SPEC_NAM_ENG
--	, [vernacularNameFR] = tS.SPEC_NAM_FRA
	, [nomenclaturalCode] = N'ICZN'
--	, [projectCode] =ProjectInfo.ProjectenLijst


FROM dbo.DimSample ds 
INNER JOIN dbo.FactTaxonOccurrence fta ON fta.SampleKey = ds.SampleKey
INNER JOIN dbo.DimTaxon dt ON dt.NBN_Taxon_List_Item_Key = fta.RecommendedTaxonTLI_Key
INNER JOIN dbo.DimTaxonWV dtw ON dtw.TaxonWVKey = fta.TaxonWVKey
INNER JOIN dbo.DimLocationWV lwv ON lwv.LocationWVKey = fta.LocationWVKey
WHERE ds.SampleKey > 0
AND fta.TaxonCount > 0


GO


