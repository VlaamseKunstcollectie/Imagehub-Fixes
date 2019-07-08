# Imagehub-Fixes

<img src="https://i.imgur.com/qMqZMhj.png" alt="imagehub workflow April 2019">

this repository contains
- some metadata files in the csv folder that are used to enrich LIDO XML files. These enriched LIDO XML files are used in a IIIF testbed for the Flemish Art Collection
- a few examples of metadata transformations, in the examples folder. It shows example source LIDO XML data, example destination LIDO XML data, and example manifest.json files
- files that originally came from the Datahub Factory, in the scripts, fixes and pipelines folders. These files are meant to be changed so they can be used to create multilingual enriched metadata for the Arthub in the IIIF testbed.

## csv 

The CSV folder contains 5 CSV files that are used to read data out of the Datahub, enrich them, and deposit those enriched LIDO files into the Datahub copy. A detailed explanation of every CSV file, its columns, and how it should be used, can be found on the wiki. 

## examples

The examples folder contains 3 more folders, that show the different types of data that can be encountered when dealing with LIDO files. 

- 1Lido1Image: This folder contains 2 lido files, 1 origin file extracted from the datahub, and a destination file showing how the LIDO files should be transformed before depositing it in the datahub copy. This lido file only has 1 image associated to it, and thus only has 1 Resource. It has no relations to other LIDO files. It is an example of metadata coming from the Museum voor Schone Kunsten, Gent. It shows how the file is enriched with translations. 
- 1LidoMulImage: This folder contains 2 lido files, 1 origin file extracted from the datahub, and a destination file showing how the LIDO files should be transformed before depositing it in the datahub copy. this lido file has multiple images associated to it, and thus has multiple resources. It has no relations to other LIDO files. It is an example of metadata coming from the GroeningeMuseum Brugge. It shows how the file is enriched with translations. 
- MulLido1Image: This folder contains 4 lido files, 2 origin files extracted from the datahub, and 2 destination files showing how the LIDO files should be transformed before depositing it in the datahub copy. Each individual lido file has 1 image associated to it, and thus has 1 resource. These lido files are related to each other, as shown in the RelatedWorks wrap.  They are examples of metadata coming from the KMSK Antwerpen. It shows how the file is enriched with translations.


