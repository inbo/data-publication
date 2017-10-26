# -*- coding: utf-8 -*-
"""
Author: Stijn Van Hoey
created within the scope of Lifewatch - INBO
"""

import sys
import argparse
import requests

# urllib is used to escape spaces, ampersands. 
# for strings, use: urllib.parse.quote_plus(string)
# for tuples of parameters, use: urllib.parse.urlencode(parameters)
import urllib.parse

import pandas as pd

def extract_gbif_accepted_key(usage_key, addname=True):
    """get the acceptedKey and acceptedScientificName for any usageKey of 
    Gbif; if not available, empty string returned
    
    Parameters
    -----------
    usage_key : int
        usage_key as provided by GBIF for a specific species
    
    Returns
    --------
    acceptedKey : str
        key of the accepted name synonym
    acceptedScientificName : str
        scientific name of the accepted name synonym
    """
    base_string = "http://api.gbif.org/v1/species/"
    request = base_string + urllib.parse.quote_plus(str(usage_key))
    message = requests.get(request).json()
    if "acceptedKey" in message.keys():
        acceptedKey = message["acceptedKey"]
    else:
        acceptedKey = ""
    
    if "accepted" in message.keys():
        acceptedScientificName = message["accepted"]
    else:
        acceptedScientificName = ""        
        
    return acceptedKey, acceptedScientificName

def extract_gbif_species_names_info(species_name, kingdom=None, 
                                    strict=True, verbose=False):
    """API request to Gbif for species name info
    
    Parameters
    ----------
    species_name : str
        species name, preferably the Gbif proposed name
    kingdom : str
        kingdom of the species
    strict : boolean
        if true it (fuzzy) matches only the given name, but never a taxon in 
        the upper classification
    verbose:
        if true it shows alternative matches which were considered but then 
        rejected
    
    Info
    ----
    http://www.gbif.org/developer/species
     """
    base_string = 'http://api.gbif.org/v1/species/match?'
    
    if not pd.isnull(kingdom) and not pd.isnull(species_name):
        request_parameters = {'verbose': str(verbose), 'strict': str(strict), 'kingdom': kingdom, 'name': species_name}
        request = base_string + urllib.parse.urlencode(request_parameters)
        # print(request)
        return requests.get(request).json()
    elif pd.isnull(kingdom) and not pd.isnull(species_name):
        request_parameters = {'verbose': str(verbose), 'strict': str(strict), 'name': species_name}
        request = base_string + urllib.parse.urlencode(request_parameters)
        # print(request)
        return requests.get(request).json()

    else:
        return None    

def _get_json_species_dtypes(message):    
    """extract the dtypes of the parsed json-file
    """
    return {key:type(val) for key, val in message.items()}

def _derive_scientific_name_column(dfcolnames):
    """estimate the scientificname column headername based on 
    simple ruleset
    
    scientific name:
    A/ screen column names for scientificname (and all upper and lower 
    alternatives)
    B/ if A fails, screen if both scientific and name are part of a column name
    C/ if B fails, screen for anything with name
       
    (assuming always a single column with this type of information)
    """
    column_names = dfcolnames.tolist()
    lower_names = [name.lower() for name in column_names]
    
    # check for scientific name
    if "scientificname" in lower_names:
        name_idx = lower_names.index("scientificname")
        namecol = column_names[name_idx]
    elif any(['scientific' in term \
                        and 'name' in term \
                        and (not 'gbifapi' in term) for term in lower_names]):
        name_idx = [idx for idx, term in enumerate(lower_names) if \
                        ('scientific' in term and 'name' in term)][0] #take first (! assumption)
        namecol = column_names[name_idx]
    elif "name" in lower_names:
        name_idx = [idx for idx, term in enumerate(lower_names) if \
                        ('name' in term)][0] #take first (! assumption)
        namecol = column_names[name_idx]    
    elif "naam" in lower_names:
        name_idx = [idx for idx, term in enumerate(lower_names) if \
                        ('naam' in term)][0] #take first (! assumption)
        namecol = column_names[name_idx]          
    else:
        raise Exception("""Not able to identify a representative column to use
                            as scientific name column. Please specify column.
                            """)                
    return namecol

def _derive_kingdom_column(dfcolnames):
    """estimate the kingdom column headername based on 
    simple ruleset
    
    kingdom:
    A/ screen column names for kingdom (and all upper and lower 
    alternatives)
    B/ if A fails, assuming no kingdom column available
    
    (assuming always a single column with this type of information)
    """
    column_names = dfcolnames.tolist()
    lower_names = [name.lower() for name in column_names]
    
    # check for kingdom
    if "kingdom" in lower_names:
        king_idx = lower_names.index("kingdom")
        kingdomcol = column_names[king_idx]  
    else:
        kingdomcol = None
                
    return kingdomcol 

def add_acceptkey_to_message(message):
    """check if acceptkey should be added
    
    if synonym or misapplied in the status -> request for acceptedkey,
    if doubt or accepted -> existing usagekey is taken
    """
    if "SYNONYM" in message['status'] or \
                                message['status'] == "MISAPPLIED":
        accepted_key, accepted_scientific_name = \
                        extract_gbif_accepted_key(message['usageKey'])
        message["acceptedKey"] = str(accepted_key)
        message["acceptedScientificName"] = accepted_scientific_name   
    else:
        message["acceptedKey"] = str(message['usageKey'])  
        message["acceptedScientificName"] = message['scientificName']
        
def extract_species_information(species_list_in, 
                                output=None,
                                update_cols=False,                                 
                                api_terms=["usageKey", 
                                           "scientificName", 
                                           "canonicalName",
                                           "status", 
                                           "rank", 
                                           "matchType", 
                                           "confidence"], 
                                namecol=None, 
                                kingdomcol=None,
                                strict=True
                                ):
    """read tsv, request the information from GBIF and add the required 
    information from the mapping
    
    Parameters
    ----------
    species_list_in : str | pd.DataFrame
        filename (full path) of the tsv file listing the species interested in 
        or pandas DataFrame with the respective columns
    update_cols : boolean
        if True, the columns with the GBIF API terms are updated; when False, 
        the api terms are added, with each gbif-term column named gbifapi_*
    api_terms : list | 'all'
        the terms from the API to store in the CSV file
    output : None | str
        if None, output is provided as output; otherwise a filename to save the
        tsv file
    strict : boolean
        add strict option to the api request as True or False
    
    Returns
    -------
    species_list_fill : pd.DataFrame
        filled version of the tsv table
    """
    
    if isinstance(species_list_in, str):
        # Reading in the files (csv or tsv)
        if species_list_in.endswith('tsv'):
            delimiter = '\t'
        else:
            delimiter = ','
        species_list = pd.read_csv(species_list_in, sep=delimiter,
                                   encoding='utf-8', dtype=object)
    elif isinstance(species_list_in, pd.DataFrame):
        species_list = species_list_in
    else:
        raise Exception('Input datatype not supported, use either str or a \
                            pandas DataFrame')

    # try to find out which columns the scientific name and kingdom have
    if not namecol:
        namecol = _derive_scientific_name_column(species_list.columns)
    if not kingdomcol:
        kingdomcol = _derive_kingdom_column(species_list.columns)
    
    # provide user information about column use
    if kingdomcol:
        print(''.join(['Using columns ', namecol, ' and ', kingdomcol, 
                       ' for API request.']))
    else:
        print(''.join(['Using only ', namecol, 
                       ' as name column for API request.']))    
                       
    # collect all API information
    api_output = {}
    for indx, row in species_list.iterrows():
        # make request
        if kingdomcol:
            species_info = extract_gbif_species_names_info(row[namecol], 
                                                           row[kingdomcol],
                                                           strict=strict)   
        else:
            species_info = extract_gbif_species_names_info(row[namecol],
                                                           strict=strict)                                                          
        
        # check response and save
        if species_info and (not species_info['matchType'] == 'NONE'): 
            # add extra item with acceptedKey
            add_acceptkey_to_message(species_info)
            # collect messages in dict
            api_output[indx] = species_info
            #dtypes_to_use = _get_json_species_dtypes(species_info)
        elif species_info and 'note' in species_info:
            api_output[indx] = {'matchType': 'NONE ' + species_info['note']}
        else:
            api_output[indx] = {'matchType': 'NONE'}  
    species_df = pd.DataFrame(api_output).transpose()
    # put the dtypes to object:
    for col in species_df.columns:
        species_df[col] = species_df[col].astype(object)
    
    # drop non-required names
    api_terms_to_extract = api_terms[:]
    if 'all' not in api_terms_to_extract:
        api_terms_to_extract.append("acceptedKey")  # add acceptedKey as default required column
        api_terms_to_extract.append("acceptedScientificName")  # add acceptedScientificName as default required column
        try:
            species_df = species_df[api_terms_to_extract]       
        except:
            raise Exception('Not all names of api_terms available in request')          

    # Put the gbifapi_ string in front of these keys
    species_df.columns = ["".join(["gbifapi_", term]) for term in species_df.columns]
    
    if update_cols:
        for term in species_df.columns:
            if not term in species_list.columns:
                if term in ["gbifapi_acceptedKey", "gbifapi_acceptedScientificName"]:
                    species_list[term] = species_df[term]
                else:
                    raise Exception("".join(["Update not possible, column ", term, 
                                             " not yet part of the dataframe"]))
            else:
                species_list[term] = species_df[term]
                
        species_list_fill = species_list
        
    else:
        if sum([term.startswith("gbifapi_") for term in species_list]) == \
                    species_df.columns.size:
            raise Exception("""The gbifAPI terms are already enlisted in the 
                            species list, consider update_cols for updating 
                            the columns
                            """)
        # concatenate old and new (control naming)        
        species_list_fill = pd.concat((species_list, species_df), axis=1)        

    if output:
        species_list_fill.to_csv(output, sep=delimiter, 
                                 index=False, 
                                 encoding='utf-8')
    return species_list_fill    

def main(argv=None):
    """
    Request species name information to the GBIF API and concatenate the 
    information to an existing data table
    """    
    parser = argparse.ArgumentParser(description="""Request species name 
        information to the GBIF API and concatenate the information to an 
        existing data table.
        """)    
    
    parser.add_argument('inputfile', type=str,
                        help='the relative path and filename containing the species to request the info')
                       
    parser.add_argument('outputfile', action='store', default=None, 
                        help='output file name, can be same as input')
   
    parser.add_argument('--update', dest='update', 
                        action='store_true', default=False, 
                        help='the columns are updated instead of added (False when not selected)')                    
    
    parser.add_argument('--namecol', type=str,
                        action='store', default=None, 
                        help='column header from which to read the scientific name; if None, an automatic derivation is attempted (default: None)')                                            

    parser.add_argument('--kingdomcol', type=str,
                        action='store', default=None, 
                        help='column header from which to read the kingdom; if None, an automatic derivation is attempted (default: None)')                                            

    parser.add_argument('--strict', dest='strict', action='store_true',
                        default=False, help='Perform the GBIF API strict (False when not selected)')                        

    parser.add_argument('--api_terms', type=str, nargs='+',
                        action='store', default=["usageKey", 
                                           "scientificName", 
                                           "canonicalName",
                                           "status", 
                                           "rank", 
                                           "matchType", 
                                           "confidence"], 
                        help="""specify the names to extract from the GBIF API 
                            request, default: usageKey scientificName
                            canonicalName status rank matchType confidence. If 
                            all, the entire message is taken into columns
                            """
                        )

    args = parser.parse_args()
    print(args)    
    print(args.inputfile)    
    
    print("Working on the requests...")
    extract_species_information(args.inputfile, args.outputfile,
                                api_terms=args.api_terms,
                                update_cols=args.update,                                 
                                namecol=args.namecol, 
                                kingdomcol=args.kingdomcol,
                                strict=args.strict
                                ) 
    print("saving to file...done!")

if __name__ == "__main__":
    sys.exit(main())
 

 
 
 
 
 
 
 
 
 
 
 