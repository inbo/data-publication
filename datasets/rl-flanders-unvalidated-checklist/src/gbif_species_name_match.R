
library('rgbif')
library('dplyr')
library('assertthat')
library('assertable')


#' Add species information provided by the GBIF taxonomic backbone API
#'
#' This functions extends an existing dataframe with additional columns provided
#' by the GBIF taxonomic backbone and matched on the species scientific name,
#' which need to be an available column in the dataframe.
#'
#' This function is essentially a wrapper around the existing rgbif
#' functionality `name_lookup()` and extends the application to a data.frame.
#' For more information on the name matching API of GBIF on which rgbif relies,
#' see https://www.gbif.org/developer/species
#'
#' @param df data.frame with species information
#' @param name_col char column name of the column containing the scientific
#' names used for the name matching with the GBIF taxonomic backbone.
#' @param list list of valid GBIF terms
#'
#'@return df with GBIF information as additional columns
#'
request_species_information <- function(df, name_col,
                                        gbif_terms = c('usageKey',
                                                       'scientificName',
                                                       'rank',
                                                       'status',
                                                       'family')) {

    # test incoming arguments
    assert_that(is.data.frame(df))
    assert_colnames(df, name_col, only_colnames = FALSE) # colname exists in df

    # matching the GBiF matching information to the sample_data
    df %>% rowwise() %>%
        do(as.data.frame(name_backbone(name = .[[name_col]]))) %>%
        select(gbif_terms) %>%
        bind_cols(df)
    # (remark I use here Standard evaluation (SE) do instead of the NSE do_,
    # see also:
    # https://stackoverflow.com/questions/26739054/using-variable-column-names-in-dplyr-do)
}