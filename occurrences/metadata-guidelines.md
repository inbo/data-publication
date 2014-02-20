# Metadata guidelines

## Basic metadata

### Shortname

The shortname is how you would write a repository name or url: `lowercase-with-hypens`. It starts with the dataset code and ends with the type of dataset (`occurrences`):

    saltabel-occurrences
    vis-inland-occurrences

### Title

The title is of the form `Dataset code - Short descriptive title of dataset`. Where applicable, it indicates the region at the end.

    VIS - Fishes in inland waters in Flanders, Belgium
    Visherintroductie - Reintroduction of the fishes chub, dace, burbot, and brown trout in Flanders, Belgium

### Description

The dataset description has this default format, unless it has been changed for a data paper:

    <Name of dataset> is a species occurrence dataset published by the Research Institute for Nature and Forest (INBO). 
    The dataset contains over <number and type of> occurrences sampled between <dates> from <number of locations> in <area>. 
    The dataset includes over <number of species with some info>. 
    <Purpose of why the data was collected>. 
    <Information on additional data>. 
    Issues with the dataset can be reported at https://github.com/LifeWatchINBO/dataset-shortname

Example:

> VIS - Fishes in inland waters in Flanders, Belgium is a species occurrence dataset published by the Research Institute for Nature and Forest (INBO). The dataset contains over 350.000 fish occurrences sampled between 1992 and 2012 from over 2000 locations in inland rivers, streams, canals, and enclosed waters in Flanders, Belgium. The dataset includes over 75 fish species, as well as a number of non-target species (mainly crustaceans). The data are retrieved from the Fish Information System (VIS), a database set up to monitor the status of fishes and their habitats in Flanders and are collected in support of the Water Framework Directive, the Habitat Directive, certain red lists, and biodiversity research. Additional information, such as measurements, absence information and abiotic data are available upon request. Issues with the dataset can be reported at https://github.com/LifeWatchINBO/vis-inland-occurrences

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

## Geographic coverage

Short and concise description of the geographic area. Example:

> Inland rivers, streams, canals, and enclosed waters in Flanders, Belgium.

## Taxonomic description

## Temporal coverage

## Keywords

## Associated parties

The associated parties are (in order):

    point of contact (required)
    other researchers (optional)
    organizations (optional)
    processor(s) (required): Dimitri Brosens; Peter Desmet

## Project data

### Study area description

Identical to `Geographic coverage`, unless changed for data paper.

## Sampling methods

### Study extent

Somewhat longer description of the sampled area: sampling locations, calculation of `coordinateUncertainInMeters`, etc.

Example:

> Over 2000 locations in inland rivers, streams, canals, and enclosed waters in Flanders, Belgium have been sampled since 1992. In 2001, these locations were consolidated in a monitoring network ("VISmeetnet") of 900 sampling points. The geographic coordinates in the dataset are those of the sampling locations. Since these do not always represent the actual coordinates of the catch, which may have occurred further up- or downriver, the coordinateUncertaintyInMeters has been set to 250.

## Citations

## Collection data

## External links

## Additional metadata
