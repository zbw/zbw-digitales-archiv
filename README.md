# ZBW - digital archive data fetcher and converter

This program downloads data from the K10Plus union catalogue and performs a conversion to a proprierary CSV schema.

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

First there must be a list of ppn-ids, one per line. A ppn (PICA production number) is a unique record identifier for bibliographic records.

Run the script by calling the shell script with specification of the ppn file as parameter.

```
$ ./get.sh [filename]
```

The records are now being downloaded and converted using Catmandu's ETL engine.

## Authors

* **Felix Hemme** - *Initial work* - [ZBW](https://zbw.eu/de/)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
