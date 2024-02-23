#!/bin/bash

token_file="token"
user_file="user"

# Function for performing the search for a specific ID
search_id_prod() {
    local id="$1"
    local token=$(<"$token_file")
    local response=$(curl -X POST -H "Content-Type: application/json" -H "Accept: application/json" -H "rest-dspace-token: $token" --data "{\"key\":\"dc.identifier.ppn\",\"value\":\"$id\",\"language\":\"en\"}" "https://zbw.eu/econis-archiv/rest/items/find-by-metadata-field?expand=metadata")
    echo "$response" >> search_results.json
}

search_id_test() {
    local id="$1"
    local user=$(<"$user_file")
    local response=$(curl -X POST --basic -u $user -H "Content-Type: application/json" --data "{\"key\":\"dc.identifier.ppn\",\"value\":\"$id\"}" "https://testdarch.zbw.eu/econis-archiv/rest/items/find-by-metadata-field?expand=metadata")
    echo "$response" >> search_results.json
}

# Check whether the number of arguments is correct
if [ "$#" -ne 2 ]; then
    echo "Wrong number of arguments. Usage: $0 [prod|test] [id_file]"
    exit 1
fi

# Festlegen des Zielsystems
target="$1"

# TSV file
tsv_file="output.tsv"

# ID file
id_file="$2"

# Result file
result_file="search_results.json"

# Check whether the file with the IDs exists
if [ ! -f "$id_file" ]; then
    echo "The file $id_file does not exist."
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
if [ "$target" == "prod" ]; then
    while IFS= read -r id; do
        echo "Search for ID: $id"
        search_id_prod "$id"
    done < "$id_file"
elif [ "$target" == "test" ]; then
    while IFS= read -r id; do
        echo "Search for ID: $id"
        search_id_test "$id"
    done < "$id_file"
else
    echo "Invalid option. Usage: $0 [prod|test] [id_file]"
    exit 1
fi

# Check whether the JSON file contains data
if [ ! -s "$result_file" ]; then
    echo "The JSON file $result_file is empty or does not exist."
    exit 1
fi

# Extract the value of the "id" and "dc.identifier.ppn" and write them to the TSV file
printf "id\tdc.identifier.ppn\n" >> "$tsv_file"
jq -r '.[] | [.id, (.metadata[] | select(.key == "dc.identifier.ppn").value)] | @tsv' "$result_file" >> "$tsv_file"

echo "Extraction completed. Results were saved in $tsv_file."
