# Accessing the REST API of the Digitales Archiv

Repository to investiage a new workflow for fetching data from the REST API of the Digitales Archiv

Version: 2024-02-23 v0.0.1

## How it works

The scripts will leverage [DSpace's REST API's](https://wiki.lyrasis.org/display/DSDOC5x/REST+API#RESTAPI-Items).

For a list of available endpoints, see [this page](https://zbw.eu/econis-archiv/rest/).

### Authentication

#### Test system

A user name and password are required to access the test system. These credentials must be saved in a file with filename `user` in the form `username:password`.

#### Productive system

A token is required for access to the production system. This token can be requested by POST via the endpoint `/rest/login` by sending the following body:

```json
{
    "email":"<your_email_address>",
    "password":"<your_password>"
}
```

Set the following request header: `Content-Type:application/json`

This token must be saved in a file with filename `token`.

### Search for records and extract the record ID and PPN

Invoke `find-by-metadata-field.sh` to retrieve a specific DSpace item by its PPN value by calling

```bash
./find-by-metadata-field.sh [prod|test] [ppn_file]
```

For example

```bash
./find-by-metadata-field.sh prod ppns.txt
```

The script will iterate over the list of PPN's and make requests to the `find-by-metadata-field` API using the option `?expand=metadata`. The response is written to a file `search_results.json`.

After that, jq will extract the ID and PPN and write it to a file `output.tsv`. This file has two columns (id, dc.identifier.ppn), delimited by tab.

## Important notes for PPN file

- The PPN file has to use UNIX line breaks.
- No BOM allowed in the PPN file. See [Byte Order Mark Wikipedia page](https://de.wikipedia.org/wiki/Byte_Order_Mark) for details.

## Planned development

- Investigate other API's
