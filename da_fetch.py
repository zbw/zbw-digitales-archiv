import os
import subprocess
import sys
import urllib.request

def display_usage():
    print("\nDas Programm erwartet drei Argumente beim Aufruf:")
    print("./da_fetch.sh [Dateiname] [Target] [ISIL]")
    print("Sofern kein Target angegeben wird, werden die Daten aus owc-de-206 abgezogen.")
    print("Sofern kein ISIL angegeben wird, bleibt die Spalte identifier.packageid leer.")


def display_targets():
    print("Folgende Targets sind verfügbar:")
    print("- owc-de-206 (Arbeitskatalog der ZBW)")
    print("- k10plus (Datenbank 1.1)")
    print("- ebooks (Datenbank 1.2)")
    print("- nl-monographien (Datenbank 1.50)")
    print("- nl-zeitschriften (Datenbank 1.55)")


# TODO: isil parameter is not necessary
if len(sys.argv) < 4:
    display_usage()
    exit(1)

file = sys.argv[1]
fileUnix = file+".unix.txt"
target=sys.argv[2]
isil=sys.argv[3]
form="marcxml-solr"
destinationXMLFile = "./records.xml"

if target == "owc-de-206" \
        or target == "k10plus" \
        or target == "ebooks" \
        or target == "nl-monographien" \
        or target == "nl-zeitschriften":
    print("Daten werden aus Target \"" + target + "\" abgezogen.")
else:
    display_targets()

if isil == "zdb-33-sfen":
    print("Wert in Spalte identifier.packageid = \"ZDB-33-SFEN\"")

print("Datei {} wird verarbeitet.".format(file))

with open(file, "r") as inputFile:
    # For now handle only ONE PPN id.
    ppn = inputFile.readline().rstrip()

try:
    content = urllib \
            .request \
            .urlopen("http://unapi.k10plus.de/?id={}:ppn:{}&format={}" \
            .format(target,ppn,form)) \
            .read()
except urllib.error.URLError as e:
     print("Download fehlgeschlagen, Programm bricht ab.")
     print(e.read().decode("utf8", 'ignore'))
     raise

# Write answer to XML file
with open(destinationXMLFile, "wb") as destFile:
    destFile.write(content)

print("Bitte warten. Heruntergeladene Datensätze werden konvertiert.")
# Execute Catmandu
catmanduCommand = "catmandu convert MARC --type XML to CSV --fix da_fetch_mapping.fix --fields identifier.ppn,type,date.issued,title,part,\
title.alternative,identifier.isbn,relation.issn,relation.journalzdbid,relation.serieszdbid,contributor.author,contributor.editor,contributor.other,identifier,\
identifier.pi,rights.license,publisher,language.iso,subject.jel,description.version,relation.ispartofseries,relation.seriesppn,\
relation.ispartofjournal,relation.journalppn,relation.ispartofbook,relation.bookppn,econstor.citation.volume,econstor.citation.issue,econstor.citation.articlenumber,\
econstor.citation.startpage,econstor.citation.endpage,url,collection_handle,identifier.packageid,filepath,description.abstract,subject.ddc,subject.keyword \
--var target=\"{}\" --var isil=\"{}\" --sep_char '\t' < {} > records-{}.csv".format(target, isil, destinationXMLFile,file)
print(catmanduCommand)
subprocess.call(catmanduCommand, shell=True)

# TODO: move file to archives directory
