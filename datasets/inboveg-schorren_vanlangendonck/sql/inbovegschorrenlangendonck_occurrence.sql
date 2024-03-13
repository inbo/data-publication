USE [D0010_00_Cydonia]
GO

/****** Object:  View [ipt].[INBOVegNicheVlaanderenOccurrenceCore]    Script Date: 13/03/2024 11:46:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










/****** Object:  View [ipt].[INBOVegNicheVlaanderenOccurrenceCore]    Script Date: 6/06/2016 11:43:07 ******/

CREATE VIEW [ipt].[INBOVegSchorrenLangendonckOccurrenceCore]
AS
SELECT s.ID
	
	, [eventId] = N'INBO:INBOVEG:' + Right( N'000000000' + CONVERT(nvarchar(20), r.recordingGivid), 19)
	, r.recordingGivid
--	, SurveyGivid as parentEventID  (removed because not resolvable)
	, s.Name as SurveyName
---	, '<!!!>' as Split1
	, tax.actionGroup
	, [basisOfRecord] = 'materialSample'
---	, [type] = 'event'
---	, resourceGIVID 
---	, '<!!!>' as Split2
---	, rq.QualifierCode as 'LocationID'  /** peilpunt ID **/
---	, r.LocationCode 
---	, r.UserReference
---	, r.ElementCode
	, [occurrenceID] = N'INBO:INBOVEG:OCC:' + Right( N'000000000' + CONVERT(nvarchar(20), [OccurrenceID]), 8) -- occurrenceID = GUID + occurrenceID
	--, occurrenceID
	--, [identifiedBy] = i.Determiner
	, [identifiedBy] = Pers.ToName 
	, [recordedBy] = Pers.ToName 
	, [collectionCode] = 'INBOVEG'
 	--> Coordinaten nog gaan halen in Watina_DWH => Conversie naar WGS84 Decimalen
	, i.TaxonFullText as verbatimScientificName
	, [occurrenceStatus] = 'present'
	, [organismQuantity] = coveragecode
	, [vegetationLayer] = CASE LayerCode   WHEN 'K' then 'herbaceous' 
									WHEN 'S' then 'shrub'	
									WHEN 'M' then 'mosses' 
									WHEN 'B' then 'tree' 
									ELSE LayerCode
									END  
	, [organismQuantityType] = 'Braun Blanquet scale'
/**---	, rt.Name as RecordingType
---	, '<!!!>' as Split3
---	, r.VagueDateBegin
---	, r.VagueDateEnd
---	, r.VagueDateType
---	, '<!!!>' as Split_Layer
--, ll.*
--	, '<!!!>' as Split_TaxonOcc
--	, iro.*
---	, '<!!!>' as Split_TaxonIdent
--	, i.*
---	, [samplingProtocol] = 'vegetationPlot- LONDO'  /**?????????????check???????????????**/
---	, r.Area as sampleSizeValue
---	, 'm²' as sampleSizeUnit
--	, r.Length
--	, r.Width
--, (r.Length * r.Width) /10000.0 as CalculatedArea --> Check Values
--	, r.Area 
--	, '<!!!>' as Splitdetermination
--	, i.TaxonFullText
--	, i.TaxonGroup
--	, '<!!!>' as SplitTaxonNameServer **/
	, tax.TaxonGIVID as taxonID	
--	, tax.RECOMMENDED_SCIENTIFIC_NAME as scientificName_old
	, REPLACE ((ISNULL(RECOMMENDED_SCIENTIFIC_NAME,i.TaxonFullText)),'groep','group') as scientificName
	---, CASE WHEN tax.RECOMMENDED_SCIENTIFIC_NAME IS NULL THEN i.TaxonFullText ELSE RECOMMENDED_SCIENTIFIC_NAME collate Latin1_General_CI_AI  end as scientificName3
		  
	, tax.RECOMMENDED_NAME_AUTHORITY as scientificNameAuthorship
	, [kingdom] = 'Plantae'
--	, tax.RECOMMENDED_NAME_RANK as verbatimTaxonRank
--	, tax.RECOMMENDED_NAME_RANK_LONG as taxonRank2
	, [taxonRank] = CASE tax.RECOMMENDED_NAME_RANK WHEN 'Spp' THEN 'species'
	                                               WHEN 'Gen' THEN 'genus'
												   WHEN 'SppGrp' THEN 'speciesAggregate'
												   WHEN 'SppHyb' THEN 'speciesHybrid'
												   WHEN 'SubSpp' THEN 'subspecies'
												   WHEN 'Var' THEN 'variety'
												   ELSE ' '
												   END
---	, tax.RECOMMENDED_TAXON_LANG
---	, '<!!!!>' as slpit
---	, i.*

FROM dbo.ivSurvey s 
	INNER JOIN [dbo].[ivRecording] r ON r.SurveyId = s.Id --> Survey Event Time,PLace, ...
	inner join [dbo].ivRLResources lr ON lr.ResourceGIVID = r.LocationResource
	--LEFT OUTER JOIN dbo.ivResourceSet rs on rs.RecordingID = r.Id
	LEFt OUTER JOIN [dbo].[ivRecTypeD] rt ON rt.ID = r.RecTypeID
	LEFT OUter jOIn dbo.ivRLQualifier rq ON rq.RecordingID = r.Id 
										AND rq.QualifierType = 'SQ' 
										AND ( rq.QualifierResource = 'RS2012080211350655' OR rq.QualifierResource IS NULL )  --> Lijst Met Watina - peilpunten  (SELECT * FROM dbo.ivRLResources WHERE  ResourceGIVID = 'RS2012080211350655')
	LEFT OUTER JOIN dbo.ivRLLayer ll ON ll.RecordingID = r.ID
	LEFT OUTER JOIN dbo.ivRLTaxonOccurrence iro ON iro.LayerID = ll.ID
	LEFT OUTER JOIN dbo.ivRLIdentification i ON i.OccurrenceID = iro.ID AND i.Preferred = 1
	LEFT OUTER JOIN [dbo].[ivRLResources] TaxonRes ON TaxonRes.ResourceGIVID = i.TaxonListResource
	LEFT OUTER JOIN [dbo].[ivRLResources] PhenoRes ON PhenoRes.ResourceGIVID = i.PhenologyResource
	LEFT OUTER JOIN ( SELECT 'Wim Mertens' as FromName, 'Wim Mertens' As ToName UNION ALL
					SELECT 'Bart Vandevoorde', 'Bart Vandevoorde' UNION ALL
					SELECT 'Jan Wouters', 'Jan Wouters'UNION ALL
					SELECT 'Mertens Wim', 'Wim Mertens'UNION ALL
					SELECT 'Els De Bie', 'Els De Bie'UNION ALL
					SELECT 'Kris Rombouts', 'Kris Rombouts'UNION ALL
					SELECT 'jan_wouters', 'Jan Wouters'UNION ALL
					SELECT 'De Bie Els', 'Els De Bie' ) Pers ON pers.FromName = i.Determiner 



	LEFT OUTER JOIN (  SELECT ft.ListType
							, ft.ActionGroup
							, agl.ListName
							, tl.TaxonListGIVID
							, tl.TaxonListItemGIVID
							, t.TaxonGIVID
							, t.TaxonName
							, t.TaxonQuickCode
							, t.TaxonLanguageKey
							, tn.ITEM_NAME as RECOMMENDED_SCIENTIFIC_NAME
							, tn.AUTHORITY as RECOMMENDED_NAME_AUTHORITY
							, trn.[DESCRIPTION] as RECOMMENDED_NAME_RANK_LONG
							, trn.[SHORT_NAME] as RECOMMENDED_NAME_RANK
						FROM syno.Futon_dbo_ftActionGroup ft
							inner join syno.Futon_dbo_ftActionGroupList agl on agl.ActionGroup = ft.ActionGroup
							INNER JOIN syno.Futon_dbo_ftTaxonListItem tl ON tl.TaxonListGIVID = agl.ListGIVID
							inner join syno.Futon_dbo_ftTaxon t ON t.TaxonGIVID = tl.TaxonGIVID	
							LEFT OUTER JOIN syno.NBNData_dbo_TAXON_LIST_ITEM tli ON tli.TAXON_LIST_ITEM_KEY = t.TaxonGIVID
							LEFT OUTER JOIN syno.NBNData_dbo_NAMESERVER ns ON ns.INPUT_TAXON_VERSION_KEY = tli.TAXON_VERSION_KEY
							LEFT OUTER JOIN syno.NBNData_dbo_TAXON_LIST_ITEM tlin ON tlin.TAXON_LIST_ITEM_KEY = ns.RECOMMENDED_TAXON_LIST_ITEM_KEY
							LEFT OUTER JOIN syno.NBNData_dbo_TAXON_RANK trn ON trn.TAXON_RANK_KEY = tlin.TAXON_RANK_KEY
							LEFT OUTER JOIN syno.NBNData_dbo_TAXON_VERSION tvn ON tvn.TAXON_VERSION_KEY = NS.RECOMMENDED_TAXON_VERSION_KEY
							LEFT OUTER JOIN syno.NBNData_dbo_TAXON tn ON tn.TAXON_KEY = tvn.TAXON_KEY
							--LEFT OUTER JOIN NBNData.inbo.Nameserver_12 ns on ns.INBO_TAXON_VERSION_KEY = tli.TAXON_VERSION_KEY
						WHERE ft.ActionGroup IN ('taxon')
						AND agl.ListName IN ('INBO-2011 Sci')
					) tax ON tax.TaxonName = i.TaxonFullText Collate Latin1_General_CI_AI
--	INNER JOIN [syno].[watinadwh_ipt_vwDimPeilpunt] wat ON wat.[PeilpuntCode] = rq.QualifierCode and wat.PeilpuntOpenbaarheidTypeNaam ='Peilmetingen'and wat.IsLaatsteOpenbaarheidsstatus = '-1'

WHERE 1=1
AND s.SurveyGivid = 'IV2015062513233033'
and s.id = '129'
AND occurrenceID > 0
--AND wat.PeilpuntopenbaarheidCode = 'PUBL'
--AND RECOMMENDED_SCIENTIFIC_NAME like '%Valeriana repens%'
--AND  tax.TaxonGIVID = 'INBSYS0000015250'

--ORDER BY scientificName

--AND r.RecordingGivid = 'IV2013111915115150'



/*
SELECT * FROM dbo.ivRLResources WHERE ResourceGIVID = 'RS2012060812481129'




------------------------------------------------------ USE Futon_IPT
SELECT *
FROM futon_ipt.dbo.ftActionGroup
WHERE ActionGroup = 'gebied'


SELECT * 
FROM dbo.ftActionGroupList 
WHERE ActionGroup = 'gebied'
AND ListName = 'MILKLIM-Gebieden'


SELECT * FROM ftgebiedValues  gv WHERE gv.ListGIVID = 'FT2012080209431020'


SELECT *
FROM dbo.ftActionGroup
WHERE ActionGroup = 'cover'


SELECT * 
FROM dbo.ftActionGroupList 
WHERE ActionGroup = 'cover'
AND ListName = 'Londo (1) volledig'


SELECT * FROM ftCoverValues  cv WHERE cv.ListGIVID = 'FT2010120313312937'





*/




















GO


