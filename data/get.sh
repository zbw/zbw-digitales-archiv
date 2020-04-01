#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'No arguments supplied!'
    exit 1
fi

echo "Bitte warten. Datensätze werden heruntergeladen."
cat $1 | xargs -n 1 -i curl -sS "http://unapi.k10plus.de/?id=gvk7:ppn:{}&format=marcxml" > records.xml
catmandu convert MARC --type XML to CSV --fix marc2csv.fix --fields identifier.ppn,type,date.issued,title,part,\
title.alternative,identifier.isbn,contributor.primary,contributor.other,identifier.pi,rights,publisher,\
language.iso,subject.ddc,subject.jel,description.version,subject.keyword,relation.ispartofseries,relation.ispartof,\
url,description.abstract --sep_char '\t' < records.xml > records.csv
