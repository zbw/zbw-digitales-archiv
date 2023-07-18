#!/bin/bash

shopt -s nocasematch;

# Variables
file=${1}
fileUnix="${file}.unix.txt"
defaultTarget="owc-de-206"
target="${2:-$defaultTarget}"
isil=${3}
format="marcxml-solr"

display_usage() {
    echo -e "\nDas Programm erwartet drei Argumente beim Aufruf:\n./da_fetch.sh [Dateiname] [Target] [ISIL]\\n
Sofern kein Target angegeben wird, werden die Daten aus owc-de-206 abgezogen.\\n
Sofern kein ISIL angegeben wird, bleibt die Spalte identifier.packageid leer.\n"
}

display_targets() {
  echo -e "Folgende Targets sind verfügbar:\n\
- owc-de-206 (Arbeitskatalog der ZBW)\n\
- k10plus (Datenbank 1.1)\n\
- ebooks (Datenbank 1.2)\n\
- nl-monographien (Datenbank 1.50)\n\
- nl-zeitschriften (Datenbank 1.55)\n"
}

# Check on arguments
if [[ $# -eq 0 ]] ; then
  echo -e "\nFEHLER: Kein Dateiname angegeben."
  display_usage
  display_targets
  exit 1
fi

# Validate target argument
if [[ $target != "owc-de-206" && $target != "k10plus" && $target != "ebooks" && $target != "nl-monographien" && $target != "nl-zeitschriften" ]] ; then
  echo -e "Ungültiges Target.\n"
  display_targets
  exit 1
fi

if [[ $target = "owc-de-206" ]] ; then
  echo -e "Daten werden aus Target \"owc-de-206\" abgezogen."
elif [[ $target = "k10plus" ]] ; then
  echo -e "Daten werden aus Target \"k10plus\" abgezogen."
elif [[ $target = "ebooks" ]] ; then
  echo -e "Daten werden aus Target \"ebooks\" abgezogen."
elif [[ $target = "nl-monographien" ]] ; then
  echo -e "Daten werden aus Target \"nl-monographien\" abgezogen."
elif [[ $target = "nl-zeitschriften" ]] ; then
  echo -e "Daten werden aus Target \"nl-zeitschriften\" abgezogen."
fi

if [[ $isil ]] ; then
  echo -e "Das Sigel \"${isil}\" wurde angegeben."
fi

echo -e "Datei \"$file\" wird verarbeitet."

awk '{ sub("\r$", ""); print }' < "${1}" > "${fileUnix}"

echo -e "Bitte warten. Datensätze werden heruntergeladen."

# Schnittstelleninformationen
< "${fileUnix}" xargs -i curl -s "http://unapi.k10plus.de/?id=${target}:ppn:{}&format=${format}" > records.xml

if [[ -s records.xml ]]
then
  echo -e "Download erfolgreich.";
else
  echo -e "Download fehlgeschlagen, Programm bricht ab.";
  exit 1
fi

echo -e "Bitte warten. Heruntergeladene Datensätze werden konvertiert."

catmandu convert MARC --type XML to CSV --fix da_fetch_mapping.fix --fields identifier.ppn,type,date.issued,title,part,\
title.alternative,identifier.isbn,relation.issn,relation.journalzdbid,relation.serieszdbid,contributor.author,contributor.editor,contributor.other,identifier,\
identifier.pi,rights.license,publisher,language.iso,subject.jel,description.version,relation.ispartofseries,relation.seriesppn,\
relation.ispartofjournal,relation.journalppn,relation.ispartofbook,relation.bookppn,econstor.citation.volume,econstor.citation.issue,econstor.citation.articlenumber,\
econstor.citation.startpage,econstor.citation.endpage,url,collection_handle,identifier.packageid,filepath,description.abstract,subject.ddc,subject.keyword --var target="${target}" --var isil="${isil}" --sep_char '\t' < records.xml > records-"${1}".csv

if [[ -s records-${1}.csv ]]
then
  echo -e "Konvertierung erfolgreich.";
else
  echo -e "Konvertierung fehlgeschlagen, Programm bricht ab.";
  exit 1
fi

ppnDir="archive/ppns"
recordsDir="archive/records"

[ ! -d "$ppnDir" ] && mkdir -p "$ppnDir"
[ ! -d "$recordsDir" ] && mkdir -p "$recordsDir"

mv ./*.txt archive/ppns
mv records-* archive/records

rm records.xml
