﻿#!/bin/bash

token_file="token"

# Function for performing the search for a specific ID
search_id() {
    local id="$1"
    local token=$(<"$token_file")
    local response=$(curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "rest-dspace-token: $token" --data "{\"key\":\"dc.identifier.ppn\",\"value\":\"$id\",\"language\":\"en\"}" "https://zbw.eu/econis-archiv/rest/items/find-by-metadata-field?expand=metadata")
    echo "$response" >> search_results.json
}

# TSV file
tsv_file="output.tsv"

# ID file
id_file="ppns_prod.txt"

# Result file
result_file="search_results.json"

# Check whether the file with the IDs exists
if [ ! -f "$id_file" ]; then
    echo "Die Datei $id_file existiert nicht."
    exit 1
fi

# Delete the result file, if it exists
if [ -f "$result_file" ]; then
    rm "$result_file"
fi

# Delete the TSV file, if it exists
if [ -f "$tsv_file" ]; then
    rm "$tsv_file"
fi

# Loop to run through each ID in the file
while IFS= read -r id; do
    echo "Recherche für ID: $id"
    search_id "$id"
done < "$id_file"

# Check whether the JSON file contains data
if [ ! -s "$result_file" ]; then
    echo "Die JSON-Datei $result_file ist leer oder nicht vorhanden."
    exit 1
fi

# Extract the value of the "id" and "dc.identifier.ppn" and write them to the TSV file
printf "id\tdc.identifier.ppn\n" >> "$tsv_file"
jq -r '.[] | [.id, (.metadata[] | select(.key == "dc.identifier.ppn").value)] | @tsv' "$result_file" >> "$tsv_file"

echo "Extraction completed. Results were saved in $tsv_file."
