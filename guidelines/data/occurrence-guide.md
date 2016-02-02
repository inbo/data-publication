# Guide for Darwin Core occurrence data

## Terms to verify

* [ ] Term names are in lowerCamelCase
* [ ] `occurrenceID` does not contain duplicates
* [ ] `occurrenceID` is globally unique (eby concatenating IDs)
* [ ] `occurrenceID` is stable (by referring to internal IDs)
* [ ] `type` uses an UpperCamelCase vocabulary
* [ ] `language` is `en`
* [ ] `license` is `http://creativecommons.org/publicdomain/zero/1.0/`
* [ ] `rightsHolder` is `INBO`
* [ ] `accessRights` is `http://www.inbo.be/en/norms-for-data-use`
* [ ] `datasetID` is of the form `http://dataset.inbo.be/shortname`
* [ ] `datasetID` is the dataset DOI (after registration)
* [ ] `institutionCode` is `INBO`
* [ ] `datasetName` is the latest dataset title
* [ ] `ownerInstitutionCode` is `INBO`
* [ ] `basisOfRecord` uses [this UpperCamelCase vocabulary](http://rs.gbif.org/vocabulary/dwc/basis_of_record.xml) 
* [ ] `informationWithheld` could be `see metata`, where it is described in additional information
* [ ] `dataGeneralizations` could be `coordinates are generalized to a 5x5km UTM grid`
* [ ] `dynamicProperties` is understandable to an outside user
* [ ] `dynamicProperties` is valid JSON
* [ ] `recordedBy` is of the form `First name Last name`, `F. Last name` or an anonymous unique code
* [ ] `recordedBy` delimits multiple values with ` | `
* [ ] `individualCount` are all integers
* [ ] `individualCount` has limited outliers
* [ ] `individualCount` has no 0 (would indicate absense data) 
* [ ] `sex` uses [this lowercase vocabulary](http://rs.gbif.org/vocabulary/gbif/sex.xml) (alternative terms allowed)
* [ ] `sex` delimits multiple values with ` | `
* [ ] `lifeStage` uses [this lowercase vocabulary](http://rs.gbif.org/vocabulary/gbif/life_stage.xml) (alternative terms allowed)
* [ ] `lifeStage` delimits multiple values with ` | `
* [ ] `eventID` refers to an internal ID
* [ ] `samplingProtocol` is a lowercase controlled vocabulary (or refers to a DOI)
* [ ] `samplingEffort` indicates the effort as a number
* [ ] `samplingEffort` is valid JSON
* [ ] `eventDate` is [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)
* [ ] `eventDate` does not contain date ranges (use `verbatimEventDate`)
* [ ] `locationID` refers to an internal ID
* [ ] `continent` is `Europe`
* [ ] `country` is not used
* [ ] `countryCode` is `BE`
* [ ] `stateProvince` is a vocabulary of English names
* [ ] `municipality` is ideally a vocabulary of local names
* [ ] `verbatimLocality` contains the fullest location name/description
* [ ] `verbatimCoordinates` is used for (UTM) grid codes only
* [ ] `verbatimLatitude` is the UTM y coordinate
* [ ] `verbatimLongitude` is the UTM x coordinate
* [ ] `verbatimCoordinateSystem` is `Belgian Lambert 72` for coordinates or e.g. `UTM 5km` for grids
* [ ] `verbatimCoordinateSystem` is only populated when there are verbatim coordinates/lat/long
* [ ] `verbatimSRS` is `Belgian Datum 1972`, `ED50` or `WGS84`
* [ ] `verbatimSRS` is only populated when there are verbatim coordinates/lat/long
* [ ] `decimalLatitude` has a precision of 5 decimals
* [ ] `decimalLongitude` has a precision of 5 decimals
* [ ] The coordinates are verified on a map
* [ ] `geodeticDatum` is `WGS84`
* [ ] `geodeticDatum` is only populated when there are decimal coordinates
* [ ] `coordinateUncertaintyInMeters` is the radius of a circle containing the complete area where the occurrence might have been seen, e.g. `3536` for a 5x5km grid square
* [ ] `coordinateUncertaintyInMeters` is only populated when there are decimal coordinates
* [ ] `georeferenceRemarks` shortly describes the coordinates calculation, e.g. `coordinates are centroid of used grid square`
* [ ] `georeferenceRemarks` is only populated when there are decimal coordinates
* [ ] `identifiedBy` is of the form `First name Last name`, `F. Last name` or an anonymous unique code
* [ ] `identifiedBy` delimits multiple values with ` | `, but is generally a single person 
* [ ] `scientificName` is the accepted taxon name, without author
* [ ] `kingdom` is always populated, e.g. `Animalia`
* [ ] `phylum` is generally populated
* [ ] `class` can be populated
* [ ] `order` can be populated
* [ ] `taxonRank` uses [this lowercase vocabulary](http://rs.gbif.org/vocabulary/gbif/rank.xml)
* [ ] `taxonRank` matches the rank of the `scientificName`
* [ ] `scientificNameAuthorship` is the author of the `scientificName` (not populated for forms, hybrids)
* [ ] `vernacularName` is the English or Dutch vernacular name of the `scientificName`
* [ ] `nomenclaturalCode` is `ICZN` or `ICBN`

## Terms we seldom use

* [ ] `references` would contain a public URL with more information about an occurrence, and we don't have those
* [ ] `behavior` is seldom noted in an easy to retrieve way
* [ ] `behavior` uses a lowercase vocabulary
* [ ] `establishmentMeans` like `invasive` is more a property for a checklist
* [ ] `establishmentMeans` uses [this lowercase vocabulary](http://rs.gbif.org/vocabulary/gbif/establishment_means.xml) (alternative terms allowed)
* [ ] `occurrenceStatus` is  assumed to be `present`, except for sample datasets
* [ ] `occurrenceStatus` uses [this lowercase vocabulary](http://rs.gbif.org/vocabulary/gbif/occurrence_status.xml) (alternative terms allowed)
* [ ] `associatedReferences` could be used to indicate source literature
* [ ] `associatedTaxa` could be used to indicate relations, such as host plants
* [ ] `verbatimEventDate` is only populated for records with a date range
* [ ] `verbatimEventDate` is [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)
* [ ] `habitat` is seldom noted in an easy to retrieve way
* [ ] `habitat` is lowercase
* [ ] `waterBody` uses a vocabulary
* [ ] `georeferencedBy` is only used for more complicated georeferencing
* [ ] `georeferencedDate` is only used for more complicated georeferencing
* [ ] `georeferencedDate` is [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601)
* [ ] `georeferenceProtocol` is only used for more complicated georeferencing, e.g. `doi:10.1080/13658810412331280211`
* [ ] `georeferenceSources` is only used for more complicated georeferencing
* [ ] `georeferenceVerificationStatus`  is only used for more complicated georeferencing
* [ ] `georeferenceVerificationStatus` uses a lowercase vocabulary, e.g. `unverified`
* [ ] `identificationVerificationStatus` can be used for citizen science data with validation
* [ ] `identificationVerificationStatus` uses a lowercase vocabulary, e.g. `verified`
* [ ] `taxonID` is a publicly known code or URL, e.g. `euring:07610`
* [ ] `family` is generally not populated, except for datasets with very few species
* [ ] `genus` is generally not populated, except for datasets with very few species
* [ ] `specificEpithet` is generally not populated, except for datasets with very few species

## Terms we don't use

This is not a full list, just terms we might have populated before.

* [ ] `modified` seldom reflects all modifications, such as altered mapping
* [ ] `bibliographicCitation` is the citation of a dataset, which is in the metadata and too bulky to repeat for every occurrence
* [ ] `locality` is not used, as our vocabularies only apply to `municipality` and higher, or `waterBody`
* [ ] `dateIdentified` is assumed to be the `eventDate` and is thus not populated
* [ ] `identificationReferences` is almost never known
* [ ] `verbatimTaxonRank` is not used since we only have regular `taxonRank`s
* [ ] `originalNameUsage` is reserved for checklists
* [ ] `taxonomicStatus` is reserved for checklists

## Specialized datasets

For specimen records, populate the following terms:

* [ ] `type` is `PhysicalObject`
* [ ] `basisOfRecord` is `PreservedSpecimen`
* [ ] `collectionCode` refers to the collection acronym
* [ ] `catalogNumber` refers to the ID on the specimen

For tracking data, try to populate these terms:

* [ ] `organismID` the code for the indivual
* [ ] `organismName` the name of the individual

For an event core, try to populate these terms:

* [ ] `organismQuantity`
* [ ] `organismQuantityType`
* [ ] `parentEventID`
* [ ] `sampleSizeValue`
* [ ] `sampleSizeUnit`
* [ ] `eventRemarks`
