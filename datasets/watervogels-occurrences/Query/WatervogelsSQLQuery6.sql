SELECT  TOP 1000  *
FROM dbo.DimSample ds 
INNER JOIN dbo.FactTaxonOccurrence fta ON fta.SampleKey = ds.SampleKey
INNER JOIN dbo.DimTaxon dt ON dt.NBN_Taxon_List_Item_Key = fta.RecommendedTaxonTLI_Key
INNER JOIN dbo.DimTaxonWV dtw ON dtw.TaxonWVKey = fta.TaxonWVKey
INNER JOIN dbo.DimLocationWV lwv ON lwv.LocationWVKey = fta.LocationWVKey
WHERE ds.SampleKey > 0
AND fta.TaxonCount > 0