#!/bin/bash

shopt -s nocasematch;

# Variables
target="owc-de-206"
schema="marcxml-solr"

display_usage() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Beschreibung:"
  echo "  Dieses Script liest eine Datei mit PPNs ein, lädt die bibliografischen Metadaten"
  echo "  und Exemplardaten per SRU herunter und konvertiert die Daten in eine TSV-Datei,"
  echo "  die von bulkzip weiterverarbeitet werden kann."
  echo
  echo "Optionen:"
  echo "  -f, --file <DATEI>          Angabe der Eingabedatei mit den PPNs."
  echo
  echo "  -t, --target <Datenbank>    Auswahl der PICA-Datenbank. Verfügbare Optionen:"
  echo "                              - owc-de-206 (Arbeitskatalog der ZBW)"
  echo "                              - k10plus (Datenbank 1.1)"
  echo "                              - ebooks (Datenbank 1.2)"
  echo "                              - nl-monographien (Datenbank 1.50)"
  echo "                              - nl-zeitschriften (Datenbank 1.55)"
  echo "                              Standard: owc-de-206"
  echo
  echo "  -i, --isil <ISIL>           Angabe eines ISIL (optional)."
  echo "                              Sofern kein ISIL angegeben wird, bleibt die Spalte"
  echo "                              identifier.packageid leer."
  echo
  echo "  -s, --schema <FORMAT>       Angabe des Formats. Verfügbare Optionen:"
  echo "                              - marcxml"
  echo "                              - marcxml-solr"
  echo "                              Standard: marcxml-solr"
  echo
  echo "  -h, --help                  Anzeige des Hilfemenü."
}

# Use getopt to parse short and long arguments
PARSED=$(getopt -o f:t:i:s:h --long format:,output:,verbose,help -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1
fi

# Reset the options parsed by getopt back to $@
eval set -- "$PARSED"

# Parse arguments
while true; do
  case "$1" in
    -f|--file)
      file="$2"
      shift 2
      ;;
    -t|--target)
      target="$2"
      shift 2
      ;;
    -i|--isil)
      isil="$2"
      shift 2
      ;;
    -s|--schema)
      schema="$2"
      shift 2
      ;;
    -h|--help)
      display_usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Ungültige Option: $1"
      exit 1
      ;;
  esac
done

# Check if a file has been provided
if [[ -z "$file" ]]; then
  echo "Keine Eingabedatei angegeben!"
  exit 1
fi

file_unix="${file}.unix.txt"

echo "File: $file"
echo "Database: $target"
echo "ISIL: $isil"
echo "Format: $schema"

echo -e "Datei \"$file\" wird verarbeitet."

awk '{ sub("\r$", ""); print }' < "${file}" > "${file_unix}"

echo -e "Bitte warten. Datensätze werden heruntergeladen."

# Schnittstelleninformationen
< "${file_unix}" xargs -i curl -s "http://unapi.k10plus.de/?id=${target}:ppn:{}&format=${schema}" > records.xml

if [[ -s records.xml ]]
then
  echo -e "Download erfolgreich.";
else
  echo -e "Download fehlgeschlagen, Programm bricht ab.";
  exit 1
fi

echo -e "Bitte warten. Heruntergeladene Datensätze werden konvertiert."

catmandu convert MARC --type XML to CSV \
  --fix da_fetch_mapping.fix \
  --fields biblvl,identifier.ppn,identifier.econbizid,type,date.issued,title,title.alternative,part,\
contributor.author,contributor.editor,contributor.other,identifier,identifier.pi,identifier.isbn,\
identifier.zbwid,identifier.packageid,collection_handle,url,url_pdf,filepath,download_method,\
download_browser,downloadelement_xpath,downloadelement_cssselect,rights.license,publisher,\
language.iso,description.version,relation.ispartofjournal,relation.issn,relation.journalzdbid,\
relation.journalppn,relation.ispartofbook,relation.bookppn,relation.ispartofseries,\
relation.serieszdbid,relation.seriesppn,econstor.citation.volume,econstor.citation.issue,\
econstor.citation.articlenumber,econstor.citation.startpage,econstor.citation.endpage,\
description.abstract,subject.ddc,subject.keyword,subject.jel \
  --var target="${target}" \
  --var isil="${isil}" \
  --sep_char '\t' \
  < records.xml > records-"${file}".tsv

if [[ -s records-${file}.tsv ]]
then
  echo -e "Konvertierung erfolgreich.";
else
  echo -e "Konvertierung fehlgeschlagen, Programm bricht ab.";
  exit 1
fi

ppn_dir="archive/ppns"
records_dir="archive/records"

[ ! -d "$ppn_dir" ] && mkdir -p "$ppn_dir"
[ ! -d "$records_dir" ] && mkdir -p "$records_dir"

mv -f ${file} archive/ppns
mv -f ${file_unix} archive/ppns
mv -f records-"${file}".tsv archive/records

rm records.xml