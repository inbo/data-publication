USE [W0004_00_Waterbirds]
GO

/****** Object:  View [iptdev].[vwGBIF_INBO_Watervogels_occurrences2019]    Script Date: 17/06/2019 14:25:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [iptdev].[vwGBIF_INBO_Watervogels_occurrences2019]
AS



SELECT 

[eventID] = N'INBO:WATERVOGELS:EVENT:' + Right(N'000000000' + CONVERT(nvarchar(20) ,dsa.SampleKey),10)  

 ---RECORD---
	 
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
	
	---- OCCURRENCE ---
		
	, [occurrenceID] = N'INBO:WATERVOGELS:Occ:' + Right( N'000000000' + CONVERT(nvarchar(20) ,fta.OccurrenceKey),10)
	, [recordedBy] = dsa.PrimaryRecorderNaam 
	, fta.TaxonCount as 'individualCount'

	--- TAXON ---

	, [taxonID] =  dtw.euringcode
	, [scientificName] = dt.TaxonNaam 
	, [kingdom] = N'Animalia'
	, [phylum] = N'Chordata'
	, [class] = N'Aves'
	, [taxonRank] = dt.TaxonRank
	, [scientificNameAuthorship] = dt.Author
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
							AND Di.SurveyCode IN ('ZSCH','NOORD','MIDMA')

WHERE dsa.SampleKey > 0
AND fta.TaxonCount > 0
--AND YEAR(fta.sampleDate) < 2016
AND fta.sampleDate < '2016-03-31 00:00:00.000' 


GO


