/*
Tables and fields we want to include:
(datecreated, datelastchange and version are not included)

allowedusers					n
calculatedmeasurement			y
- id							n
- latitude						y
- longitude						y
- km
- km2
condition						
controlled vocabulary			y
- id
- type							n
- code
- name
- esascode
- esasdescription
controlledvocabulary_warning	n
databasechangelog				n
databasechangeloglock			n
exportdownload					n
exportposkey					n?
exportstatus					n
measurement						
measurementsummary				
measurementuploads				
measurementvalidationerror		
migrationstatus					n
observation
- id 							y
- wp							n
- taxon							y
- age							y?
- plumage						y?
- distance				
- direction				
- association			
- remarks				
- turbineheight			
- transect				
- datelastchange				y
- surveyevent					a
- starttime				
- endtime				
- group_field			
- number				
- calculatedmeasurement			y
- behaviour						y
- flagged						?
positionalkey					
surveyevent						
taxon							y
- id							n
- inbocode
- scientificname				y
- dutchvernacularname			n
- englishvernacularname			y
- esascode
- euringcode					y
- taxonrank						
- taxonversionkey
- remarks
taxon_warning					n
userconnection					n
users							n
*/
	
SELECT
-- record
    o.id AS occurrenceID,
    'Event' AS type,
    to_char(o.datelastchange at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS"Z"') AS modified, -- TODO: can we assume UTC?
    'en' AS language,    
	'http://creativecommons.org/publicdomain/zero/1.0/' AS license,
	'INBO' AS rightsholder,
  	'http://www.inbo.be/en/norms-for-data-use' AS accessRights,
  	'DOI to be assigned' AS datasetID, -- TODO: update
  	'INBO' AS institutionCode,
	'SAS - Seabirds at sea monitoring in the Belgian part of the North Sea' AS datasetName, -- To verify
	'INBO' AS ownerInstitutionCode,
	'HumanObservation' AS basisOfRecord,
	'see metadata' AS informationWitheld, -- TODO: verify

-- occurrence
	-- occurrenceRemarks,
	-- recordedBy,
	-- individualCount,
	-- organismQuantity,
	-- organismQuantityType,
	-- sex,
	-- lifeStage,
	-- reproductiveCondtion,
	behaviour.name AS behavior, -- TODO: verify
    age.name AS age,
    plumage.name AS plumage,

-- event
	-- eventID,
	-- samplingProtocol,
	-- sampleSizeValue,
	-- sampleSizeUnit,
	-- samplingEffort,
	-- eventDate,
	-- eventTime,
	-- eventRemarks

-- location
	-- locationID,
	-- continent,
	-- waterbody,
	-- countryCode,
	-- minimumElevationInMeters
	-- minimumDistanceAboveSurfaceInMeters,
    to_char(loc.latitude, '99.99999') AS decimalLatitude,
    to_char(loc.longitude, '999.99999') AS decimalLongitude,
	'WGS84' AS geodeticDatum, -- TODO: verify
	-- coordinateUncertaintyInMeters
	-- georeferencedDate,
	-- georeferenceProtocol,
	-- georeferenceSources,
	-- georeferenceVerificationStatus,
	
-- identification
	-- identifiedBy,
	-- identificationVerificationStatus,

-- taxon
    CASE
    	WHEN taxon.euringcode != '' THEN 'euring:' || taxon.euringcode -- Works for '' and NULL. Resulting code is cf. watervogels
    	ELSE ''
    END AS taxonID,
    taxon.scientificname AS scientificName,
    'Animalia' AS kingdom,
    'Chordata' AS phylum, -- TODO: verify
    -- order, -- SAS contains birds and cetaceans, so no single order
    taxon.taxonrank AS taxonRank,
    -- scientificNameAuthorship, -- This information is not available in SAS
    taxon.dutchvernacularname AS vernacularName, -- TODO: decide EN or NL
	'ICZN' AS nomenclaturalCode

FROM observation AS o
    LEFT JOIN taxon ON o.taxon = taxon.id
    LEFT JOIN controlledvocabulary AS age ON o.age = age.id AND age.type = 'age'
    LEFT JOIN controlledvocabulary AS plumage ON o.plumage = plumage.id AND plumage.type = 'plumage'
    LEFT JOIN controlledvocabulary AS behaviour ON o.behaviour = behaviour.id AND behaviour.type = 'behaviour'
    LEFT JOIN calculatedmeasurement AS loc ON o.calculatedmeasurement = loc.id

WHERE
	taxon.inbocode != 0 -- exclude observations without birds TODO: f3310e23-e014-4897-80c4-07fd293525db
	AND taxon.inbocode != 9999 -- exclude boat observations TODO: d818f147-2571-4770-aed8-f5338e303fb5
LIMIT 10
