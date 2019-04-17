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
