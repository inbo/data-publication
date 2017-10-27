/*
This view creates a denormalized version of the observations and all information linked to it.

Tables and fields we want to include:
(datecreated, datelastchange and version are not listed below)

allowedusers                    n
calculatedmeasurement           y
- id                            n
- latitude                      y
- longitude                     y
- km                            y
- km2                           y
condition                       
- id                            
- starttime                     
- endtime                       
- transectwidth                 
- countmethod                   
- speciescounted                
- visibility                    
- waveheight                    
- windforce                     
- glare                         
- remarks                       
- surveyevent                   n
controlledvocabulary            n
- id                            n
- type                          n
- code                          y
- name                          y
- esascode                      y
- esasdescription               y
controlledvocabulary_warning    n
databasechangelog               n
databasechangeloglock           n
exportdownload                  n
exportposkey                    
exportstatus                    n
measurement                     y
- id                            n
- dateofmeasurement             n
- timeofmeasurement             n
- latitude                      y
- longitude                     y
- heading                       
- sog                           y
- airtemp                       y
- airpres                       y
- airhum                        y
- winddir                       
- windforce                     y
- depth                         y
- watersal                      y
- watertemp                     y
- chla                          y
- surveyevent                   n
measurementgeographicalinformation
measurementsummary              n
measurementuploads              n
measurementvalidationerror      n
migrationstatus                 n
observation                     y
- id                            y
- wp                            y
- taxon                         y
- age                           y
- plumage                       y
- distance                      y
- direction                     y
- association                   y
- remarks                       y
- turbineheight                 y
- transect                      y
- datelastchange                y
- surveyevent                   n
- starttime                     y
- endtime                       y
- group_field                   y
- number                        y
- calculatedmeasurement         n
- behaviour                     y
- flagged                       y
observation_warning             
positionalkey                     
surveyevent                     y
- survey                        y
- tripid                        n
- dateofsurvey                  y
- ship                          y
- observer1                     y
- observer2                     y
surveyevent_warning             
taxon                           y
- id                            n
- inbocode                      n
- scientificname                y
- dutchvernacularname           y
- englishvernacularname         y
- esascode                      y
- euringcode                    y
- taxonrank                     y
- taxonversionkey               n
- remarks                       n
taxon_warning                   n
userconnection                  n
users                           n
*/

SELECT    
    -- trips
    trip.id AS trip_id,
    trip.survey AS trip_survey,
    trip.dateofsurvey AS trip_date,
    ship.name AS ship,
    ship.code AS ship_code,
    observer1.name AS trip_observer1,
    observer2.name AS trip_observer2,
    
    -- position lat/longs
    linkedpos.latitude AS linkedpos_latitude,
    linkedpos.longitude AS linkedpos_longitude,
    linkedpos.km AS linkedpos_km,
    linkedpos.km2 AS linkedpos_km2,
    pos.latitude AS pos_latitude,
    pos.longitude AS pos_longitude,
    pos.number_of_meas AS pos_numberofmeasurements,
    coalesce(linkedpos.latitude, pos.latitude) as latitude,
    coalesce(linkedpos.longitude, pos.longitude) as longitude,
    
    -- positions
    -- pos.heading AS pos_heading_degrees,
    pos.speedoverground AS pos_speedoverground_knots,
    pos.airtempurature AS pos_airtempurature_celsius,
    pos.airpressure AS pos_airpressure_hpa,
    pos.airhumidity AS pos_airhumidity_percentage,
    -- pos.winddirection AS pos_winddirection_degrees,
    pos.windforce AS pos_windforce_ms,
    pos.depth AS pos_depth_m,
    pos.watersalinity AS pos_watersalinity_psu,
    pos.watertemperature AS pos_watertemperature_celsius,
    pos.chorophyla AS pos_chorophyla_µgl,
    
    -- taxa
    taxon.scientificname AS taxon_scientificname,
    taxon.inbocode AS taxon_code,
    taxon.esascode AS taxon_esascode,
    taxon.euringcode AS taxon_euringcode,
    taxon.dutchvernacularname AS taxon_vernacularname_nl,
    taxon.englishvernacularname AS taxon_vernacularname_en,
    taxon.taxonrank AS taxon_rank,

    -- observations
    obs.id AS obs_id,
    obs.starttime AS obs_starttime,
    obs.endtime AS obs_endtime,
    obs.number AS obs_individualcount,
    obs.group_field AS obs_partofgroup,
    obs.transect AS obs_transect,
    obs.wp AS obs_waypoint,
    obs.flagged AS obs_flagged,
    obs.remarks AS obs_remarks,
    obs.datelastchange AS obs_lastmodified,
        
    age.name AS obs_age,
    age.code AS obs_age_code,
    age.esasdescription AS obs_age_esas,
    age.esascode AS obs_age_esas_code,
    
    plumage.name AS obs_plumage,
    plumage.code AS obs_plumage_code,
    plumage.esasdescription AS obs_plumage_esas,
    plumage.esascode AS obs_plumage_esascode,
    
    behaviour.name AS obs_behaviour,
    behaviour.code AS obs_behaviour_code,
    behaviour.esasdescription AS obs_behaviour_esas,
    behaviour.esascode AS obs_behaviour_esascode,

    distance.name AS obs_distance,
    distance.code AS obs_distance_code,
    distance.esasdescription AS obs_distance_esas,
    distance.esascode AS obs_distance_esascode,
    
    direction.name AS obs_direction,
    direction.code AS obs_direction_code,
    direction.esasdescription AS obs_direction_esas,
    direction.esascode AS obs_direction_esascode,
    
    association.name AS obs_association,
    association.code AS obs_association_code,
    association.esasdescription AS obs_association_esas,
    association.esascode AS obs_association_esascode,

    turbineheight.name AS obs_turbineheight,
    turbineheight.code AS obs_turbineheight_code,
    turbineheight.esasdescription AS obs_turbineheight_esas,
    turbineheight.esascode AS obs_turbineheight_esascode

FROM
    observation AS obs
    
    -- trips
    LEFT JOIN surveyevent AS trip
        ON obs.surveyevent = trip.id
    LEFT JOIN controlledvocabulary AS observer1
	    ON trip.observer1 = observer1.id AND observer1.type = 'observer'
    LEFT JOIN controlledvocabulary AS observer2
        ON trip.observer2 = observer2.id AND observer2.type = 'observer'
    LEFT JOIN controlledvocabulary as ship
        ON trip.ship = ship.id AND ship.type = 'ship'
    
    -- precalculated measurements (directly linked with 1-1 relation)
    LEFT JOIN calculatedmeasurement AS linkedpos
        ON obs.calculatedmeasurement = linkedpos.id
    
    -- measurements (indirectly linked on trip, starttime, endtime)
    LEFT OUTER JOIN (
        SELECT
		    obs.id,
		    avg(meas.latitude) AS latitude,
		    avg(meas.longitude) AS longitude,
		    -- TODO: circularaverage(heading)
            avg(meas.sog) AS speedoverground,
            avg(airtemp) AS airtempurature,
            avg(airpres) AS airpressure,
            avg(airhum) AS airhumidity,
            -- TODO: circularaverage(winddir)
            avg(windforce) AS windforce,
            avg(depth) AS depth,
            avg(watersal) AS watersalinity,
            avg(watertemp) AS watertemperature,
            avg(chla) AS chorophyla,
		    count(*) AS number_of_meas
		FROM
		    observation AS obs
		    INNER JOIN surveyevent AS trip
			    ON obs.surveyevent = trip.id
		    INNER JOIN measurement AS meas
		        ON meas.surveyevent = obs.surveyevent 
				AND trip.dateofsurvey  = meas.dateofmeasurement 
				AND (obs.starttime = meas.timeofmeasurement OR obs.endtime = meas.timeofmeasurement)
		WHERE 1=1
		    AND obs.calculatedmeasurement IS NULL -- for non-precalcated measurements only
		GROUP BY
		    obs.id
		HAVING
		    count(*) <= 2 -- 0,1,2 matching measurements could be found
		) AS pos
		ON pos.id = obs.id
		
	-- taxa
    LEFT JOIN taxon
        ON obs.taxon = taxon.id
    
    -- observations
    LEFT JOIN controlledvocabulary AS age
        ON obs.age = age.id AND age.type = 'age'
    LEFT JOIN controlledvocabulary AS plumage
        ON obs.plumage = plumage.id AND plumage.type = 'plumage'
    LEFT JOIN controlledvocabulary AS behaviour
        ON obs.behaviour = behaviour.id AND behaviour.type = 'behaviour'
    LEFT JOIN controlledvocabulary AS distance
        ON obs.distance = distance.id AND distance.type = 'distance'
    LEFT JOIN controlledvocabulary AS direction
        ON obs.direction = direction.id AND direction.type = 'direction'
    LEFT JOIN controlledvocabulary AS association
        ON obs.association = association.id AND association.type = 'association'
    LEFT JOIN controlledvocabulary AS turbineheight
        ON obs.turbineheight = turbineheight.id AND turbineheight.type = 'turbineheight'
        
    -- conditions 
    -- TODO: link conditions to observations

WHERE 1=1
-- LIMIT 100
