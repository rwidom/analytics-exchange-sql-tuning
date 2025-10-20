"""
FOR REFERENCE ONLY, not necessary for running the SQL exercises.

Normalize "For Hire Vehicle" data downloaded from 
https://data.cityofnewyork.us/Transportation/For-Hire-Vehicles-FHV-Active/8wbx-tsch/about_data
for import into the Postgres database in docker.
To use this on updated raw data, save the raw downloaded file under "data_prep" in this 
repo or adjust "SRC_DIR" below.
"""

import pandas as pd
from pathlib import Path

DATA_DIR = Path(__file__).parent / "data"
SRC_DIR = Path(__file__).parent / "data_prep"

# Read in the raw data and do some clean-up
df = pd.read_csv(SRC_DIR / "For_Hire_Vehicles__FHV__-_Active_20250926.csv")
new_names = {col: col.replace(" ","_").lower() for col in df.columns}
df = df.rename(columns=new_names)
print(f"ALL POSSIBLE COLUMNS: {df.columns}")
df = df.drop(columns=['active', 'license_type', 'vehicle_vin_number', 'veh', 'hack_up_date', 
        'reason', 'order_date', 'last_date_updated', 'last_time_updated', 'certification_date'])
df = df.rename(columns={"name": "fhv_name"})
df["base_key"] = [int(base_number[1:]) for base_number in df.base_number]

# create small table
small_df = (
    df.wheelchair_accessible.fillna("Missing").value_counts()
    .reset_index().reset_index()
    .rename(columns={
        "index": "wheelchair_accessible_key", 
        "wheelchair_accessible": "wheelchair_accessible_desc",
        "count": "total_vehicles",
    })
)
small_df.set_index("wheelchair_accessible_key").to_csv(DATA_DIR / "wheelchair_access.csv")
print(small_df)

# create medium table
medium_df = (
    df[['base_key', 'base_number', 'base_name', 'base_type', 'base_telephone_number', 'website', 'base_address']]
    .drop_duplicates()
    .set_index("base_key")
)
medium_df.to_csv(DATA_DIR / "bases.csv")
print(medium_df.head(10))
print(medium_df.base_type.value_counts(dropna=False))

# normalize medium-large table
df = df.merge(
    small_df, how="left", left_on="wheelchair_accessible", right_on="wheelchair_accessible_desc"
).set_index("vehicle_license_number")
df.wheelchair_accessible_key = df.wheelchair_accessible_key.fillna(0)
df.wheelchair_accessible_key = df.wheelchair_accessible_key.astype(int)

df.to_csv(DATA_DIR / "for_hire_vehicles.csv",
    columns=[
        "base_key",
        "wheelchair_accessible_key",
        "fhv_name",
        "expiration_date",
        "permit_license_number",
        "dmv_license_plate_number",
        "vehicle_year",
    ])
