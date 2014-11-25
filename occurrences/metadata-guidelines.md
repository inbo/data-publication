# Metadata guidelines

## Basic metadata

### Shortname

The shortname is how you would write a repository name or url: `lowercase-with-hypens`. It starts with the dataset code and ends with the type of dataset (`occurrences`):

    saltabel-occurrences
    vis-inland-occurrences

### Title

The title is of the form `Dataset code - Short descriptive title of dataset`. Where applicable, it indicates the region at the end. If the dataset is an important temporal subset, the year range is included between hyphens at the end:

    VIS - Fishes in inland waters in Flanders, Belgium
    Visherintroductie - Reintroduction of the fishes chub, dace, burbot, and brown trout in Flanders, Belgium
    Broedvogel - Atlas of breeding birds in Flanders, Belgium (2000-2002)

### Description

The dataset description has this default format, unless it has been changed for a data paper:

    *<Name of dataset>* is a species occurrence dataset published by the Research Institute for Nature and Forest (INBO). 
    The dataset contains over <number and type of> occurrences sampled between <dates> from <number of locations> in <area>. 
    The dataset includes over <number of species with some info>. 
    <Purpose of why the data was collected>. 
    <Information on additional data>. 
    Issues with the dataset can be reported at https://github.com/LifeWatchINBO/dataset-shortname

Example:

> *VIS - Fishes in inland waters in Flanders, Belgium* is a species occurrence dataset published by the Research Institute for Nature and Forest (INBO). The dataset contains over 350,000 fish occurrences sampled between 1992 and 2012 from over 2000 locations in inland rivers, streams, canals, and enclosed waters in Flanders, Belgium. The dataset includes over 75 fish species, as well as a number of non-target species (mainly crustaceans). The data are retrieved from the Fish Information System (VIS), a database set up to monitor the status of fishes and their habitats in Flanders and are collected in support of the Water Framework Directive, the Habitat Directive, certain red lists, and biodiversity research. Additional information, such as measurements, absence information and abiotic data are available upon request. Issues with the dataset can be reported at https://github.com/LifeWatchINBO/vis-inland-occurrences

### Metadata & resource language

Default to `English`. The resource language should be the same as in the `language` field in the data.

    Metadata language: English
    Resource language: English

### Resource type and subtype

    Observations only:          Occurrence > Observation
    Observations and specimens: Occurrence > none

### Resource contact info

Example:

    Name:         Gerlinde Van Thuyne
    Position:     Researcher
    Organisation: Research Institute for Nature and Forest (INBO)
    Address:      Kliniekstraat 25, Brussels, Brussels Capital Region, BELGIUM, Postal Code: 1070
    Contact:      gerlinde.vanthuyne@inbo.be

### Resource creator

The resource creator is the person responsible for the original creation of the resource content.

Example:

    Name:         Gerlinde Van Thuyne
    Position:     Researcher
    Organisation: Research Institute for Nature and Forest (INBO)
    Address:      Kliniekstraat 25, Brussels, Brussels Capital Region, BELGIUM, Postal Code: 1070
    Contact:      gerlinde.vanthuyne@inbo.be
    
### Metadata providor

The metadata provider is the person responsible for processing the resource metadata.

    Name:         Dimitri Brosens
    Position:     Biodiversity Data Liaison Officer
    Organisation: Research Institute for Nature and Forest (INBO)
    Address:      Kliniekstraat 25, Brussels, Brussels Capital Region, BELGIUM, Postal Code: 1070
    Contact:      dimitri.brosens@inbo.be

## Geographic coverage

Short and concise description of the geographic area. 

Example:

    Inland rivers, streams, canals, and enclosed waters in Flanders, Belgium.
Example:

    The birds were counted at 1,196 predefined locations (waterVogelTelgebieden, figure 1), covering the wetlands and coast of Flanders, Belgium. 
    No birds were counted at sea. These locations are visited regularly during the wintering and migration season (midmonthly, from October to March). 
    For each occurrence, the code for the "waterVogelTelgebied" is indicated in localityID. 
    The polygon shape for most of these localities can be found at https://github.com/LifeWatchINBO/watervogels-occurrences/blob/master/localities/localities.geojson. 
    The geographic coordinates for the occurrences represent the centroid of the locality. 

## Taxonomic Coverage

### Description

A description of the range of taxa addressed in the data set or collection.

Example:

    The term waterfowl is used like defined in the AEWA treaty and thus, does not only include species which belong to the Anseriformes but all species which are migratory and related to wetlands.
    The AEWA treaty deals with 225 bird species, 168 species are recorded in the dataset.

### Add several taxa

List taxa at a meaningful level, down to lowest common rank.

Example:

    Kingdom: Animalia (animals)
    Phylum: Chordata
    Class: Aves (birds)
    Families: Alcidae, Anatidae, Ardeidae, Charadriidae, Ciconiidae, Gaviidae, Gruidae, Haematopodidae, Laridae, Pelecanidae, Phalacrocoracidae, Phoenicopteridae, Podicipedidae, Rallidae, Recurvirostridae, Scolopacidae, Stercorariidae, Threskiornithidae

## Temporal coverage

Information about the time periods covered by the resource. Enter start date (earliest `eventDate`) and end date (latest `eventDate`) 

## Keywords

list keywords, use , as a separator. Thesaurus vocabulary, use n/a

    waterfowl, birds, monitoring, wetlands, occurrence, observation, lifewatch



## Associated parties

The associated parties are (in order):

    point of contact (required)
    other researchers (optional)
    organizations (optional)
    processor(s) (required): Dimitri Brosens; Peter Desmet

## Project data

Short description of the project, if any. 

				Project title: Waterbird counts Flanders
				
				Personnel
				
				Combination of IPT > Basic metadata > Resource contact/Resource creator/Metadata provider, IPT > Associated parties, and IPT > Project data > Personnel.
				
				Principal investigators: Koen Devos
				Resource contact: 
				Resource creator: 
				Point of contact:
				Metadata provider:
				Content providers:
				Developer:
				Processors: Dimitri Brosens, Peter Desmet
				Funding: This monitoring project receives funding from the Flemish Government.

### Study area description

Identical to `Geographic coverage`, unless changed for data paper.

## Sampling methods

### Study extent description

Somewhat longer description of the sampled area: sampling locations, calculation of `coordinateUncertainInMeters`, etc.

Example1:

> Over 2000 locations in inland rivers, streams, canals, and enclosed waters in Flanders, Belgium have been sampled since 1992. In 2001, these locations were consolidated in a monitoring network ("VISmeetnet") of 900 sampling points. The geographic coordinates in the dataset are those of the sampling locations. Since these do not always represent the actual coordinates of the catch, which may have occurred further up- or downriver, the coordinateUncertaintyInMeters has been set to 250.

Example2:
> During the waterbird counts shall be aimed for maximal standardization. Each month and every winter, the same areas are counted in an identical manner. Only in this way reliable comparisons can be made between data originating from several months or years and from different areas.



### Sampling description

Example metadata:

>The counts are done in fixed enclosed areas, the waterVogelTelGebieden named verbatimLocality in the dataset. In these enclosed areas the present species are counted as complete as possible. Clearly visible areas are often counted from one point with a telescope. Large and less visible areas are usually traversed on foot, by bicycle or by car. A special case are the monthly counts on the Zeeschelde wich are performed from boats by INBO staff.
>
It is also important that the risk of double-counting or missing groups of waterbirds is kept as small as possible. Therefore the count limit is set to only two days each month and volunteers are asked to count areas within close range one after another, or even better, simultaniously using more recorders.
>
The mid monthly counts are each done during the day. Counts birds resting places places are not. For certain species additional roosting counts were performed because it was shown that that kind of counts do give a better measure of the number of species on the spot. Since 2003 every winter two simultanious counts of cormorants are done (mid November and mid December). In January 2009 a first count of Curlews was organized and specific high tide counts were organized for typical coastal waders (hiding on high tide gather places). The Zeeschelde on the contrary, is mainly counted at low tide due to better visibility of the birds.

Example datapaper:

	In inland waters, standardized sampling methods were used as described in Belpaire et al., 2000 and Van Thuyne, 2010 and are specified in the dataset as dwc:samplingProtocol. Per water body, the same method was used for each sampling event. The default method is electric fishing, but additional techniques such as gill nets, fykes, and seine netting (variable sizes) were used as well. Electric fishing was carried out using a 5kW generator with an adjustable output voltage of 300-500V and a pulse frequency of 480Hz. The number of electric fishing devices and hand-held anodes used depends on the river width (Belpaire et al., 2000). In riverine environments, electric fishing was carried out on both riverbanks in upstream direction. All fishes were identified to species level, counted, and their length and weight was measured.
	The default method used in estuarine waters is paired fyke netting, but additional techniques such as anchor netting, seine netting, pound netting, electric fishing, and eel fyke netting were used as well (Breine et al., 2011). All fishes were identified to species level, counted their length and weight was measured.
				

###Quality control description

Extended information on the validation and quality control used in the dataset generation.

Example metadata:

    All records are validated.

Example datapaper:

    Strict field protocols where used. The Manual for Application of the European Fish Index (EFI) (Fame consortium, 2004) served as a guideline for electrofishing and was used in support of the EU water framework directive.
    Users of the data can comment on the inland waters and estuarine waters dataset at https://github.com/LifeWatchINBO/vis-inland-occurrences and https://github.com/LifeWatchINBO/vis-estuarine-occurrences respectively.


## Citations

## Collection data

## External links

## Additional metadata
