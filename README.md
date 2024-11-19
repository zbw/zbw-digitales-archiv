# ZBW - digital archive data fetcher and converter

This program downloads data from a variety of CBS databases and performs a conversion to a CSV schema designed for [Digitales Archiv](https://zbw.eu/econis-archiv/).

## Getting started and prerequisites

1. Install curl.
2. Install cpanminus.
3. Install [Catmandu](http://librecat.org/Catmandu/#installation). The necessary dependencies are automatically resolved and installed.
4. Install the Catmandu MARC importer:

```bash
sudo cpanm Catmandu::Importer::MARC
```

5. Install the Catmandu CSV exporter:

```bash
sudo cpanm Catmandu::Exporter::CSV
```

### Usage

```bash
./da_fetch.sh [OPTIONS]
```

The program accepts the following options:

| Option                      | Description                                             | Default value           |
|-----------------------------|---------------------------------------------------------|-------------------------|
| `-f, --file <FILE>`         | Specification of the input file with the PPNs.          |                         |
| `-t, --target <DATABASE>`   | Specification of the PICA database. Available options:  | `owc-de-206`            |
|                             | - `owc-de-206` (ZBW work catalog)                       |                         |
|                             | - `k10plus` (Database 1.1)                              |                         |
|                             | - `ebooks` (Database 1.2)                               |                         |
|                             | - `nl-monographien` (Database 1.50)                     |                         |
|                             | - `nl-zeitschriften` (Database 1.55)                    |                         |
| `-i, --isil <ISIL>`         | Specification of an ISIL.                               |                         |
| `-s, --schema <FORMAT>`     | Specification of format. Available options:             | `marcxml-solr`          |
|                             | - `marcxml`                                             |                         |
|                             | - `marcxml-solr`                                        |                         |
| `-h, --help`                | Display of the help menu.                               |                         |

The records are now being downloaded and converted using Catmandu's ETL engine.

The PPN file will be automatically moved to a distinct directory: ```archive/ppns```

A CSV file ```records-[FILE].csv``` will be created that stores the converted records. The column separator is tab (\t). The file will be moved to ```archive/records```.

If the mapping has to be adjusted, it is as simple as editing the mapping file ```da_fetch_mapping.fix```. Use Catmandu's [fix language](https://github.com/LibreCat/Catmandu/wiki/Fix-language).

## Authors

* **Felix Hemme** - *Initial work* - [ZBW](https://zbw.eu/de/)
* **Luisa Kramer-Ibig** - *Extensions within the scope of the SAVE project* - [ZBW](https://zbw.eu/de/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
