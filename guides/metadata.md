# Metadata

## Basic metadata

### Description

The dataset description has this default format, unless it has been changed for a data paper:

    *<Name of dataset>* is a species occurrence dataset published by the Research Institute for Nature and Forest (INBO). 
    The dataset contains over <number and type of> occurrences sampled between <dates> from <number of locations> in <area>. 
    The dataset includes over <number of species with some info>. 
    <Purpose of why the data was collected>. 
    <Information on additional data>. 
    Issues with the dataset can be reported at https://github.com/LifeWatchINBO/dataset-shortname

Example:

> *VIS - Fishes in inland waters in Flanders, Belgium* is a species occurrence dataset published by the Research Institute for Nature and Forest (INBO). The dataset contains over 350,000 fish occurrences sampled between 1992 and 2012 from over 2000 locations in inland rivers, streams, canals, and enclosed waters in Flanders, Belgium. The dataset includes over 75 fish species, as well as a number of non-target species (mainly crustaceans). The data are retrieved from the Fish Information System (VIS), a database set up to monitor the status of fishes and their habitats in Flanders and are collected in support of the Water Framework Directive, the Habitat Directive, certain red lists, and biodiversity research. Additional information, such as measurements, absence information and abiotic data are available upon request. Issues with the dataset can be reported at https://github.com/inbo/data-publication/tree/master/datasets/vis-inland-occurrences

## Project data

Short description of the project, if any. 

	Project title: Waterbird counts Flanders
	Personnel:
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

Example metadata:

> During the waterbird counts shall be aimed for maximal standardization. Each month and every winter, the same areas are counted in an identical manner. Only in this way reliable comparisons can be made between data originating from several months or years and from different areas.

Example datapaper:

    Over 2000 locations in inland rivers, streams, canals, and enclosed waters in Flanders, Belgium have been sampled since 1992. In 2001, these locations were consolidated in a monitoring network ("VISmeetnet") of 900 sampling points. The geographic coordinates in the dataset are those of the sampling locations. Since these do not always represent the actual coordinates of the catch, which may have occurred further up- or downriver, the coordinateUncertaintyInMeters has been set to 250.

### Sampling description

Example metadata:

>The counts are done in fixed enclosed areas, the waterVogelTelGebieden named verbatimLocality in the dataset. In these enclosed areas the present species are counted as complete as possible. Clearly visible areas are often counted from one point with a telescope. Large and less visible areas are usually traversed on foot, by bicycle or by car. A special case are the monthly counts on the Zeeschelde wich are performed from boats by INBO staff.
>
It is also important that the risk of double-counting or missing groups of waterbirds is kept as small as possible. Therefore the count limit is set to only two days each month and volunteers are asked to count areas within close range one after another, or even better, simultaniously using more recorders.
>
The mid monthly counts are each done during the day. Counts birds resting places places are not. For certain species additional roosting counts were performed because it was shown that that kind of counts do give a better measure of the number of species on the spot. Since 2003 every winter two simultanious counts of cormorants are done (mid November and mid December). In January 2009 a first count of Curlews was organized and specific high tide counts were organized for typical coastal waders (hiding on high tide gather places). The Zeeschelde on the contrary, is mainly counted at low tide due to better visibility of the birds.

Example datapaper:

	In inland waters, standardized sampling methods were used as described in Belpaire et al., 2000 and Van Thuyne, 2010 and are specified in the dataset as dwc:samplingProtocol.
	Per water body, the same method was used for each sampling event. The default method is electric fishing, but additional techniques such as gill nets, fykes, and seine netting (variable sizes) were used as well.
	Electric fishing was carried out using a 5kW generator with an adjustable output voltage of 300-500V and a pulse frequency of 480Hz. The number of electric fishing devices and hand-held anodes used depends on the river width (Belpaire et al., 2000).
	In riverine environments, electric fishing was carried out on both riverbanks in upstream direction. All fishes were identified to species level, counted, and their length and weight was measured.
	The default method used in estuarine waters is paired fyke netting, but additional techniques such as anchor netting, seine netting, pound netting, electric fishing, and eel fyke netting were used as well (Breine et al., 2011).
	All fishes were identified to species level, counted their length and weight was measured.

### Quality control description

Extended information on the validation and quality control used in the dataset generation.

Example metadata:

    All records are validated.

Example datapaper:

    Strict field protocols where used. The Manual for Application of the European Fish Index (EFI) (Fame consortium, 2004) served as a guideline for electrofishing and was used in support of the EU water framework directive.
    Users of the data can comment on the inland waters and estuarine waters dataset at https://github.com/LifeWatchINBO/vis-inland-occurrences and https://github.com/LifeWatchINBO/vis-estuarine-occurrences respectively.

## Citations

For a datapaper:

### References cited within the metadata

Example:

		Belpaire C, Smolders R, Vanden Auweele I, Erecken D, Breine J, Van Thuyne G, Ollevier F (2000) An Index of Biotic Integrity characterizing fish populations and the ecological quality of Flandrian water bodies, Hydrobiologia, 434: 17-33, 2000.
		Breine, J, Maes, J., Ollevier F, Stevens M (2011) Fish assemblages across a salinity gradient in the Zeeschelde estuary (Belgium). Belgian Journal of Zoologie, 141 (2): 21-44.
		Breine JJ, Maes J, Quataert P, Van den Bergh E, Simoens I, Van Thuyne G, Belpaire C (2007) A fish-based assessment tool for the ecological quality of the brackish Schelde estuary in Flanders (Belgium). Hydrobiologia, 575: 141-159.

### Publications based on this dataset

Example:

		Adriaenssens V, Goethals P, Breine J, Maes J, Simoens I, Ercken D, Belpaire C, Ollevier F, De Pauw N (2002) Referenties voor een visindex. Landschap, 19 (1): 59-61.
		Adriaenssens V, Goethals P, De Pauw N, Breine J, Simoens I, Belpaire C, Maes J, Ercken D, Ollevier F (2002) Ontwikkeling van een estuariene visindex in Vlaanderen. Water, 2: 1-13.
		Bervoets L, Goemans G, Belpaire C, Van den Boeck H, De Boeck G, De Jonge M, Van Thuyne G, Breine J, Joosen S, Van De Vijver B, Ningtias P, De Temmerman L, De Cooman W (2007) Ecologische en Ecotoxicologische toestand van de Dommel vóór de sanering van de waterbodem. Statusrapport 1, 60 pp + bijlagen.

### Publications describing the database

Example:

		Verbiest H, Belpaire C, Vandenabeele P, Ollevier F (1996) Het in werking stellen van de visdatabank met de nadruk op de gebruiksvriendelijkheid ervan IBW.Wb.V.R.96.042.
		Verbiest H, Vandenabeele P, Belpaire C, Ollevier F (1994) Ontwerp van de visdatabank en implementatie van historische en recente gegevens IBW.Wb.V.R.94.029.

## Collection data

## External links

## Additional metadata

Hierarchy level: dataset

### Purpose  - Rationale

The rationale of the dataset. In a datapaper this will come directly under the `Data Published through` section

Example:

	Counting waterbirds has a long tradition in Flanders, going back to the 1960s. The aim of this long-running monitoring scheme is to gather reliable information on the numbers, trends, and distribution of these species during their winter and migration period. Through this project, required data become available for international treaties and conventions such as the European Union (EU) Birds and Habitats Directives, the Ramsar Convention on Wetlands, and the Agreement on the Conservation of African-Eurasian Migratory Waterbirds (AEWA). These results are also used for informed decision-making by conservation bodies, planners and developers, and contribute to the sustainable use and management of wetlands and their dependent waterbirds.

### Additional information

Example:

	The overall coordination of the waterbird monitoring project is the responsibility of the Research Institute for Nature and Forest (INBO). To organize the counts, a regional network has been set up. Flanders is divided into 24 regions, each of them with a local coordinator. The fieldwork is mainly done by skilled volunteer birdwatchers, often working together within local bird clubs. The NGO "Natuurpunt" supports the majority of these bird clubs and volunteers and thereby delivers an important contribution to the waterbird project. A number of large and important wetland areas are counted by INBO staff (especially in the Scheldt estuary and along the Yser river).
	The project "" waterbird counts Flanders "" includes six major censuses in the period from October to March. These counts take place during the weekend closest to the 15th of the month. Counts are made at all kind of wetland habitats such as lakes, ponds, reservoirs and rivers. Also agricultural areas, often holding large numbers of waterbirds (such as wintering geese), are included.
	During the counts, numbers of all waterbird species are recorded. This includes divers, grebes, cormorants, herons and allies, swans, geese, ducks, coots and rails. Waders and gulls (optional) have been added on the species list in 1999. Counts of coastal waders are however available since 1992. For Great Cormorant, Eurasian Curlew and gulls there are also additional counts on roost sites.
	Although the projects aims to a (nearly) complete coverage of all areas hosting substantial numbers of waterbirds, this is hard to achieve and the number of counted sites varies between months and years.
	All data of the waterbird counts are entered in a central database managed by the Institute for Nature and Forest. Through a site, http://www.watervogels.inbo.be, volunteers have the opportunity to enter their count data and additional data directly into the central database. This special site is only available to permanent employees on the project waterbird counts.


