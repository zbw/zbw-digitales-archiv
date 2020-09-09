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

echo $file

awk '{ sub("\r$", ""); print }' < $1 > $fileUnix

echo "Bitte warten. Datensätze werden heruntergeladen."

cat $fileUnix | xargs -n 1 -i curl -s "http://unapi.k10plus.de/?id=k10plus:ppn:{}&format=marcxml" > records.xml

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
language.iso,subject.jel,description.version,seriesname,relation.ispartofseries,\
journalname,relation.ispartof,url,description.abstract --sep_char '\t' < records.xml > records-$1.csv

if [[ -s records-$1.csv ]]
then
    echo "Konvertierung erfolgreich.";
else
    echo "Konvertierung fehlgeschlagen, Programm bricht ab.";
    exit 1
fi

mv *.txt archive/ppns
mv records-* archive/records

rm records.xml
