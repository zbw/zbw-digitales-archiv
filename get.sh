#!/bin/bash

display_usage() {
    echo -e "Das Programm erwartet die Angabe eines Dateinamens als Parameter:\n$ bash get.sh <Dateiname>"
}

if [[ $# -eq 0 ]] ; then
    echo "Kein Dateiname angegeben."
    display_usage
    exit 1
fi

file=$1
fileUnix="${file}.unix.txt"

echo "Datei $file wird verarbeitet."

awk '{ sub("\r$", ""); print }' < $1 > $fileUnix

echo "Bitte warten. Datensätze werden heruntergeladen."

# Schnittstelleninformationen
cat $fileUnix | xargs -n 1 -i curl -s "http://unapi.k10plus.de/?id=owc-de-206:ppn:{}&format=marcxml-solr" > records.xml

if [[ -s records.xml ]]
then
    echo "Download erfolgreich.";
else
    echo "Download fehlgeschlagen, Programm bricht ab.";
    exit 1
fi

echo "Bitte warten. Heruntergeladene Datensätze werden konvertiert."

catmandu convert MARC --type XML to CSV --fix marc2csv-solr.fix --fields identifier.ppn,type,date.issued,title,part,\
title.alternative,identifier.isbn,contributor.primary,contributor.other,identifier.pi,rights,publisher,\
language.iso,subject.jel,description.version,seriesname,relation.ispartofseries,\
journalname,relation.ispartof,url,description.abstract,subject.ddc,subject.keyword --sep_char '\t' < records.xml > records-$1.csv

if [[ -s records-$1.csv ]]
then
    echo "Konvertierung erfolgreich.";
else
    echo "Konvertierung fehlgeschlagen, Programm bricht ab.";
    exit 1
fi

ppnDir="archive/ppns"
recordsDir="archive/records"

[ ! -d "$ppnDir" ] && mkdir -p "$ppnDir"
[ ! -d "$recordsDir" ] && mkdir -p "$recordsDir"

mv *.txt archive/ppns
mv records-* archive/records

rm records.xml
