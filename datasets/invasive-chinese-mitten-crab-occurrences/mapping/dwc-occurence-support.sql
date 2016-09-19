USE [VIS_DWH_IPT]
GO

/****** Object:  View [ipt].[vwGBIF_Wolhandkrab]    Script Date: 03/09/2016 16:20:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









-- Modif 20150908 => Eventdate to Single date ( no range ), range => [verbatimEventDate]



ALTER VIEW [ipt].[vwGBIF_Wolhandkrab]
AS
SELECT 
	  [survey] = 'wolhandkrab'
	, [dynamicProperties] = '{"projectName":' + dp.projectnaam + '}'
	, [occurrenceID] = N'INBO:VIS:' + Right( N'000000000' + CONVERT(nvarchar(20), [fm].[MetingID]), 8) -- occurrenceID = GUID
	, [modified] = CONVERT(nvarchar(10), modified.EndTime, 120)
	, [basisOfRecord] = N'HumanObservation'
	, [institutionCode] = N'INBO'
	, [datasetName] = N'INBO_Chinese_mittencrab_occurrences_VIS'
	, [eventID] = N'INBO:EVENT:VIS:' + CONVERT(Nvarchar(50), dw.WaarnemingID ) 
	, [scientificName] =
		CASE 
			WHEN ns.INBO_TAXON_VERSION_KEY IS NULL THEN dt.WetenschappelijkeNaam
			ELSE ns.TAXON_NAME COLLATE Latin1_General_CI_AI 
		END
	, [scientificNameAuthorship] = 
		CASE
			WHEN ns.INBO_TAXON_VERSION_KEY IS NULL THEN ''
			ELSE  ns.TAXON_AUTHORITY COLLATE Latin1_General_CI_AI 
		END

	, [taxonRank] =
		CASE
			WHEN ns.INBO_TAXON_VERSION_KEY IS NULL THEN ''
			ELSE LOWER(Ns.Recommended_name_rank_long) COLLATE Latin1_General_CI_AI 
		END
	, [recordedBy] = N'Jan Breine'
	, [countryCode] = 
		CASE
			WHEN dg.Gebiednaam IN ('paulinapolder', 'Walsoorden') THEN N'NL'
			ELSE N'BE'
		END
	, [verbatimEventDate] = CONVERT(Nvarchar(10), dw.Begindatum, 120) + N'/' + CONVERT(Nvarchar(10), dw.Einddatum, 120)
	, [eventDate] = CONVERT(Nvarchar(10), dw.Begindatum, 120) --+ N'/' + CONVERT(Nvarchar(10), dw.Einddatum, 120)
	, [identifiedBy] = N'Jan Breine'
	, [decimalLatitude] = dg.Lat
	, [decimalLongitude] = dg.Long
	, [geodeticDatum] = N'WGS84'
	, [coordinateUncertaintyInMeters] = CONVERT(int, 250)

	, [verbatimCoordinates] = CONVERT(nvarchar(50), CONVERT(INT,Round(dg.LambertY, 0))) + ', ' + CONVERT(nvarchar(50), CONVERT(INT,Round(dg.LambertX, 0)))
--	, [verbatimLongitude] = 
	, [verbatimCoordinateSystem] = N'Belgium Lambert 72'
	, [verbatimSRS] = N'Belgium Datum 1972'
	, [language] = N'en'
	, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
	, [rightsHolder] = N'INBO'
	, [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
	, [type] = N'Event'
	, [datasetID] = N'http://dataset.inbo.be/invasive-mittencrab-occurrences'
    , [ownerInstitutionCode] = N'INBO'
    
--	, [informationWithheld] = 'Length and weight measurements available upon request.'
	, [individualCount] = CONVERT(int, fm.Waarde)
	, [continent] = N'Europe'
---	, [habitat] = N'estuary'
	, [INFORMAL_GROUP] = N'schaaldier'
	, [nomenclaturalCode] = N'ICZN'
	, [kingdom] = N'Animalia'
	, [verbatimLocality] = dg.Gebiednaam
	, [verbatimLocality_new] = dg.Gebiednaam
	, [locality] = dg.Gebiednaam
	, [locationID] = dg.gebiedcode
	, [locationID2] = dg.gebiedcode
	, [references] = N'VIS'
	, [vernacularName] = dt.Soort
	, [establishmentMeans] = 'invasive alien'
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
			ELSE ''
		END
/**	, [samplingEffort] = 
		CASE
			WHEN AantalDagen = 0 AND AantalFuiken = 0 THEN '{"trajectLengthInMeters":' + Convert(nvarchar(20), Convert(int,dw.LengteTraject)) + '}'
			WHEN AantalDagen <> 0 AND AantalFuiken = 0 THEN N'{"numberOfDays":' + Convert(nvarchar(20), AantalDagen) + '}'
			WHEN AantalDagen = 0 AND AantalFuiken <> 0 THEN N'{"numberOfFykes":' + Convert(nvarchar(20), AantalFuiken) + '}'
			WHEN AantalDagen <> 0 AND AantalFuiken <> 0 THEN N'{"numberOfFykes":' + Convert(nvarchar(20), AantalFuiken) + N', "numberOfDays":' +  Convert(nvarchar(20), AantalDagen) + '}'
			WHEN AantalDagen IS NULL OR AantalFuiken IS NULL THEN ''
			ELSE ''
		END **/
	

--	, [locationID] = N'visbestanden:' + dg.Gebiedcode
	
--	, [waterBody] = dg.VHAG

	
	-- , dt.TaxonKey
	-- , dt.NBN_VERSIONKEY
	-- , dw.WaarnemingID
	-- , dp.Projectcode
	-- , dp.Projectnaam
	
FROM dbo.DimProject dp
	INNER JOIN dbo.DimWaarneming dw ON dw.ProjectKey = dp.ProjectKey
	INNER JOIN dbo.DimGebied dg ON dg.GebiedKey = dw.GebiedKey
	INNER JOIN dbo.DimMethode dm ON dm.MethodeKey = dw.MethodeKey
	INNER JOIN dbo.FactMeting fm ON fm.WaarnemingKey = dw.WaarnemingKey
	INNER JOIN dbo.DimVariabele dv ON dv.Variabelecode = 'TAXONAANTAL' AND dv.VariabeleKey = fm.VariabeleKey
	LEFT OUTER JOIN dbo.DimTaxon dt ON dt.TaxonKey = fm.TaxonKey
	LEFT OUTER JOIN  NBNData.inbo.Nameserver_12 ns ON   NS.INBO_TAXON_VERSION_KEY = dt.NBN_VERSIONKEY COLLATE Latin1_General_CI_AI 
	
	LEFT OUTER JOIN (SELECT dw.WaarnemingID
						, dw.WaarnemingKey 
						, at.EndTime
						, at.Target
					FROM dbo.DimWaarneming dw
						LEFT OUTER JOIN aud.AuditBranch ab ON ab.AuditKey = dw.UpdateAuditKey
						LEFT OUTER JOIN aud.AuditTable at ON at.TableKey = ab.TableKey AND at.[Target] = '[dbo].[DimWaarneming]' ) as modified ON modified.WaarnemingKey = dw.WaarnemingKey

WHERE
	1=1
--	AND dp.Projectnaam IN ('Estuaria') --, 'Estuaria vanaf 2013')
	AND dt.WetenschappelijkeNaam = 'Eriocheir sinensis' 

;
















GO



