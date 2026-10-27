USE [D0010_00_Cydonia]
GO

/****** Object:  View [ipt].[INBOSchorrenLangendonckEventCore]    27/10/2026 11:24:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/**ALTER VIEW [ipt].[INBOVegSchorrenLangendonckEventCore]
AS**/


SELECT 
/**record level**/
      s.ID 
	, s.Name as SurveyName
	, [type] = 'Event'
	, [language] = 'en'
	, [License] = N'http://creativecommons.org/publicdomain/zero/1.0/'
	, [rightsHolder] = N'INBO'
    , [accessRights] = N'http://www.inbo.be/en/norms-for-data-use'
	, [datasetID] = N'https://doi.org/10.15468/b67why'
	, [institutionCode] = CONVERT(Nvarchar(20),'INBO') 
	, [datasetName] = N'INBOVEG - Vegetation surveys in the Zwin tidal mudflat and salt marsh in 1933, Flanders, Belgium'
	, [ownerInstitutionCode] = CONVERT(Nvarchar(20),'INBO')
	, [collectionCode] = 'INBOVEG'
	, [bibliographicCitation] = 'Bulletin de la Société Royale de Botanique de Belgique, t. LXV, fasc. 2, 1933'

/** EVENT**/
	, [eventId] = N'INBO:INBOVEG:' + Right( N'000000000' + CONVERT(nvarchar(20), r.recordingGivid), 19)
--	, CASE WHEN rq.QualifierCode = '-9' THEN '' ELSE rq.QualifierCode END as locationID 
	, [municipality] = r.LocationCode 
	, [verbatimLocality] = rq.QualifierCode + ', ' + r.UserReference
	, [fieldNumber] = r.UserReference
	/**	, r.ElementCode
	, r.Length
	, r.Width 
	, (r.Length * r.Width) /10000.0 as CalculatedArea --> Check Values **/
	, Convert(nvarchar(100), r.Area) as sampleSizeValue
	, 'm²' as sampleSizeUnit

	, rt.Name as RecordingType
	, [samplingProtocol] = 'vegetation plot Braun-Blanquet coverage' 
--	, [habitat] = 'Le Salicornietum herbaceae'

/**	, r.VagueDateBegin
	, r.VagueDateEnd
	, r.VagueDateType  **/
	, [verbatimEventDate] = [inbo].[LCReturnVagueDateGBIF]( r.VagueDateBegin, r.VagueDateEnd , 'dd', 0)
	, [EventDate] = [inbo].[LCReturnVagueDateGBIF]( r.VagueDateBegin, r.VagueDateEnd , r.VagueDateType,0) 
	
/** LOCATION **/
	
	, [continent] = 'Europe'
	, [countryCode] = 'BE'

	, [decimalLatitude] = CASE latitude WHEN 51.3322   
							THEN 51.3600
							ELSE latitude
							END
	, [decimalLongitude] = CASE longitude WHEN 3.3091
							THEN 3.3625
							ELSE longitude
							END
	, [geodeticDatum] = 'WGS84'
	, [coordinateUncertaintyInMeters] = CASE latitude WHEN 51.3322   
							THEN '1000'
							ELSE '30'
							END
--	, [georeferenceRemarks] = 'initial coordinates based on the locationCode of municipalities in Belgium'
    , [dataGeneralizations] = N'Coordinates generalized to the estimated center of the survey area'
	
FROM dbo.ivSurvey s 
	INNER JOIN [dbo].[ivRecording] r ON r.SurveyId = s.Id --> Survey Event Time,PLace, ...
	inner join [dbo].ivRLResources lr ON lr.ResourceGIVID = r.LocationResource
	LEFT OUTER JOIN dbo.ivResourceSet rs on rs.RecordingID = r.Id
	LEFt OUTER JOIN [dbo].[ivRecTypeD] rt ON rt.ID = r.RecTypeID
	LEFT OUter jOIn dbo.ivRLQualifier rq ON rq.RecordingID = r.Id 
										AND rq.QualifierType = 'SQ' 
	--									AND (rq.QualifierResource = 'RS2012080211350655' OR rq.QualifierResource  IS NULL ) --> Lijst Met Watina - peilpunten  (SELECT * FROM dbo.ivRLResources WHERE  ResourceGIVID = 'RS2012080211350655')
	--INNER JOIN [syno].[watinadwh_ipt_vwDimPeilpunt] wat ON wat.[PeilpuntCode] = rq.QualifierCode and wat.PeilpuntOpenbaarheidTypeNaam ='Peilmetingen'and wat.IsLaatsteOpenbaarheidsstatus = '-1'

WHERE 1=1

AND s.SurveyGivid = 'IV2015062513233033'

--ORDER BY rq.qualifierCode ASC
--ORDER BY verbatimLongitude
--ORDER BY locationID

GO
