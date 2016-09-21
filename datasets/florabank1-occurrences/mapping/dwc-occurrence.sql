USE [Flora_IPT]
GO

/****** Object:  View [ipt].[vwGBif]    Script Date: 03/03/2016 16:57:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [ipt].[vwGBif] 
AS

/*********************************************************/
/*                                                       
ChangeLog IPT (2013-01-07) 
	add (Fixed) term [type] =  '.....'
	Cahnged (Fixed) term  [Language] = 'NL'
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

CHANGE IPT (2015-09-08)
	Eventdate to Single date ( no range ), range => [verbatimEventDate]
CHANGE IPT (2016-01-13)
	tblNameServer_12 => NameServer_12

FROM 2016-06-01: Changelog on github.org/inbo/data-publication
*/
/*********************************************************/

SELECT  
		[occurrenceID] = 'INBO:FLORA:' + Right( '000000000' + CONVERT(nvarchar(20),tMt.METI_ID),8)

		/* Category: Record */
		, [type] = CONVERT(Nvarchar(20),'Event')
		, [language] = CONVERT(Nvarchar(20),'en')
	    , [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
		, [rightsHolder] = 'INBO'
        , [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
		, [bibliographicCitation] = CONVERT(Nvarchar(300),'Van Landuyt W, Vanhecke L, Brosens D (2012) Florabank 1: a grid-based database on vascular plant distribution in the northern part of Belgium (Flanders and the Brussels Capital region). PhytoKeys 12: 59–67. doi: team.3897/phytokeys.12.2849' )
		, [references] = cB.BRON_DES
		, [datasetID] = CONVERT(Nvarchar(100),'http://dx.doi.org/10.3897/phytokeys.12.2849')
		, [institutionCode] = CONVERT(Nvarchar(20),'INBO')
		, [datasetName] = CONVERT(Nvarchar(200),'Florabank 1 - A grid-based database on vascular plant distribution in the northern part of Belgium (Flanders and the Brussels Capital region)')
		, [ownerInstitutionCode] = CONVERT(Nvarchar(20),'INBO')
		, [basisOfRecord] = CONVERT(Nvarchar(20),'HumanObservation')

		/* Category: Occurence */
		, [recordedBy] = dbo.ufn_MedewerkersPerWaarneming(tW.WRNG_ID)		
		
		/* Category: Event */
		, [eventDate] = CONVERT(Nvarchar(12) , tW.WRNG_BEG_DTE , 120)  	
		, [verbatimEventDate] = CONVERT(Nvarchar(12) , tW.WRNG_BEG_DTE , 120)  + '/' + CONVERT(Nvarchar(12) , tW.WRNG_END_DTE , 120)  

		/* Category: Location */
		, [continent] = 'Europe'
		, [countryCode] = CONVERt(Nvarchar(20),'BE')  
		, [verbatimLocality] = tW.WRNG_OPM 
		, [verbatimCoordinates] = tIH.IFBL_CDE
	    , [verbatimCoordinateSystem] = CASE 
										WHEN LEN([tIH].[IFBL_CDE]) > 5 THEN 'IFBL 1km'
										ELSE 'IFBL 4km'
									   END
		, [decimalLatitude] = CONVERT(Nvarchar(20),convert(decimal(12,5),round(tI84.IFBL_LAT,5)) )
		, [decimalLongitude] = CONVERT(Nvarchar(20),convert(decimal(12,5),round(tI84.IFBL_LONG,5)) ) 
		, [geodeticDatum] = CONVERT(Nvarchar(10),'WGS84')
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
		, [georeferenceRemarks] = CONVERT(Nvarchar(100),'The centroid coördinates of the IFBL square containing the occurence were given')
		
		/* Category: Taxon */
		, [scientificName] = ns.RECOMMENDED_SCIENTIFIC_NAME
		, [kingdom] = CONVERT(Nvarchar(10),'Plantae')
		, [taxonRank] = NS.RECOMMENDED_NAME_RANK_LONG
		, [scientificNameAuthorship] = NS.RECOMMENDED_NAME_AUTHORITY + ISNULL ( ' ' + NS.RECOMMENDED_NAME_QUALIFIER , '')
		, [nomenclaturalCode] = CONVERT(Nvarchar(20),'ICBN')

		/* Following fields are mentioned in the data paper doi: 10.3897/phytokeys.12.2849, butnot taken into account in current updates */
		-- originalNameUsage
		-- verbatimTaxonrank
		-- modified
		
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
		INNER JOIN [NBNData].[inbo].[NameServer_12] NS ON ( NS.INBO_TAXON_VERSION_KEY = tT.TAXN_VRS_KEY COLLATE Latin1_General_CI_AI )
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
	AND NS.[INFORMAL GROUP] IN ('biesvaren', 'wolfsklauw', 'varen', 'paardenstaart', 'ginkgo', 'conifeer', 'bloemplant')

	--ORDER BY tW.WRNG_ID, tMt.METI_ID
		


GO



