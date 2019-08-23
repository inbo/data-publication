USE [S0008_00_Meetnetten]
GO

/****** Object:  View [iptdev].[vwGBIF_INBO_meetnetten_dragonflies population count per location_occurrence]    Script Date: 23/08/2019 14:01:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










/* Generieke query inclusief soorten */


CREATE VIEW [iptdev].[vwGBIF_INBO_meetnetten_dragonflies population count per location_occurrence]
AS

SELECT --fa.*   --unieke kolomnamen
	

	 [occurrenceID] = N'INBO:MEETNETTEN:OCC:' + Right( N'0000' + CONVERT(nvarchar(20) ,FieldworkObservationID),7)

	---RECORD ---

/**      [type] = N'Event'
   	, [language] = N'en'
	, [license] = N'http://creativecommons.org/publicdomain/zero/1.0/'
	, [rightsHolder] = N'INBO'
	, [accessRights] = N'https://www.inbo.be/en/norms-data-use'
	, [datasetID] = N'meetnettendatasetDOI'
	, [datasetName] = N'Meetnetten - Generiek Vuursalamander, Belgium'
	, [institutionCode] = N'INBO'

	**/
	
	 ---EVENT---	
	
	,  [eventID ] = N'INBO:MEETNET:EVENT:' + Right( N'000000000' + CONVERT(nvarchar(20) , fA.FieldworkSampleID),6)  
	, [basisOfRecord] = N'HumanObservation'
	, [samplingProtocol] = Protocolname
	, [lifeStage] = SpeciesLifestageName
	, [protocol] = ProtocolSubjectDescription
	
--	, [samplingEffort] =
						
--	,[eventDate] = SampleDate
--	,[dynamicProperties] = 
	

	--, CONVERT(decimal(10,5), dL.LocationGeom.STCentroid().STY) as decimalLatitude
	--, CONVERT(decimal(10,5), dL.LocationGeom.STCentroid().STX) as decimalLongitude
/**
	---LOCATION
	, [locationID] = N'INBO:MEETNET:LOCATION:' + Right( N'000000000' + CONVERT(nvarchar(20) ,dL.LocationID),10) 
	, [continent] = N'Europe'
--	, [waterbody] = dL.Location
	, [countryCode] = N'BE'
	, [locality] = locationName
	, [georeferenceRemarks] = N'coordinates are centroid of location' 
	
	, CONVERT(decimal(10,5), dL.LocationGeom.MakeValid().STCentroid().STY) as decimalLatitude
	, CONVERT(decimal(10,5), dL.LocationGeom.MakeValid().STCentroid().STX) as decimalLongitude
	, [geodeticDatum] = N'WGS84'

	**/
		
	---- OCCURRENCE ---
		
	, [recordedBy] = 'to complete'
	, [individualCount] = Aantal

	
	
	
	----Taxon

	, [scientificName] = SpeciesScientificName
	, [vernacularName] = SpeciesName

	, [kingdom] = N'Animalia'
	, [phylum] = N'Chordata'
	, [class] = N''
	, [nomenclaturalCode] = N'ICZN'
	
	, fa.ProjectKey

FROM dbo.FactAantal fA
	INNER JOIN dbo.dimProject dP ON dP.ProjectKey = fA.ProjectKey
	INNER JOIN dbo.DimLocation dL ON dL.locationID = fA.LocationID
	INNER JOIN dbo.DimProtocol dProt ON dProt.ProtocolID = fA.ProtocolID
	INNER JOIN dbo.DimSpeciesActivity dSA ON dSA.SpeciesActivityID = fA.SpeciesActivityID
	INNER JOIN dbo.DimSpeciesLifestage dSL ON dSL.SpeciesLifestageID = fA.SpeciesLifestageID
	INNER JOIN dbo.DimSpecies dSP ON dsp.SpeciesKey = fa.SpeciesKey

	--INNER JOIN FactCovariabele FCo ON FCo.FieldworkSampleID = fA.FieldworkSampleID
WHERE 1=1
---AND ProjectName = 'Vuursalamander'
--AND fa.ProjectKey = '16'
AND fa.ProtocolID =  '3'








GO

