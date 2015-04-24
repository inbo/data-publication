# Bird tracking - GPS tracking of Lesser Black-backed Gull and Herring Gull breeding at the Belgian coast

Eric Stienen [^1], Peter Desmet [^1], Francisco Hernandez [^2], Willem Bouten [^3], Luc Lens [^4]

[^1]: Research Institute for Nature and Forest (INBO), Kliniekstraat 25, 1070, Brussels, Belgium

[^2]: Flanders Marine Institute (VLIZ), Wandelaarkaai 7, 8400, Ostend, Belgium

[^3]: Institute for Biodiversity and Ecosystem Dynamics (IBED), University of Amsterdam, Science Park 904, 1098 XH, Amsterdam, The Netherlands

[^4]: Terrestrial Ecology Unit (TEREC), Ghent University, K.L. Ledeganckstraat 35, 9000, Ghent, Belgium

**Corresponding author(s)**: Eric Stienen (<eric.stienen@inbo.be>), Peter Desmet (<peter.desmet@inbo.be>)

---

*Received {date} | Revised {date} | Accepted {date} | Published {date}*

---

**Citation**: *Combination of authors, year of data paper publication (in parentheses), Title, Journal Name, Volume, Issue number (in parentheses), and doi of the data paper.*

---

**Resource Citation**: Research Institute for Nature and Forest (INBO). Bird tracking - GPS tracking of Lesser Black-backed Gull and Herring Gull breeding at the Belgian coast. Online at <http://dataset.inbo.be/bird-tracking-gull-occurrences>. Published on 2014-06-18. GBIF key: [83e20573-f7dd-4852-9159-21566e1e691e](http://www.gbif.org/dataset/83e20573-f7dd-4852-9159-21566e1e691e)

## Abstract

*Bird tracking - GPS tracking of Lesser Black-backed Gull and Herring Gull breeding at the Belgian coast* is a species occurrence dataset published by the Research Institute for Nature and Forest (INBO). The dataset currently contains over 1.1 million occurrences, recorded in 2013 and 2014 by 60 GPS trackers mounted on 44 Lesser Black-backed Gulls and 16 Herring Gulls breeding at the Belgian coast (see <https://inbo.cartodb.com/u/lifewatch/viz/lifewatch.da04f120-ea70-11e4-a3f2-0e853d047bba/public_map> for a visualization of the data). The trackers are developed by the University of Amsterdam Bird Tracking System (UvA-BiTS, <http://www.uva-bits.nl>) and automatically record and transmit the movements of the birds, which allows us and others to study their habitat use and migration behaviour in more detail. Our bird tracking network is set up and maintained in collaboration with UvA-BiTS and the Flanders Marine Institute (VLIZ), and funded for LifeWatch by the Hercules Foundation. The data are released in bulk as open data and are also accessible through CartoDB. See the dataset metadata for contact information, scope and methodology. Issues with the data or dataset can be reported at <https://github.com/LifeWatchINBO/data-publication/tree/master/datasets/bird-tracking-gull-occurrences>

## Keywords

animal movement, bird tracking, GPS tracking, habitat use, migration, Lesser Black-backed Gull, Larus fuscus, Herring Gull, Larus argentatus, UvA-BiTS, LifeWatch, open data, MachineObservation, Occurrence, Observation

## Data published through

<http://dataset.inbo.be/bird-tracking-gull-occurrences>

## Rationale

As part of our terrestrial observatory for LifeWatch (<http://lifewatch.inbo.be>), the Research Institute for Nature and Forest (INBO) is tracking large birds with lightweight, solar powered GPS trackers. The project builds upon the extensive knowledge the INBO has acquired over the last 12 years in studying postnuptial migration, and mate and site fidelity of large gulls, using sightings of colour-marked individuals ringed in Belgium. The data this bird tracking network collects allow us to study the migration patterns and habitat use of the gulls in more detail, and are no longer biased towards locations where observers can see the birds. To allow greater use of the data beyond our research questions, all data are published as open data.

## Taxonomic coverage

The dataset contains tracking data from 44 Lesser Black-Backed Gulls (*Larus fuscus*) and 16 Herring Gulls (*Larus argentatus*) breeding at the Belgian coast.

### Taxonomic ranks

**Kingdom**: *Animalia* (animals)

**Phylum**: *Chordata*

**Class**: *Aves* (birds)

**Order**: *Charadriiformes*

**Family**: *Laridae* (gulls)

**Genus**: *Larus*

**Species**: *Larus fuscus* (Lesser Black-backed Gull), *Larus argentatus* (Herring Gull)

## Geographic coverage

The birds breed at the Belgian coast in two colonies: the port of Zeebrugge and Ostend. Their foraging range includes the west of Belgium, northern France, the North Sea, and the English Channel. The Lesser Black-backed Gulls migrate south in winter, mainly hibernating in the south of Spain, Portugal, and North Africa. See <https://inbo.cartodb.com/u/lifewatch/viz/lifewatch.da04f120-ea70-11e4-a3f2-0e853d047bba/public_map> for a visualization of the geospatial extent of the data.

### Bounding coordinates

10° to 60° latitude, -25° to 10° longitude

## Temporal coverage

**Date range**: 2013-05-17 to 2014-02-12

**Formation periods**: breeding season 2013
**Formation periods**: winter season 2013
**Formation periods**: breeding season 2014

## Datasets

### Dataset description

* **Object name**: Bird tracking - GPS tracking of Lesser Black-backed Gull and Herring Gull breeding at the Belgian coast
* **Character encoding**: UTF-8
* **Format name**: Darwin Core Archive format
* **Format version**: 1.0
* **Distribution**: <http://dataset.inbo.be/bird-tracking-gull-occurrences>
* **Publication date of data**: 2014-06-18
* **Language**: English
* **Licenses of use**: <http://creativecommons.org/publicdomain/zero/1.0/>
* **Metadata language**: English
* **Date of metadata creation**: 2014-06-18
* **Hierarchy level**: Dataset

### External datasets

All our public bird tracking data are also available through CartoDB (<https://inbo.cartodb.com/u/lifewatch>), where users can query the data using SQL via the CartoDB API or download these in various formats (`csv`, `shp`, `kml`, `svg`, and `geosjon`). Two tables are of use: `bird_tracking`, containing all occurrence data and `bird_tracking_devices`, containing information on the GPS trackers and individual birds. Note that these tables are not standardized to Darwin Core, contain flagged outliers (omitted from the standardized dataset), and include data from other bird species. For more info, see <https://github.com/LifeWatchINBO/bird-tracking/blob/master/cartodb/README.md>

#### bird_tracking

* **Object name**: bird_tracking
* **Character encoding**: UTF-8
* **Format name**: CartoDB table
* **Distribution**: <https://inbo.cartodb.com/u/lifewatch/tables/bird_tracking/public>

#### bird_tracking_devices

* **Object name**: bird_tracking_devices
* **Character encoding**: UTF-8
* **Format name**: CartoDB table
* **Distribution**: <https://inbo.cartodb.com/u/lifewatch/tables/bird_tracking_devices/public>

### Additional information

The following information is not included in this dataset and available upon request: outliers, temperature, speed, accelerometer data, GPS metadata (fix time, number of satellites used, vertical accuracy), bird biometrics data measured during tagging (bill length, bill depth, tarsus length, wing length, body mass), life history data (day of ringing, age, resightings by volunteers), as well as growth data of chicks.

### Usage norms

To allow anyone to use this dataset, we have released the data to the public domain under a Creative Commons Zero waiver (<http://creativecommons.org/publicdomain/zero/1.0/>). We would appreciate it however if you read and follow these norms for data use (<https://github.com/LifeWatchINBO/norms-for-data-use>) and provide a link to the original dataset (<http://dataset.inbo.be/bird-tracking-gull-occurrences>) when possible. We are always interested to know how you have used or visualized the data, or to provide more information, so please contact us via the contact information provided in the metadata or via <https://twitter.com/LifeWatchINBO>.

## Methodology

### Study extent description

The birds were trapped and tagged at or near their breeding colony at the Belgian coast.

The colony of Zeebrugge is situated in the western part of the port (51.341 latitude, 3.182 longitude) at sites that are not yet used for port activities and on roof tops. The first Herring Gulls (HG) nested here in 1987, followed by the first breeding record of Lesser Black-backed Gull (LBBG) in 1991. In the 1990s the number of breeding pairs strongly increased, with 2,336 pairs of HG and 4,760 pairs of LBBG in 2011. After 2011 the number of gulls strongly declined due to habitat loss and the presence of foxes.

In the colony of Ostend (51.233 latitude, 2.931 longitude), breeding started in 1993. Here the number of HG stabilised at about 300 pairs since 2000 and an equal numbers of LBBG since 2010. In Ostend most gulls breed on roof tops. Currently the roofs of the Vismijn and the wood processing company Lemahieu hold most pairs.

Most birds were trapped on their nest using a walk-in cage. In 2013 and 2014 respectively 22 and 24 ground-nesting LBBG were caught in the port of Zeebrugge and respectively 5 and 8 HG on the roof of the Vismijn in Ostend. Additionally, in 2014 one ground nesting HG was caught in the port of Zeebrugge and 3 HG were caught with a small canon net when feeding on the Visserskaai in Ostend. We took biometrics of all captured gulls (bill length, bill depth, tarsus length, wing length, and body mass) and a feather sample to determine the sex. The UvA-BiTS GPS trackers were attached to the back of the gull using a harness of Teflon tape.

### Sampling description

The birds are tracked with the University of Amsterdam Bird Tracking System (UvA-BiTS, <http://www.uva-bits.nl>). The system is described in Bouten et al. 2013. The lightweight, solar powered GPS trackers periodically record the 3D position and air temperature, and can be configured to collect body movements with the built-in tri-axial accelerometer as well. The system allows us to remotely set or change a measurement interval per tracker: the actual interval between measurements is provided in `samplingEffort` as `secondsSinceLastOccurrence`.

The measured data are stored on the tracker, until these can be transmitted automatically and wireless to a base station using the built-in ZigBee tranceiver with whip antenna. This receiver is also used to receive new measurement settings. The spatial range for this communication is restricted to the location of the base station (or antenna network), which is placed near the colony. Data from birds that do not return to the colony cannot be retrieved.

Data received by the base stations are automatically harvested, post-processed, and stored in a central PostgreSQL database at UvA-BiTS (<http://www.uva-bits.nl/virtual-lab>), accessible to the involved researchers only. We periodically export the tracking data to CartoDB for visualization purposes (see the External datasets section), removing test records and flagging outliers (see <https://github.com/LifeWatchINBO/bird-tracking/blob/master/cartodb/import-procedure.md>).

To create the Darwin Core Archive, we extract the data from CartoDB and standardize these to Darwin Core using an SQL query (<https://github.com/LifeWatchINBO/data-publication/blob/master/datasets/bird-tracking-gull-occurrences/mapping/dwc-occurrence.sql>). The dataset is documented, published via our IPT (<http://dataset.inbo.be/bird-tracking-gull-occurrences>), and registered with the Global Biodiversity Information System (<http://www.gbif.org/dataset/83e20573-f7dd-4852-9159-21566e1e691e>). Issues or remarks regarding the data or this procedure can be reported at <https://github.com/LifeWatchINBO/data-publication/tree/master/datasets/bird-tracking-gull-occurrences>

To extract data from one individual, one can use `individualID`, which contains the unique metal leg ring code of each bird. Tracker IDs are provided in `dynamicProperties` as `device_info_serial`. For an overview of all GPS trackers and the individual birds these are mounted on, see <https://inbo.cartodb.com/u/lifewatch/tables/bird_tracking_devices/public>.

### Quality control description

See the section Sampling description for more details: our import procedure (<https://github.com/LifeWatchINBO/bird-tracking/blob/master/cartodb/import-procedure.md>) and standardization to Darwin Core (<https://github.com/LifeWatchINBO/data-publication/blob/master/datasets/bird-tracking-gull-occurrences/mapping/dwc-occurrence.sql>) are publicly documented.

### Method step description

1. Researcher captures bird, takes biometrics, attaches GPS tracker, and releases bird.
2. Researcher sets a measurement scheme, which can be updated anytime.
3. GPS tracker records data.
4. GPS tracker automatically receives new measurement settings and transmits recorded data when a connection can be established with the base station at the colony.
5. Recorded data are automatically harvested, post-processed, and stored in a central PostgreSQL database at UvA-BiTS.
6. LifeWatch INBO team periodically exports tracking data to CartoDB and makes these publicly accessible.
7. LifeWatch INBO team periodically (re)publishes data as a Darwin Core Archive, registered with GBIF.
8. Data stream stops when bird no longer returns to colony or if GPS tracker no longer functions (typical tracker lifespan: 2-3 years).

## Project data

### Project title

Bird tracking network

### Personnel

* **Resource contact, resource creator, principal investigator**: Eric Stienen
* **Metadata provider, processor**: Peter Desmet
* **Collaborators**: Francisco Hernandez, Willem Bouten, Luc Lens

### Funding

This bird tracking network is funded for LifeWatch by the Hercules Foundation (<http://www.herculesstichting.be/in_English/>), with additional contributions from the Terrestrial Ecology Unit (TEREC) at the University of Ghent.

## Acknowledgements



## References

Bouten W., Baaij E.W., Shamoun-Baranes J., Camphuysen K.C.J. (2013) A flexible GPS tracking system for studying bird behaviour at multiple scales. Journal of Ornithology 154 (2): 571-580. doi: [10.1007/s10336-012-0908-1](http://doi.org/10.1007/s10336-012-0908-1)
