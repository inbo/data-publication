import pandas as pd
import numpy as np
import zipfile

def open_first_file_from_zip(path):
    """Open first file from zip

    Directly opening a zip with pd.read_csv() returns the error 'Multiple files found in compressed zip file %s'.
    That is because Mac OS has added a __MACOSX/ directory.
    This function opens the first file it finds in the zip.
    
    Parameters
    ----------
    path: str
        Relative or absolute path name to .zip file

    Returns
    -------
    File handler of first file in .zip file

    """
    with zipfile.ZipFile(path) as zip:
        return zip.open(zip.namelist()[0])

def export_df_as_md_table(df, name='temp'):
    """Export a Pandas DataFrame as a file with a Markdown table

    Parameters
    ----------
    df: pd.DataFrame
        Pandas dataframe to be exported
    name:
        Name of the export file

    """
    df = df.reset_index()
    fmt = ['---' for i in range(len(df.columns))]
    df_fmt = pd.DataFrame([fmt], columns=df.columns, dtype=object)
    df_formatted = pd.concat([df_fmt, df])
    df_formatted.to_csv("".join([name, ".md"]), sep="|", index=False)

def print_unique_values(df, limit=20):
    """Print unique values for each column in a Pandas DataFrame
    """
    for column in df.columns:
        unique_values = df[column].astype(str).unique().tolist()
        if len(unique_values) <= limit:
            unique_values_for_print = ', '.join(np.sort(unique_values))
        else:
            unique_values_for_print = 'more than {0} values, check seperately'.format(limit)
        print(column.upper() + ': ' + unique_values_for_print +'\n')