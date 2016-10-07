/*
Tables and fields we want to include:
(datecreated, datelastchange and version are not included)

condition						
allowedusers                    n
calculatedmeasurement           y
- id                            n
- latitude                      y
- longitude                     y
- km                            
- km2                           
controlled vocabulary           y
- id
- type                          n                        
- code                          
- name
- esascode                      
- esasdescription
controlledvocabulary_warning    n
databasechangelog               n
databasechangeloglock           n
exportdownload                  n
exportposkey                    n?
exportstatus                    n
measurement                     
measurementsummary              n
measurementuploads              n
measurementvalidationerror      n
migrationstatus                 n
observation                     y
- id                            y
- wp                            n
- taxon                         y
- age                           y?
- plumage                       y?
- distance                      
- direction                     
- association                   
- remarks                       
- turbineheight                 
- transect                      
- datelastchange                y
- surveyevent                   y
- starttime                     y
- endtime                       y
- group_field                   
- number                        
- calculatedmeasurement         y
- behaviour                     y
- flagged                       ?
positionalkey                    
surveyevent                     y
- survey                        
- tripid                        
- dateofsurvey                  y
- ship                          
- observer1                     y
- observer2                     y
taxon                           y
- id                            n
- inbocode                      n
- scientificname                y
- dutchvernacularname           n
- englishvernacularname         y
- esascode                      
- euringcode                    y
- taxonrank                     y   
- taxonversionkey               
- remarks                       
taxon_warning                   n
userconnection                  n
users                           n
*/

SELECT
-- record
    obs.id AS occurrenceID,
    'Event' AS type,
    to_char(obs.datelastchange at time zone 'UTC','YYYY-MM-DD"T"HH24:MI:SS"Z"') AS modified, -- TODO: can we assume UTC?
    'en' AS language,    
    'http://creativecommons.org/publicdomain/zero/1.0/' AS license,
    'INBO' AS rightsholder,
      'http://www.inbo.be/en/norms-for-data-use' AS accessRights,
      'DOI to be assigned' AS datasetID, -- TODO: update
      'INBO' AS institutionCode,
    'SAS - Seabirds at sea monitoring in the Belgian part of the North Sea' AS datasetName, -- TODO: verify
    'INBO' AS ownerInstitutionCode,
    'HumanObservation' AS basisOfRecord,
    'see metadata' AS informationWitheld, -- TODO: verify

-- occurrence
    -- occurrenceRemarks,
    CASE
        WHEN observer2.id IS NOT NULL THEN observer1.name || ', ' || observer2.name
        ELSE observer1.name
    END AS recordedBy,
    obs.number AS individualCount,
    -- organismQuantity,
    -- organismQuantityType,
    -- sex,
    -- lifeStage,
    -- reproductiveCondition,
    behaviour.name AS behavior, -- TODO: verify
    age.name AS age, -- TODO: not DwC
    plumage.name AS plumage, -- TODO: not DwC

-- event
    -- eventID,
    -- samplingProtocol,
    -- sampleSizeValue,
    -- sampleSizeUnit,
    -- samplingEffort,
    
    /* 
    survey.dateofsurvey, obs.starttime, obs.endtime are all recorded in DB without timezone, but:
    Times are recorded by users in UTC/GMT and surveys are limited to days.
    There is no risk of spilling over to next/previous day as max difference is GMT+2 and no surveys are around midnight.
    We can therefore assume all dates/times to be in UTC/GMT.
    
    The app will set obs.endtime = obs.starttime if no obs.endtime is recorded (= for most historical surveyevents)
    In DarwinCore, we will only use a time range (with /) if obs.endtime is different from obs.startdate
    */
    CASE
        WHEN obs.endtime != obs.starttime AND obs.endtime IS NOT NULL THEN -- A time range
            to_char(survey.dateofsurvey at time zone 'UTC', 'YYYY-MM-DD"T"') || to_char(obs.starttime at time zone 'UTC', 'HH24:MI"Z"') || '/' || 
            to_char(survey.dateofsurvey at time zone 'UTC', 'YYYY-MM-DD"T"') || to_char(obs.endtime at time zone 'UTC', 'HH24:MI"Z"')
        ELSE to_char(survey.dateofsurvey at time zone 'UTC', 'YYYY-MM-DD"T"') || to_char(obs.starttime at time zone 'UTC', 'HH24:MI"Z"') -- Single time
    END AS eventDate,
    -- eventRemarks

-- location
    loc.id AS locationID,
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
    CASE
        WHEN observer2.id IS NOT NULL THEN observer1.name || ', ' || observer2.name
        ELSE observer1.name
    END AS identifiedBy,

-- taxon
    CASE
        WHEN taxon.euringcode != '' THEN 'euring:' || taxon.euringcode -- Works for '' and NULL. Resulting value is cf. watervogels
        ELSE ''
    END AS taxonID,
    taxon.scientificname AS scientificName,
    'Animalia' AS kingdom,
    'Chordata' AS phylum, -- SAS contains birds, cetaceans and Basking shark
    -- scientificNameAuthorship, -- This information is not available in SAS
    taxon.dutchvernacularname AS vernacularName, -- TODO: decide EN or NL
    'ICZN' AS nomenclaturalCode

FROM observation AS obs
    LEFT JOIN taxon ON obs.taxon = taxon.id
    LEFT JOIN controlledvocabulary AS age ON obs.age = age.id AND age.type = 'age'
    LEFT JOIN controlledvocabulary AS plumage ON obs.plumage = plumage.id AND plumage.type = 'plumage'
    LEFT JOIN controlledvocabulary AS behaviour ON obs.behaviour = behaviour.id AND behaviour.type = 'behaviour'
    LEFT JOIN calculatedmeasurement AS loc ON obs.calculatedmeasurement = loc.id
    LEFT JOIN surveyevent AS survey ON obs.surveyevent = survey.id
    -- via surveyevent
    LEFT JOIN controlledvocabulary AS observer1 ON survey.observer1 = observer1.id AND observer1.type = 'observer'
    LEFT JOIN controlledvocabulary AS observer2 ON survey.observer2 = observer2.id AND observer2.type = 'observer'
    LEFT JOIN condition AS condition ON survey.observer2 = observer2.id AND observer2.type = 'observer'
WHERE
    taxon.id != 'f3310e23-e014-4897-80c4-07fd293525db' -- exclude observations without birds (inbocode: 0)
    AND taxon.id != 'd818f147-2571-4770-aed8-f5338e303fb5' -- exclude boat observations (inbocode: 9999)
LIMIT 10
