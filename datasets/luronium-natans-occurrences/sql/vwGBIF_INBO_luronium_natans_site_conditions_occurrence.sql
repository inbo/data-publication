USE [D0017_00_NBNData]
GO

/****** Object:  View [ipt].[vwGBIF_INBO_Luronium_natans_standplaatsonderzoek_occurrence]    Script Date: 7/12/2020 9:54:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








/**********************************
2018-05-17  Maken generische querie voor TrIAS
2018-12-10  Ecologische waterlopen vegetatie starts DiB
2019-01-20  Finaliseren Query
2020-10-12  Luronium natans
2020-10-22  insert list of exotic waterplants
*********************************/

ALTER View [ipt].[vwGBIF_INBO_Luronium_natans_standplaatsonderzoek_occurrence]
AS

SELECT 
      --- EVENT ---

	  [eventID]= 'INBO:NBN:' + SA.[SAMPLE_KEY]
	, [parentEventID] ='INBO:NBN:' + SA.[survey_event_key]
		
	
	--- RECORD ---	
	
	, [type] = N'Event'
	, [basisOfRecord] = N'HumanObservation'

		--- Occurrence---

	, [occurrenceID] = N'INBO:NBN:' + TAO.[TAXON_OCCURRENCE_KEY]
	, [recordedBy] = NAME_KEY
	, [organismQuantity] = meas.DATA
					 
	, [organismQuantityType] = CASE DataLongName
								WHEN 'p/a' THEN 'check'
								WHEN 'BB' THEN 'CHECK'
								WHEN 'Tansley' THEN 'Tansley'
								WHEN 'Personal code' THEN 'Personal code'
								WHEN 'Klasse LurNat2' THEN 'CHECK'
								WHEN 'Range' THEN 'check'
								WHEN 'None' THEN 'check'
								WHEN '%' THEN 'check'
								WHEN 'Klasse LurNat' THEN 'CHECK'
								ELSE DataLongName
								END
	
	, DataShortName
	, [occurrenceStatus] = N'present'
	, [taxonRank] = CASE
					 WHEN NS.RECOMMENDED_NAME_RANK_LONG = 'Species' THEN 'species'
					 WHEN NS.RECOMMENDED_NAME_RANK_LONG = 'Species hybrid' THEN 'species'
					 WHEN NS.RECOMMENDED_NAME_RANK_LONG = 'Genus' THEN 'genus'
					ELSE NS.RECOMMENDED_NAME_RANK_LONG
					END
					
	

		--- TAXON ---

	, [scientificName] = RECOMMENDED_SCIENTIFIC_NAME
	, [scientificNameAuthorship] = RECOMMENDED_NAME_AUTHORITY
	, [kingdom] = N'Plantae'

	

	
	
	--- LOCATION ---
	
FROM dbo.Survey S
	
	INNER JOIN [dbo].[Survey_event] SE ON SE.[Survey_Key] = S.[Survey_Key]
	LEFT OUTER JOIN [dbo].[Location] L ON L.[Location_Key] = SE.[Location_key]
	LEFT OUTER JOIN [dbo].[Location_Name] LN ON LN.[Location_Key] = L.[Location_Key] AND LN.[PREFERRED] = 1
	INNER JOIN [dbo].[SAMPLE] SA ON SA.[SURVEY_EVENT_KEY] = SE.[SURVEY_EVENT_KEY]
	LEFT OUTER JOIN [dbo].[SAMPLE_TYPE] ST ON  ST.[SAMPLE_TYPE_KEY] = SA.[SAMPLE_TYPE_KEY]
	INNER JOIN [dbo].[TAXON_OCCURRENCE] TAO ON TAO.[SAMPLE_KEY] = SA.[SAMPLE_KEY]

	LEFT JOIN [dbo].[RECORD_TYPE] RT ON RT.[RECORD_TYPE_KEY] = TAO.[RECORD_TYPE_KEY]
	LEFT JOIN [dbo].[SPECIMEN] SP ON SP.[TAXON_OCCURRENCE_KEY] = TAO.[TAXON_OCCURRENCE_KEY]
	
	LEFT JOIN [dbo].[TAXON_DETERMINATION] TD ON TD.[TAXON_OCCURRENCE_KEY] = TAO.[TAXON_OCCURRENCE_KEY]
	LEFT JOIN [dbo].[INDIVIDUAL] I ON I.[NAME_KEY] = TD.[DETERMINER]
	LEFT JOIN [dbo].[DETERMINATION_TYPE] DT ON DT.[DETERMINATION_TYPE_KEY] = TD.[DETERMINATION_TYPE_KEY]

	
	--Taxon
	LEFT JOIN [dbo].[TAXON_LIST_ITEM] TLI ON TLI.[TAXON_LIST_ITEM_KEY] = TD.[TAXON_LIST_ITEM_KEY]
	LEFT JOIN [dbo].[TAXON_VERSION] TV ON TV.[TAXON_VERSION_KEY] = TLI.[TAXON_VERSION_KEY]
	LEFT JOIN [dbo].[TAXON] T ON T.[TAXON_KEY] = TV.[TAXON_KEY]
	
	INNER JOIN [dbo].[TAXON_RANK] TR ON TR.TAXON_RANK_KEY = TLI.TAXON_RANK_KEY
	--Lijst
	--LEFT JOIN [dbo].[TAXON_LIST_VERSION] TLV ON TLV.TAXON_LIST_VERSION_KEY = TLI.TAXON_LIST_VERSION_KEY
	--LEFT JOIN [dbo].[TAXON_LIST] TL ON TL.TAXON_LIST_KEY =  TLV.TAXON_LIST_KEY

	--Normalizeren Namen 
	--LEFT JOIN [dbo].[NAMESERVER] NS ON NS.INPUT_TAXON_VERSION_KEY = TD.TAXON_LIST_ITEM_KEY
	INNER JOIN [inbo].[NameServer_12] NS ON NS.[INBO_TAXON_VERSION_KEY] = TLI.[TAXON_VERSION_KEY]

	--measurement
		LEFT OUTER JOIN ( SELECT taoMeas.TAXON_OCCURRENCE_KEY 
								, taoMeas.DATA
								, MUMeas.SHORT_NAME as DataShortName
								, MUMeas.LONG_NAME as DataLongName
								, MUMeas.[DESCRIPTION] as DataDescription
 								, MQMeas.SHORT_NAME as QualifierShortName
								, MQMeas.LONG_NAME as QualifierLongName
								, MQMeas.[DESCRIPTION] as QualifierDescription
							FROM [dbo].[TAXON_OCCURRENCE_DATA] taoMeas 
								LEFT JOIN dbo.MEASUREMENT_UNIT MUMeas ON  MUMeas.MEASUREMENT_UNIT_KEY = taoMeas.MEASUREMENT_UNIT_KEY
								LEFT JOIN dbo.MEASUREMENT_QUALIFIER MQMeas ON  MQMeas.MEASUREMENT_QUALIFIER_KEY = taoMeas.MEASUREMENT_QUALIFIER_KEY
								LEFT JOIN dbo.MEASUREMENT_TYPE MTMeas ON  (MTMeas.MEASUREMENT_TYPE_KEY = MQMeas.MEASUREMENT_TYPE_KEY )
							WHERE 1=1
							--AND taoMeas.TAXON_OCCURRENCE_KEY = 'BFN0017900009PCB'
							--AND  MTMeas.SHORT_NAME = 'Abundance'
						) Meas on meas.TAXON_OCCURRENCE_KEY = tao.TAXON_OCCURRENCE_KEY 

	--measurement

WHERE
	S.[ITEM_NAME] IN ('Luronium natans standplaatsonderzoek') 
/**	AND ISNUMERIC(LEFT (SA.SPATIAL_REF, CHARINDEX(',', SA.SPATIAL_REF, 1)-1)) = 1
	AND CHARINDEX (',', SA.SPATIAL_REF, 1) > 5
	AND ISNUMERIC(SUBSTRING (SA.SPATIAL_REF, CHARINDEX(',', SA.SPATIAL_REF, 1 )+1, LEN(SA.SPATIAL_REF))) = 1 **/
--	and ST.SHORT_NAME <> 'Weather'
    AND DataShortName <> 'Personal code'
	AND meas.DATA > '0'	
	AND RECOMMENDED_SCIENTIFIC_NAME IN ('Acorus calamus','Alternanthera philoxeroides','Amaranthus blitum','Amaranthus hybridus'
										,'Ambrosia artemisiifolia','Aponogeton distachyos','Azolla filiculoides'
										,'bamboegroep: Bambusoideae','Bidens sp.','Bolboschoenus glaucus','Bolboschoenus yagara'
										,'Cabomba caroliniana','Cabomba aquatica','Cabomba furcata','Cabomba sp.'
										,'Crassula helmsii','Cyperus eragrostis','Cyperus alterniflorus','Cyperus congestus'
										,'Egeria densa','Egeria najas','Eichhornia crassipes','Eichhornia azurea'
										,'Eleocharis austriaca','Eleocharis engelmannii','Eleocharis obtusa','Elodea canadensis'
										,'Elodea nuttallii','Elodea callitrichoides','Elodea sp','Fallopia baldschuanica'
										,'Fallopia japonica','Fallopia sachalinensis','Fallopia x bohemica'
										,'Glyceria canadensis','Glyceria striata','Gymnocoronis spilanthoides'
										,'Heracleum mantegazzianum','Heracleum persicum','Heracleium sosnowskyi'
										,'Heracleum sphondylium','Hydrilla verticillata','Hydrocotyle ranunculoides'
										,'Hydrocotyle verticillata','Hydrocotyle leucocephala'
										,'Hydrocotyle novae-zelandiae var. montana','Hydrocotyle sibthorpioides'
										,'Hygrophila polysperma','Hygroryza aristata','Impatiens balfourii'
										,'Impatiens capensis','Impatiens glandulifera','Impatiens parviflora'
										,'Juncus canadensis','Juncus tenuis','Lagarosiphon major','Landoltia punctata'
										,'Lemna minuta','Lemna turionifera','Limnobium laevigatum','Limnobium spongia'
										,'Lindernia dubia','Ludwigia grandiflora','Ludwigia peploides','Lysichiton americanus'
										,'Lysichiton camtschatcensis','Mimulus guttatus','Miscanthus X gigantea'
										,'Miscanthus sinensis','Miscanthius sacchariflorus','Miscanthus sp.'
										,'Myriophyllum aquaticum','Myriophyllum crispatum','Myriophyllum heterophyllum'
										,'Myriophyllum robustum','Myriophyllum simulans','Myriophyllum sp. trade name brasiliensis'
										,'Myriophyllum tetrandrum','Myriophyllum tuberculatum','Phyllanthus fluitans','Pistia stratiotes'
										,'Pontederia cordata','Sagittaria latifolia','Salvinia auriculata-complex','Salvinia molesta','Salvinia natans'
										,'Saururus cernuus','Schoenoplectiella bucharica','Spartina anglica','Thalia dealbata','Typha laxmannii'
										,'Typha minima','Typha x provincialis','Vallisneria americana','Vallisneria sp.','Vallisneria spiralis'
										,'Wolffia columbiana','Zizania latifolia','Zizania sp.','Azolla caroliniana','Reynoutria japonica'
										,' Polygonum cuspidatum','Spirodela punctata','Salvinia molesta')


 -- AND TAO.[TAXON_OCCURRENCE_KEY] in ('BFN001790000BPTR','BFN001790000BPTW','BFN001790000BQK0')







GO


