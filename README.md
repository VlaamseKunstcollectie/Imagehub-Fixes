# Imagehub-Fixes

<img src="https://i.imgur.com/qMqZMhj.png" alt="imagehub workflow April 2019">

This repository is a development repo with the goal to create several ETL pipeline scripts. Below is a description of what the final pipelines should do, and which test files are relevant to them.

## Pre-imagehub ETL

these ETL pipelines take data from elsewhere and push them either to Cantaloupe, or to Imagehub:
- **Datahub -> Datahub2**: this takes 200 LIDO files from the Datahub, enriches them with additional metadata from a CSV file, and imports them into another copy of the Datahub (Datahub 2) that sits on the Imagehub VPS.
- **Datahub2 -> ResourceSpace**: This automatically imports metadata LIDO files from the Datahub 2 OAI-PMH endpoint into resource space, making at least 1 resource for every LIDO file (without an image uploaded to it yet), or additional resources per LIDO file with more than 1 image, and returning an index of resource IDs from resource space that will be used by the ImageFiles -> ResourceSpace script.
- **Image files -> ResourceSpace**: This script takes a list of resource IDs and uploads the corresponding images to resourcespace, filling the empty resources with image files and letting resourcespace extract metadata embedded in the image
- **ResourceSpace API -> Cantaloupe**: If Cantaloupe can't automatically extract converted image files using Httpsource from the Resourcespace API, a script will have to be written to interact with the resourcespace API and extract image files to a file system where they can then be picked up by Cantaloupe.
- **ResourceSpace API -> Imagehub**: This script takes metadata from the resourcespace API, adds extra metadata from the Datahub 2, and metadata from the Image API's info.json files, and converts them to manifest.json files that are then storen in the Imagehub MongoDB to be exposed by the Presentation API. 

## Post-imagehub ETL

Additionally, there is an ETL pipeline that take data from Imagehub//Datahub, and pushes it to Arthub:
- **Datahub 2 -> Arthub**: This script is very similar to the 'vanilla' Datahub -> Arthub script, but it should add links to the manifest.json files associated with the LIDO file that is being processed, potentially having to store both in an SQLite database or an equivalent of that before pushing them to the Arthub Solr database. 

## csv 

The CSV folder contains 5 CSV files that are used to read data out of the Datahub, enrich them, and deposit those enriched LIDO files into the Datahub copy. A detailed explanation of every CSV file, its columns, and how it should be used, can be found on the wiki. 

## examples

The examples folder contains 3 more folders, that show the different types of data that can be encountered when dealing with LIDO files. 

- 1Lido1Image: This folder contains 2 lido files, 1 origin file extracted from the datahub, and a destination file showing how the LIDO files should be transformed before depositing it in the datahub copy. This lido file only has 1 image associated to it, and thus only has 1 Resource. It has no relations to other LIDO files. It is an example of metadata coming from the Museum voor Schone Kunsten, Gent. It shows how the file is enriched with translations. 
- 1LidoMulImage: This folder contains 2 lido files, 1 origin file extracted from the datahub, and a destination file showing how the LIDO files should be transformed before depositing it in the datahub copy. this lido file has multiple images associated to it, and thus has multiple resources. It has no relations to other LIDO files. It is an example of metadata coming from the GroeningeMuseum Brugge. It shows how the file is enriched with translations. 
- MulLido1Image: This folder contains 4 lido files, 2 origin files extracted from the datahub, and 2 destination files showing how the LIDO files should be transformed before depositing it in the datahub copy. Each individual lido file has 1 image associated to it, and thus has 1 resource. These lido files are related to each other, as shown in the RelatedWorks wrap.  They are examples of metadata coming from the KMSK Antwerpen. It shows how the file is enriched with translations.


