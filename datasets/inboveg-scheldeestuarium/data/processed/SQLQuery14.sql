USE [D0010_00_Cydonia]
GO

/****** Object:  View [ipt].[dev_INBOVegMILKLIM_W&Z_Bermen_AfleidingskanaalLeie_EventCore]    Script Date: 22/05/2024 14:53:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






/**CREATE VIEW [ipt].[dev_INBOVegScheldeEstuariumEventCore]
AS**/


SELECT 
/**record level**/
      s.ID 
	, s.Name as SurveyName
	--, '<!!!>' as Split1
	---, lr.*
	---, ActionGroup 
	---, ListName 
	---, '<!!!>' as Split2
	---, ResourceGIVID
---	, SurveyGivid as parentEventID  (removed because not resolvable)
    , r.recordingGivid
	, [eventId] = N'INBO:INBOVEG:' + Right( N'000000000' + CONVERT(nvarchar(20), r.recordingGivid), 19)
--	, CASE WHEN rq.QualifierCode = '-9' THEN '' ELSE rq.QualifierCode END as locationID 
	, r.LocationCode as verbatimLocality
	, r.UserReference
/**	, r.ElementCode
	, r.Length
	, r.Width 
	, (r.Length * r.Width) /10000.0 as CalculatedArea --> Check Values **/
	, Convert(nvarchar(100), r.Area) as sampleSizeValue
	, 'm²' as sampleSizeUnit
 	--> Coordinaten nog gaan halen in Watina_DWH => Conversie naar WGS84 Decimalen
	, rt.Name as RecordingType
	, [samplingProtocol] = 'vegetation plot Braun/Blanket coverage'  /**?????????????check???????????????**/
--	, '<!!!>' as Split3
/**	, r.VagueDateBegin
	, r.VagueDateEnd
	, r.VagueDateType  **/
	, [verbatimEventDate] = [inbo].[LCReturnVagueDateGBIF]( r.VagueDateBegin, r.VagueDateEnd , 'dd', 0)
	, [EventDate] = [inbo].[LCReturnVagueDateGBIF]( r.VagueDateBegin, r.VagueDateEnd , r.VagueDateType,0) 
---	[inbo].[LCReturnVagueDateGBIF] ( '2013-07-18', '2013-07-18', 'D', 0 )
	
	, [type] = 'Event'
	, [language] = 'en'
	, [License] = N'http://creativecommons.org/publicdomain/zero/1.0/'
	, [rightsHolder] = N'INBO'
    , [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
	, [datasetID] = CONVERT(Nvarchar(100),'****')
	, [institutionCode] = CONVERT(Nvarchar(20),'INBO') 
	, [datasetName] = N'InboVeg - Schorren_VanLangendonck1933 Flanders, Belgium'
	--, [ownerInstitutionCode] = CONVERT(Nvarchar(20),'INBO')
	, [collectionCode] = 'INBOVEG'
	, [bibliographicCitation] = 'Bulletin de la Société Royale de Botanique de Belgique, t. LXV, fasc2, 1933'
/** IDENTIFICATION**/

	, [recordedBy] = 'H.J. Van Langendonck'
	, [identifiedBy] = 'H.J. Van Langendonck'
	
/** LOCATION **/
	
	, [continent] = 'Europe'
	, [countryCode] = 'BE'
	, CASE ListName WHEN 'MILKLIM-gebieden' THEN 'MILKLIM-areas' end as locationAccordingTo
	, [decimalLatitude] = latitude
	, [decimalLongitude] = longitude
	--	, [verbatimSRS] = 'Belgium Datum 1972'

/**	, [wat].[PeilpuntXCoordinaat] as verbatimLongitude
	, [wat].[PeilpuntYCoordinaat] as verbatimLatitude
	, wat.decimalLatitude
	, wat.decimalLongitude
	, CASE [wat].[peilpuntXYDeelgemeenteNaam] WHEN 'XY Onbekend' THEN ' ' 
										      ELSE [wat].[peilpuntXYDeelgemeenteNaam]
											  END as municipality
	, CASE [wat].[peilPuntXYProvincieNaam] WHEN 'Antwerpen' THEN 'Antwerp'
										   WHEN 'Limburg' THEN 'Limburg' 
										   WHEN 'Oost-Vlaanderen' THEN 'East Flanders' 
										   WHEN 'West-Vlaanderen' THEN 'West Flanders' 
										   WHEN 'Vlaams-Brabant' THEN 'Flemish Brabant' 
										   WHEN 'XY Onbekend' THEN ' ' 
										     	ELSE ' '	
										   END	as stateProvince  --stateProvince?
	
	, [wat].[peilPuntXYGewestNaam] as stateProvince
	, [verbatimCoordinateSystem] = 'Belgian Lambert 72' **/
	, [geodeticDatum] = 'WGS84'
	, [coordinateUncertaintyInMeters] = '30'
	, [georeferenceRemarks] = 'coördinates based on the locationCode of municipalities in Belgium'
	--, [wat].peilpuntcode
	, rq.QualifierCode
	--, lr.*
	
FROM dbo.ivSurvey s 
	INNER JOIN [dbo].[ivRecording] r ON r.SurveyId = s.Id --> Survey Event Time,PLace, ...
	inner join [dbo].ivRLResources lr ON lr.ResourceGIVID = r.LocationResource
	LEFT OUTER JOIN dbo.ivResourceSet rs on rs.RecordingID = r.Id
	LEFt OUTER JOIN [dbo].[ivRecTypeD] rt ON rt.ID = r.RecTypeID
	LEFT OUter jOIn dbo.ivRLQualifier rq ON rq.RecordingID = r.Id 
	--									AND rq.QualifierType = 'SQ' 
	--									AND (rq.QualifierResource = 'RS2012080211350655' OR rq.QualifierResource  IS NULL ) --> Lijst Met Watina - peilpunten  (SELECT * FROM dbo.ivRLResources WHERE  ResourceGIVID = 'RS2012080211350655')
	--INNER JOIN [syno].[watinadwh_ipt_vwDimPeilpunt] wat ON wat.[PeilpuntCode] = rq.QualifierCode and wat.PeilpuntOpenbaarheidTypeNaam ='Peilmetingen'and wat.IsLaatsteOpenbaarheidsstatus = '-1'

WHERE 1=1

AND s.SurveyGivid = 'IV2013070514100478'
--and s.id = '129'
--AND RecordingGivid = 'IV2013090211233164'
--AND wat.PeilpuntOpenbaarheidCode = 'PUBL'
--AND s.ExternalReference = 'INBO.R.2007.3 Callebaut J, De Bie E, Huybrechts W en De Becker P (2007) NICHE-Vlaanderen, SVW, 1-7.'

--AND wat.PeilpuntID IS NULL
--and IsLaatsteOpenbaarheidsstatus = '-1'
--AND PeilpuntOpenbaarheidCode = 'publ'
--and rq.QualifierCode = 'ABEP045X'
--order by 4

--ORDER BY rq.qualifierCode ASC
--ORDER BY verbatimLongitude
--ORDER BY locationID




GO


