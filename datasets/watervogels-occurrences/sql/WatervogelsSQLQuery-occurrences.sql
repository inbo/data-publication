USE [W0004_00_Waterbirds]
GO

/****** Object:  View [ipt].[vwGBIF_INBO_Watervogels_occurrences]    Script Date: 4/07/2019 9:47:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













ALTER VIEW [ipt].[vwGBIF_INBO_Watervogels_occurrences]
AS



SELECT 

[eventID] = N'INBO:WATERVOGELS:EVENT:' + Right(N'000000' + CONVERT(nvarchar(20) ,dsa.SampleKey),6)  

 ---RECORD---
	 
	/**, [type] = N'Event'
	, [language] = N'en'
	, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
	, [rightsHolder] = N'INBO'
	, [accessRights] = N'https://github.com/LifeWatchINBO/norms-for-data-use'
	, [datasetID] = N'http://doi.org/10.15468/lj0udq'
	, [institutionCode] = N'INBO'
	, [datasetName] = N'Watervogels - Wintering waterbirds in Flanders, Belgium'
	, [ownerInstitutionCode] = N'INBO' **/
	, [basisOfRecord] = N'HumanObservation'
	
	---- OCCURRENCE ---
		
	, [occurrenceID] = N'INBO:WATERVOGELS:OCC:' + Right( N'000000' + CONVERT(nvarchar(20) ,fta.OccurrenceKey),10)
	, [recordedBy] = case dsa.PrimaryRecorderNaam 
						WHEN ' Onbekend' THEN 'unknown'
						WHEN 'INBO Instituut voor Natuur- en Bosonderzoek' THEN 'INBO'
						ELSE dsa.PrimaryRecorderNaam
						END
	

	, fta.TaxonCount as 'individualCount'

	--- TAXON ---

	, [taxonID] = N'euring:' + dtw.euringcode
--	, [scientificName2] = dt.TaxonNaam
	, [scientificName] = scientificname
	, [kingdom] = N'Animalia'
	, [phylum] = N'Chordata'
	, [class] = N'Aves'
	, [taxonRank] = case LOWER (dt.TaxonRank)
					WHEN '-' THEN 'species'
					ELSE LOWER (dt.Taxonrank)
					END
	                
	, [scientificNameAuthorship] = CASE dt.Author
							WHEN '-' THEN ''
							ELSE  dt.Author
							END
	, [vernacularName] = commonname
	, [nomenclaturalCode] = N'ICZN'
	, fta.sampledate
	, fta.surveyKey
	, di.surveyCode

FROM dbo.DimSample dsa 
INNER JOIN dbo.FactTaxonOccurrence fta ON fta.SampleKey = dsa.SampleKey
INNER JOIN dbo.DimTaxon dt ON dt.NBN_Taxon_List_Item_Key = fta.RecommendedTaxonTLI_Key
INNER JOIN dbo.DimTaxonWV dtw ON dtw.TaxonWVKey = fta.TaxonWVKey
INNER JOIN dbo.DimLocationWV lwv ON lwv.LocationWVKey = fta.LocationWVKey

 INNER JOIN dbo.DimSurvey Di on Di.SurveyKey = fta.SurveyKey
							AND Di.SurveyCode IN ('ZSCH','MIDMA')

WHERE dsa.SampleKey > 0
AND fta.TaxonCount > 0
--AND YEAR(fta.sampleDate) < 2016
AND fta.sampleDate < '2016-03-31 00:00:00.000' 
AND dsa.sampleDate > '1991-01-01 00:00:00.000' 
AND LocationGeometry IS NOT NULL

--and commonname like 'Chileense Taling'
--and fta.TaxonCount = '1'
--and dtw.euringcode like '9999%'







GO


