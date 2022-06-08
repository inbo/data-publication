USE [D0012_00_Flora]
GO

/****** Object:  View [ipt].[vwGBif_mossen]    Script Date: 8/06/2022 14:40:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








ALTER VIEW [ipt].[vwGBif_mossen] 
AS



/*********************************************************/
/*                                                       
ChangeLog IPT (2013-01-07) 
	add (Fixed) term [type] =  '.....'
	Cahnged (Fixed) term  [Language] = 'EN'
	add (Fixed) term [Rightsholder] =  'INBO'
	add (Fixed) term [bibliographicCitation] = '....'
	add (Fixed) term [DatasetID]
	Change termname CollectionCode To DatasetName
	Change (Fixed) term [ownerInstitutionCode] from 'FLower' TO 'INBO'
	add (Fixed) term [dataGeneralizations] = '...'
	change termname occurrenceDetails to References
	add (Fixed) term [continent] = 'Europe'
	change termname Country to CountryCode
	add (Fixed) term [Country] = 'BELGIUM'
	add (Fixed) term [Kingdom] = 'Plantae'
	
Change IPT (2014-10-07)
	Change Rights From 'http://creativecommons.org/licenses/by-nc-sa/3.0/' to 'http://creativecommons.org/publicdomain/zero/1.0/ & https://github.com/LifeWatchINBO/norms-for-data-use'
	
CHANGE IPT (2015-08-17)
	add accessrights, remove rights , add license
	Change globalUniqueIdentifier --> occurrenceID

--Modif 20150908 => Eventdate to Single date ( no range ), range => [verbatimEventDate]
-- Aanpasing 20160113 tblNameServer_12 => NameServer_12

*/
/*********************************************************/


SELECT  
		[occurrenceID] = 'INBO:FLORA:' + Right( '000000000' + CONVERT(nvarchar(20),tMt.METI_ID),8) 
		--, [modified] = CASE 
		--	WHEN tW.WRNG_USR_CRE_DTE  IS NOT NULL
		--		AND tW.WRNG_USR_CRE_DTE >= COALESCE(tMt.METI_USR_CRE_DTE, CONVERT(Date,'1900-01-01',120) )
		--		AND tW.WRNG_USR_CRE_DTE >= COALESCE(tMt.METI_USR_UPD_DTE, CONVERT(Date,'1900-01-01',120) )
		--		AND tW.WRNG_USR_CRE_DTE >= COALESCE(tW.WRNG_USR_UPD_DTE, CONVERT(Date,'1900-01-01',120) )
		--		THEN CONVERT(Date, tW.WRNG_USR_CRE_DTE ,120) 
				
		--	WHEN tW.WRNG_USR_UPD_DTE  IS NOT NULL
		--		AND tW.WRNG_USR_UPD_DTE >= COALESCE(tMt.METI_USR_CRE_DTE , CONVERT(Date,'1900-01-01',120) )
		--		AND tW.WRNG_USR_UPD_DTE >= COALESCE(tMt.METI_USR_UPD_DTE, CONVERT(Date,'1900-01-01',120) )
		--		AND tW.WRNG_USR_UPD_DTE >= COALESCE(tW.WRNG_USR_CRE_DTE, CONVERT(Date,'1900-01-01',120) )
		--		THEN CONVERT(Date, tW.WRNG_USR_UPD_DTE ,120) 	
						
		--	WHEN tMt.METI_USR_CRE_DTE IS NOT NULL
		--		AND tMt.METI_USR_CRE_DTE >= COALESCE(tMt.METI_USR_UPD_DTE , CONVERT(Date,'1900-01-01',120) )
		--		AND tMt.METI_USR_CRE_DTE >= COALESCE(tW.WRNG_USR_CRE_DTE, CONVERT(Date,'1900-01-01',120) )
		--		AND tMt.METI_USR_CRE_DTE >= COALESCE(tW.WRNG_USR_UPD_DTE, CONVERT(Date,'1900-01-01',120) )
		--		THEN CONVERT(Date, tMt.METI_USR_CRE_DTE ,120) 
				
		--	WHEN tMt.METI_USR_UPD_DTE IS NOT NULL
		--		AND tMt.METI_USR_UPD_DTE >= COALESCE(tMt.METI_USR_CRE_DTE, CONVERT(Date,'1900-01-01',120) )
		--		AND tMt.METI_USR_UPD_DTE >= COALESCE(tW.WRNG_USR_CRE_DTE, CONVERT(Date,'1900-01-01',120) )
		--		AND tMt.METI_USR_UPD_DTE >= COALESCE(tW.WRNG_USR_UPD_DTE, CONVERT(Date,'1900-01-01',120) )
		--		THEN CONVERT(Date, tMt.METI_USR_UPD_DTE ,120) 
				
		--	ELSE CONVERT(Date, GETDATE(),120) 
		--END 

		, [verbatimLocality] = tW.WRNG_OPM 
		
		, [basisOfRecord] = CONVERT(Nvarchar(20),'HumanObservation')
		, [institutionCode] = CONVERT(Nvarchar(20),'INBO') 
		, [language] = CONVERT(Nvarchar(20),'EN') 
	--	, [catalogNumber] = Right( '000000000' + CONVERT(nvarchar(20),tMt.METI_ID),8)
		, [collectionCode] = 'IFBL'
-- Taxonomic Elements --
		--, [originalNameUsage] = tT.TAXN_NAM_WET 
		, [scientificName] = ns.RECOMMENDED_SCIENTIFIC_NAME    --recommended scientific soort + genus 
		, [vernacularName] = tT.TAXN_NAM_NED
---		NULL::text AS HigherTaxon,
		, [kingdom] = CONVERT(Nvarchar(10),'Plantae')
--- 	NULL::text AS Phylum, 
---		tc.name::text AS Class, 
---		NULL::text AS Order, 
---		tf.name::text AS Family, 
---		tg.name::text AS Genus, 
---		ts.name::text AS SpecificEpithet, 
		--, [verbatimTaxonRank] = NS.RECOMMENDED_NAME_RANK  -- recomended rank 
		, [taxonRank] = LOWER (NS.RECOMMENDED_NAME_RANK_LONG)
---		NULL::text AS InfraSpecificEpithet,
		, [scientificNameAuthorship] = NS.RECOMMENDED_NAME_AUTHORITY + ISNULL ( ' ' + NS.RECOMMENDED_NAME_QUALIFIER , '')
		--, NS. 	-- recommended auth 
		, [nomenclaturalCode] = CONVERT(Nvarchar(20),'ICBN')
		--tT.TAXN_NAM_WET , -debugging
-- Identification Elements --

-- Locality Elements --
	--	, [country] = CONVERt(Nvarchar(20),'BELGIUM') 
		, [countryCode] = CONVERt(Nvarchar(20),'BE')  
-- Collecting Event Elements --
		, [eventDate] = CONVERT(Nvarchar(12) , tW.WRNG_BEG_DTE , 120)  + '/' + CONVERT(Nvarchar(12) , tW.WRNG_END_DTE , 120)  
	--	, [eventDate] = CONVERT(Nvarchar(12) , tW.WRNG_BEG_DTE , 120)  
		, [recordedBy] = dbo.ufn_MedewerkersPerWaarneming(tW.WRNG_ID) 
		, [occurrenceStatus] = 'present'
-- Biological Elements --

-- References Elements --

		
-- Curatorial Extension --
	--	, [catalogNumberNumeric] = tMt.METI_ID 
		


-- Geospatial Extension --
		, [decimalLatitude] = CONVERT(Nvarchar(20),convert(decimal(12,5),round(tI84.IFBL_LAT,5)) )
		, [decimalLongitude] = CONVERT(Nvarchar(20),convert(decimal(12,5),round(tI84.IFBL_LONG,5)) ) 
		, [GeodeticDatum] = CONVERT(Nvarchar(10),'WGS84') 
		--CONVERT(Nvarchar(10),ROUND(tIH.IFBL_COR_Y,3)) AS verbatimLatitude, 
		--CONVERT(Nvarchar(10),ROUND(tIH.IFBL_COR_X,3)) AS verbatimLongitude, 
		--CONVERT(Nvarchar(10),'EPSG:31370') AS verbatimCoordinateSystem, 
		, [coordinateUncertaintyInMeters] = CONVERT(Nvarchar(5),
			CONVERT(INT, CASE 
				WHEN cHP.HOPR_CDE = 1 THEN 	700  --zeker kmhok
				WHEN cHP.HOPR_CDE = 2 THEN 	2800  --zeker uurhok
				WHEN cHP.HOPR_CDE = 3 THEN 	10000  --onzeker uurhok
				WHEN cHP.HOPR_CDE = 4 THEN 	1000  --voorkeur kmhok
				WHEN cHP.HOPR_CDE = 5 THEN 	3500  --voorkeur uurhok			
				ELSE 10000	
			END )
			) 

---		NULL::text AS PointRadiusSpatialFit,

		, [verbatimCoordinates] = tIH.IFBL_CDE 

	    , [verbatimCoordinateSystem] = CASE 
				WHEN LEN([tIH].[IFBL_CDE]) > 5 THEN 'IFBL 1km'
				ELSE 'IFBL 4km'
			END 	
		--, [VerbatimSRS] = 'ED50' --/ WGS84 --BD72
		
		
	    , [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
        , [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
		, [type] = CONVERT(Nvarchar(20),'Event')
		, [bibliographicCitation] = CONVERT(Nvarchar(300),'to complete' )
		, [datasetID] = CONVERT(Nvarchar(100),'to complete')
		
		, [datasetName] = CONVERT(Nvarchar(200),'FLORABANK 2: a grid-based database on the distribution of mosses in the northern part of Belgium (Flanders and the Brussels Capital region)')
	--	, [ownerInstitutionCode] = CONVERT(Nvarchar(20),'INBO') 
		, [georeferenceRemarks] = CONVERT(Nvarchar(100),'The centroid coördinates of the IFBL square containing the occurence were given')
		, [occurrenceRemarks] = CASE cB.BRON_DES 
									WHEN 'literatuur' THEN 'occurrence derived from literature'
									WHEN 'losse waarneming' THEN 'casual observation'
									WHEN 'Biologische Waarderingskaart' THEN 'biological valuation map'
									WHEN 'Gewestelijke Bosinventarisatie' THEN 'forest inventarisation'
									WHEN 'Monitoring bosreservaten' THEN 'monitoring forest reserves'
									ELSE  cB.BRON_DES
									END
		, [continent] = 'Europe'
		
		
	FROM [dbo].[tblWaarneming] tW 
		INNER JOIN [dbo].[tblMeting] tMt ON ( tMt.METI_WRNG_ID = tW.WRNG_ID )
		INNER JOIN [dbo].[tblIFBLHok] tIH ON ( tW.WRNG_IFBL_ID = tIH.IFBL_ID )
		INNER JOIN [dbo].[tblIFBLWGS84] tI84 ON ( tI84.IFBL_ID = tIH.IFBL_ID  ) 
		LEFT JOIN  [dbo].[cdeHokPrecisie] cHP ON ( tW.WRNG_HOPR_CDE = cHP.HOPR_CDE )
		INNER JOIN [dbo].[cdeWaarnemingStatus] cWS ON ( tW.WRNG_WGST_CDE = cWS.WGST_CDE )
		INNER JOIN [dbo].[cdeBron] cB ON ( cB.BRON_CDE = tW.WRNG_BRON_CDE )
		--LEFT JOIN [dbo].[relWaarnemingMedewerker] rWM ON ( tW.WRNG_ID = rWM.WGMW_WRNG_ID )
		--LEFT JOIN [dbo].[cdeWaarnemingMedewerkerType] cWMT ON ( cWMT.WMTP_CDE = rWM.WGMW_WMTP_CDE )
		--LEFT JOIN [dbo].[tblMedewerker] tM ON ( rWM.WGMW_MDWK_ID = tM.MDWK_ID )
		--LEFT JOIN [dbo].[Person] P ON (tM.MDWK_PERS_CDE = P.PERS_CDE)
		
		INNER JOIN [dbo].[tblTaxon] tT ON (tT.TAXN_ID = tMt.METI_TAXN_ID)
		INNER JOIN [D0017_00_NBNData].[inbo].[NameServer_12] NS ON ( NS.INBO_TAXON_VERSION_KEY = tT.TAXN_VRS_KEY COLLATE Latin1_General_CI_AI )
		INNER JOIN [dbo].[cdeMetingStatus] cMS ON (cms.MEST_CDE = tMt.METI_MEST_CDE)
		INNER JOIN [dbo].[cdeWaarnemingStatus] cW ON (cW.WGST_CDE = tW.WRNG_WGST_CDE)
	--dbo.cdeWaarnemingMedewerkerType
	WHERE 1=1 
	--AND tW.WRNG_ID = 20
	--AND tMt.METI_USR_CRE_DTE IS NOT NULL
	AND  (tW.WRNG_BEG_DTE >= CONVERT(Date , '1972-01-01' , 120)
		OR (tW.WRNG_BEG_DTE < CONVERT(Date , '1972-01-01' , 120) 
			AND cB.BRON_DES not like '%streep%') )
	AND cMS.MEST_CDE in ( 'GDGA','GDGK' )
	AND cW.WGST_CDE = 'GCTR'
	AND NS.[INFORMAL GROUP] IN ('mos','hauwmos','korstmos','levermos')

--	('biesvaren', 'wolfsklauw', 'varen', 'paardenstaart', 'ginkgo', 'conifeer', 'bloemplant')
	--ORDER BY tW.WRNG_ID, tMt.METI_ID
		





























GO


