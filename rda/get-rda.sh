#!/bin/sh

cat ppns-w32-first.txt | xargs -n 1 -i curl "http://unapi.k10plus.de/?id=gvk7:ppn:{}&format=marcxml" > records.xml
catmandu convert MARC --type XML to CSV --fix marc2csv.fix --fields identifier.ppn,type,date.issued,title,title.alternative,\
identifier.isbn,contributor.author,editor,identifier.pi,rights,publisher,language.iso,subject.ddc,\
subject.jel,description.version,subject.keyword,ispartofseries,ispartofseries2,url,\
description.abstract --sep_char '\t' < records.xml
