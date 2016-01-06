# Invasive species - American bullfrog (Lithobates catesbeianus) in Flanders, Belgium

*Invasive species - American bullfrog (Lithobates catesbeianus) in Flanders, Belgium* is a species occurrence dataset published by the Research Institute for Nature and Forest (INBO) at <http://dataset.inbo.be/invasive-bullfrog-occurrences>.

## Data publication process

* [Metadata](https://docs.google.com/a/inbo.be/document/d/1BkEDwmk3yiF0MWCxSnQva4oNAoYy9-E75VwPuuHzFRU/edit?usp=sharing) (working document)
* [Known issues](https://github.com/LifeWatchINBO/data-publication/labels/invasive-bullfrog-occurrences)
* [Submit an issue](https://github.com/LifeWatchINBO/data-publication/issues/new) (please mention the dataset name)

## Notes

* In `establishmentMeans`, we use `alien` instead of `introduced` and `invasive alien` instead of `alien` as that is the terminology used in Belgium.
* If known, we add the Belgium IAS code in `establishmentMeans`: `invasive alien A3`
* In `recordedBy` and `identifiedBy`, we use the NBN code of the person: `BFN001790000004L`
* For a number of invasive species, we mention the webpage of the species at the IAS website: `http://ias.biodiversity.be/species/show/88` in `taxonID`.
* `lifeStage` contains a whole bunch of information, including number of individuals and lifestages based on length. As a result it is not a clean controlled vocabulary.
* added `dynamicProperties` to add information on the original survey/source of the data/project. `{"projectName":"INVEXO - American bullfrog"}`
