# Vlaams Open Data Portaal

Our IPT datasets are discoverable via the [Vlaams Open Data Portaal (VODAP)](http://opendata.vlaanderen.be/organization/inbo). This information is pulled automatically from the [DCAT feed of our IPT](https://data.inbo.be/ipt/dcat) and includes:

* `dcat:Catalog` (1): the list of published datasets on the IPT
* `dcat:Dataset` (many): metadata for each dataset
* `dcat:Distribution` (as many): a link to the Darwin Core Archive for each dataset

## Update DCAT feed

Our IPT DCAT feed always reflects the last published information. If information is outdated, the dataset in question needs to be updated and republished.

## DCAT harvesting

Our IPT DCAT feed is harvested monthly by VOCAB. INBO admins at VOCAB will receive an email for each harvest. **No manual maintenance is required.** However, if updates need to be made:

To update the settings:

1. Login at [VODAP](http://opendata.vlaanderen.be/)
2. Go to <http://opendata.vlaanderen.be/harvest/inbo-dcat>
3. Click `Beheer` (requires INBO admin rights at VOCAB)
4. Click `Bewerk` to update metadata
5. Set `Bron type` to `Generic DCAT RDF Harvester`
6. Set `Configuratie` to (`email_reporting` can also be set to `on_error`):
    ```json
    {
        "rdf_format":"application/rdf+xml",
        "email_reporting":"always"
    }
    ```
7. Save

To manually trigger a harvest, go to <http://opendata.vlaanderen.be/harvest/inbo-dcat>, click `Beheer` and then `Reharvest`.

To update the organization page, go to <http://opendata.vlaanderen.be/organization/inbo> and click `Beheer`.

## DCAT-AP validation

Our IPT DCAT feed should be compliant with the [DCAT-AP v1.1](https://joinup.ec.europa.eu/release/dcat-ap-v11).

To test compliancy:

1. Go to <http://opendata.vlaanderen.be/validator>
2. Enter our DCAT URL: `https://data.inbo.be/ipt/dcat`
3. Click submit
4. Review report

The VOCAB however is far less strict regarding validation: if the syntax is OK, the feed is more or less accepted.

## Development and fixing errors

This IPT DCAT feed was developed in a [2015 Summer of Code project](https://github.com/inbo/ipt-dcat) and is part of the IPT source code (and thus available for all IPTs). If any changes need to be made, send an issue or pull request at <https://github.com/gbif/ipt>.
