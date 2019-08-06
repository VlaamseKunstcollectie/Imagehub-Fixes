# Imagehub-Fixes

<img src="https://i.imgur.com/z1rYcLA.png" alt="imagehub workflow August 2019">

This repository contains scripts and input files used in the IIIF imagehub architecture.

There are several folders:

* The **csv** folder contains CSV spreadsheets with data which is used to enrich the original object metadata as stored in the [Datahub](https://datahub.vlaamsekunstcollectie.be). More specifically, it contains various English translations of strings that aren't present in the original LIDO XML data.
* The **examples** folder contains several reference XML and JSON serializations of object and image metadata. These serializations are used as reference models when developing mapping and transformations.
* The **fixes** folder contains actual transformations used in ETL pipelines in the architecture.
* The **pipelines** folder contains configuration for specific ETL pipelines in the architecture.
* The **scripts** folder contains scripts that are used to trigger ETL pipelines in the architecture.

## Prerequisites

This repository needs to be deployed on a host provisioned with the dependencies and the architecture defined in the Ansible configuration of [Imagehub-Box](https://github.com/VlaamseKunstcollectie/Imagehub-Box).

These applications should have been deployed - installed and configured - successfully on this host:

* A Datahub instance
* A Resourcespace instance
* An Imagehub instance
* A Cantaloupe instance
* An Arthub instance

Refer to [Imagehub-Box](https://github.com/VlaamseKunstcollectie/Imagehub-Box) for more details.

## Installation

Clone the folder to an appropriate folder on your host. Assuming we use Ubuntu 18.04:

```bash
$ cd /srv
$ mkdir imagehub # if not exists
$ git clone https://github.com/VlaamseKunstcollectie/Imagehub-Fixes imagehub-fixes
$ ls /srv/imagehub/imagehub-fixes
```

Make sure the scripts in the `scripts` folder are executable.

```bash
$ cd scripts
$ chmod +x *.sh
```

## Usage

Assuming all prerequisites are available, running all ETL pipelines in the architecture is as simple as executing this command:

```bash
$ ./cronjob.sh
```

This script is meant to be set up as a seperate cron job which will run automatically. Execute `crontab -e` and then add this line to your crontab file:

```bash
30 21 * * * /srv/imagehub/imagehub-fixes/scripts/cronjob.sh
```

This will execute the `cronjob.sh` script every night at 9:30PM.

Restart cron after with `sudo cron restart` in order to pass on the changes to the running cron service.

The `cronjob.sh` script captures several commands that can also be executed seperately for debugging purposes. We will walk through each command:

### ETL 2 & 3

```bash
$ ( cd /srv/imagehub/imagehub ; ./app/console app:fill-resourcespace )
```

This command will take in two inputs: (a) data from the Datahub and (b) data from the image files (TIFF files) in a dropfolder. It will use those two inputs to import images and data into the ResourceSpace instance.

This command will also transform the images from uncompressed TIFF to JPEG compressed TIFF's which will be used as inputs for the Cantaloupe IIIF Image server.

### ETL 5

```bash
$ ( cd /srv/imagehub/imagehub ; ./app/console app:generate-manifests )
```

This command takes three inputs. (a) data from the Datahub (b) data from ResourceSpace and (c) IIIF Image API data from Cantaloupe. It will use these three inputs to generate IIIF Manifest files per the IIIF Presentation API specification. 

These JSON documents will be stored in a MongoDB backend and made available over HTTP via the Imagehub instance.

### Authority files

```bash
( cd /srv/imagehub/authority-files ; git pull )
```

This command simply updates local [authority-files repository](https://github.com/VlaamseKunstcollectie/Authority-Files). 

This project relies on the `CREATORS_UTF8.csv` file which is part of this repository. This file contains a concordance table of all identifiable artist names stored in local registration systems and matches them with VIAF, Wikidata and ODIS persistent URI's.

### CREATORS_UTF8.csv to CREATORS_UTF8.sqlite

```bash
( cd /srv/imagehub/imagehub-fixes/scripts ; ./creators.sh -e /srv/imagehub/authority-files/CREATORS_UTF8.csv )
```

This command converts the CREATORS_UTF8.csv file to a SQLite database which is stored in the `/tmp` folder. This SQLite database is queried as a data source by the `lookup_in_store` function that is used in the [Catmandu](https://librecat.org) fixes stored in the `fixes` folder.

### ETL 6

```bash
(
  cd /srv/imagehub/imagehub-fixes/scripts ;
  ./arthub-index.sh -e https://datahub.iiif.vlaamsekunstcollectie.be/oai -l ../fixes/datahub-oai-to-blacklight-solr-en.fix ;
  ./arthub-index.sh -e https://datahub.iiif.vlaamsekunstcollectie.be/oai -l ../fixes/datahub-oai-to-blacklight-solr-nl.fix
)
```

The `arthub-index.sh` script contains several steps that will fetch LIDO XML data from a Datahub instance, convert and merge those into a JSON document stored as `/tmp/bulk_raw.json`. This file will then be pushed to a Apache Solr Bulk JSON API request handler, triggering an indexing process.

This script will call the `process.pl` listing. This Perl listing will fetch the raw XML strings and inject them in the JSON document `/tmp/bulk.json` as a separate `xml` Solr field defined in Solr's `schema.xml` configuration.

The actaully script is executed twice with two differing fixes. The first will extract and process English (EN) metadata, the second will extract and process Dutch (NL) metadata.

## Contents

### CSV

The CSV folder contains 5 CSV files that are used to read data out of the Datahub, enrich them, and deposit those enriched LIDO files into the Datahub copy. A detailed explanation of every CSV file, its columns, and how it should be used, can be found on the wiki. 

### Examples

The examples folder contains 3 more folders, that show the different types of data that can be encountered when dealing with LIDO files. 

* **1Lido1Image**: This folder contains 2 lido files, 1 origin file extracted from the datahub, and a destination file showing how the LIDO files should be transformed before depositing it in the datahub copy. This lido file only has 1 image associated to it, and thus only has 1 Resource. It has no relations to other LIDO files. It is an example of metadata coming from the Museum voor Schone Kunsten, Gent. It shows how the file is enriched with translations. 
* **1LidoMulImage**: This folder contains 2 lido files, 1 origin file extracted from the datahub, and a destination file showing how the LIDO files should be transformed before depositing it in the datahub copy. this lido file has multiple images associated to it, and thus has multiple resources. It has no relations to other LIDO files. It is an example of metadata coming from the GroeningeMuseum Brugge. It shows how the file is enriched with translations. 
* **MulLido1Image**: This folder contains 4 lido files, 2 origin files extracted from the datahub, and 2 destination files showing how the LIDO files should be transformed before depositing it in the datahub copy. Each individual lido file has 1 image associated to it, and thus has 1 resource. These lido files are related to each other, as shown in the RelatedWorks wrap.  They are examples of metadata coming from the KMSK Antwerpen. It shows how the file is enriched with translations.
* **Manifests**: This folder contains 1 example IIIF Manifest file based on actual data from the Datahub.

## Credits

* Matthias Vandermaesen <matthias dot vandermaesen at vlaamsekunstcollectie dot be>
* Jolan Wuyts <jolan dot wuyts at vlaamsekunstcollectie dot be>
* [All contributors](https://github.com/vlaamsekunstcollectie/imagehub-fixes/contributors)

## License

The Datahub is copyright (c) 2019 by Vlaamse Kunstcollectie vzw and PACKED vzw.

This is free software; you can redistribute it and/or modify it under the terms of the The MIT License. Please see [License File](https://github.com/vlaamsekunstcollectie/imagehub-fixes/LICENSE.md) for more information.

