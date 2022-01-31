# ZBW - digital archive data fetcher and converter

This program downloads data from the K10Plus union catalogue and performs a conversion to a proprietary CSV schema.

## Getting started and prerequisites

1. Install curl.
2. Install cpanminus.
3. Install [Catmandu](http://librecat.org/Catmandu/#installation). The necessary dependencies are automatically resolved and installed.
4. Install the Catmandu MARC importer:
```
$ sudo cpanm Catmandu::Importer::MARC
```
5. Install the Catmandu CSV exporter:
```
$ sudo cpanm Catmandu::Exporter::CSV
```

### Usage

First there has to be a list of PPN IDs (one per row) in a file. A PPN (PICA production number) is a unique record identifier for bibliographic records in a CBS database.

Run the script by calling it with the filename as parameter.

```
$ ./get.sh [filename]
```

The records are now being downloaded and converted using Catmandu's ETL engine.

The PPN file will be automatically moved to a distinct directory: ```archive/ppns```

A CSV file ```records-[filename].csv``` will be created that stores the converted records. The column separator is tab (\t). The file will be moved to ```archive/records```. 

If the mapping has to be adjusted, it is as simple as editing the mapping file ```marc2csv-solr.fix```. Use Catmandu's [fix language](https://github.com/LibreCat/Catmandu/wiki/Fix-language).

## Authors

* **Felix Hemme** - *Initial work* - [ZBW](https://zbw.eu/de/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
