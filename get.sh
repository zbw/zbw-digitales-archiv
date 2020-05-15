#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'No arguments supplied!'
    exit 1
fi

echo "Bitte warten. Datensätze werden heruntergeladen."

cat $1 | xargs -n 1 -i curl -s "http://unapi.k10plus.de/?id=gvk7:ppn:{}&format=marcxml" > records.xml

if [[ -s records.xml ]]
then 
    echo "Download erfolgreich.";
else
    echo "Download fehlgeschlagen, Programm bricht ab."; 
    exit 1
fi

echo "Bitte warten. Heruntergeladene Datensätze werden konvertiert."

catmandu convert MARC --type XML to CSV --fix marc2csv.fix --fields identifier.ppn,type,date.issued,title,part,\
title.alternative,identifier.isbn,contributor.primary,contributor.other,identifier.pi,rights,publisher,\
language.iso,subject.ddc,subject.jel,description.version,subject.keyword,relation.ispartofseries,relation.ispartof,\
url,description.abstract --sep_char '\t' < records.xml > records.csv

if [[ -s records.csv ]]
then 
    echo "Konvertierung erfolgreich.";
else
    echo "Konvertierung fehlgeschlagen, Programm bricht ab."; 
    exit 1
fi

mv ppns-*.txt data/archive/ppns

rm records.xml
