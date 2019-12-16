#! /usr/bin/perl
use strict;
use warnings;
use Getopt::Std;
use LWP::Simple;

#Fehlermeldungen
my $USAGE = "...\n";
my $ERROR_NOPARAM = "Kein Parameter übergeben.\n";


my %option;     # Hash mit über Kommandozeile eingegebenen Suchbegriff
my $urlbegin = 'http://sru.gbv.de/opac-de-206?version=1.1&operation=searchRetrieve';    # URL-Beginn
my $urlend = '&maximumRecords=5&recordSchema=picaxml';                          # URL-Ende
# zwischen URL-Beginn und URL-Ende muessen Suchschlüssel und Suchbegriff eingebaut werden
my $request;    # SRU-Request
my $filename = "ppns.txt";
my $row;
my $i;

# den eingebebenen Wert = Suchbegriff in den Hash %option schreiben
getopts('p:l:', \%option);

# Request-URL zusammensetzen durch Einfuegen der Suchbegriffe
if (defined $option{p}) {
  $request = $urlbegin . "&query=pica.ppn%3D" . $option{p} . $urlend;
} elsif (defined $option{l}) {
  open (my $fh, "<:encoding(UTF-8)", $filename) or die "Konnte die Datei nicht öffnen.\n";
  while (my $row = <$fh>) {
    chomp $row;
    print "$row\n";
    for ($i = 0; $i <= $row; $i++) {
      $request = $urlbegin . "&query=pica.ppn%3D" . $row . $urlend;
    }
  }
} else {
  # Fehlerbhandlung
  die "\n", $ERROR_NOPARAM, "\n\n" , $USAGE, "\n";
}

$request =~ s/ /%20/g;
print "Request: ", $request ."\n";



# Anfrage an die SRU-Schnittstelle
sub SRU {
  my ($resultXml) = get($request);
  print $resultXml; # Aktivieren zum Debugging
#  open (fh, ">", "records.xml");
#  print fh $resultXml;
#  close (fh) or "Kann die Datei nicht schließen.\n";
}

&SRU();
