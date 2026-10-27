USE [D0010_00_Cydonia]
GO

/****** Object:  View [ipt].[INBOVegNicheVlaanderenOccurrenceCore]    Script Date: 13/03/2024 11:46:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [ipt].[INBOVegSchorrenLangendonckOccurrenceCore]
AS
SELECT s.ID
	
	, [eventId] = N'INBO:INBOVEG:' + Right( N'000000000' + CONVERT(nvarchar(20), r.recordingGivid), 19)
	, s.Name as SurveyName
    , [basisOfRecord] = 'HumanObservation' --'MaterialCitation' would be specimen described in scientific literature
	, [occurrenceID] = N'INBO:INBOVEG:OCC:' + Right( N'000000000' + CONVERT(nvarchar(20), [OccurrenceID]), 8) -- occurrenceID = GUID + occurrenceID

	, [identifiedBy] = 'H.J. van Langendonck' 
	, [recordedBy] = 'H.J. van Langendonck' 
	, [collectionCode] = 'INBOVEG'

	, [occurrenceStatus] = 'present'
	, [organismQuantity] = coveragecode
	, [vegetationLayer] = CASE LayerCode   WHEN 'K' then 'herbaceous' 
									WHEN 'S' then 'shrub'	
									WHEN 'M' then 'mosses' 
									WHEN 'B' then 'tree' 
									ELSE LayerCode
									END  
	, [organismQuantityType] = 'Braun Blanquet scale'
	, [fieldNumber] = r.UserReference 

	, [scientificName] = CASE i.TaxonFullText
							WHEN 'Tortula ruralis (Hedw.) Gärtn.,Meyer & Scherb.' THEN 'Tortula'
							WHEN 'Carex flava L. sensu lato' THEN 'Carex flava agg.'
							ELSE i.TaxonFullText
							END
	, [scientificNameAuthorship] = CASE WHEN i.TaxonFullText IN('Tortula ruralis (Hedw.) Gärtn.,Meyer & Scherb.','Carex flava L. sensu lato') THEN NULL
									ELSE tax.RECOMMENDED_NAME_AUTHORITY
									END		  
	, [kingdom] = 'Plantae'
--	, tax.RECOMMENDED_NAME_RANK as verbatimTaxonRank
--	, tax.RECOMMENDED_NAME_RANK_LONG as taxonRank2
	, [taxonRank] = CASE 
						WHEN i.TaxonFullText IN('Agropyron junceum (L.)','Agrostis alba auct. non. L.','Leontodon hirtus') THEN 'species'
						WHEN i.TaxonFullText LIKE '%subvar%' THEN 'variety'
						WHEN i.TaxonFullText LIKE '%sensu lato%' THEN 'speciesAggregate'
						ELSE
							CASE tax.RECOMMENDED_NAME_RANK 
												   WHEN 'Spp' THEN 'species'
	                                               WHEN 'Gen' THEN 'genus'
												   WHEN 'Agg' THEN 'genus' -- to match 'Tortula ruralis Agg.' in GBIF
												   WHEN 'SppGrp' THEN 'speciesAggregate'
												   WHEN 'SppHyb' THEN 'speciesHybrid'
												   WHEN 'SubSpp' THEN 'subspecies'
												   WHEN 'Var' THEN 'variety'
												   ELSE tax.RECOMMENDED_NAME_RANK
												   END
					END
---	, tax.RECOMMENDED_TAXON_LANG
	, [verbatimScientificName] = CASE 
							WHEN i.TaxonFullText = 'Tortula ruralis (Hedw.) Gärtn.,Meyer & Scherb.' THEN 'Tortula ruralis agg.'  --enig taxon in deze dataset met taxonRank 'Agg'
							WHEN i.TaxonFullText LIKE '%subvar%' THEN i.TaxonFullText   -- Salicornia herbacea L. subvar. brachystachya G.F.W. Mey.
							WHEN i.TaxonFullText LIKE '%sensu lato%' THEN i.TaxonFullText  -- Carex flava L. sensu lato
							ELSE ''
							END
	, [verbatimIdentification] = CASE 							
							WHEN i.TaxonFullText = 'Tortula ruralis (Hedw.) Gärtn.,Meyer & Scherb.' THEN 'Tortula ruralis agg.'  --enig taxon in deze dataset met taxonRank 'Agg'
							WHEN i.TaxonFullText LIKE '%subvar%' THEN i.TaxonFullText   -- Salicornia herbacea L. subvar. brachystachya G.F.W. Mey.
							WHEN i.TaxonFullText LIKE '%sensu lato%' THEN i.TaxonFullText  -- Carex flava L. sensu lato
							ELSE ''
							END
	, [verbatimTaxonRank] = CASE  							
							WHEN tax.RECOMMENDED_NAME_RANK = 'Agg' THEN 'speciesAggregate'
							WHEN tax.RECOMMENDED_NAME_RANK = 'SppGrp' THEN 'speciesAggregate'
							WHEN i.TaxonFullText LIKE '%subvar%' THEN '(sub)variety'
							WHEN i.TaxonFullText LIKE '%sensu lato%' THEN 'speciesAggregate'
							ELSE ''
							END
	, [identificationQualifier] = CASE 
							WHEN tax.RECOMMENDED_NAME_RANK = 'Agg' THEN 'speciesAggregate'
							WHEN tax.RECOMMENDED_NAME_RANK = 'SppGrp' THEN 'speciesAggregate'
							WHEN i.TaxonFullText LIKE '%subvar%' THEN '(sub)variety'
							WHEN i.TaxonFullText LIKE '%sensu lato%' THEN 'speciesAggregate'							
							ELSE ''
							END
	, [datasetID] = N'https://doi.org/10.15468/b67why'
	, [datasetName] = N'INBOVEG - Vegetation surveys in the Zwin tidal mudflat and salt marsh in 1933, Flanders, Belgium'

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

WHERE 1=1
AND s.SurveyGivid = 'IV2015062513233033'

GO


