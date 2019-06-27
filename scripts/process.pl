#!perl

use JSON;
use Catmandu;
use Try::Tiny::ByClass;
use Data::Dumper;

my $oai_endpoint = shift or die "Usage: $0 OAI\n";

sub prepare {
	if (-e "/tmp/index.oai_raw.sqlite") {
		unlink "/tmp/index.oai_raw.sqlite";
	}

	my $store = Catmandu->store(
		'DBI',
		data_source => 'dbi:SQLite:/tmp/index.oai_raw.sqlite',
	);

	my $importer = Catmandu->importer(
		'OAI',
	     url => $oai_endpoint,
	     handler => 'raw',
	     metadataPrefix => 'oai_lido',	
	);

	$importer->each(sub {
		my $item = shift;
		my $bag = $store->bag();
		$bag->add($item);
	});
}

sub process {
	prepare();

	my $importer = Catmandu->importer('JSON', file => '/tmp/bulk.json');
	my $fixer = Catmandu->fixer(
		'lookup_in_store(raw, DBI, data_source: "dbi:SQLite:/tmp/index.oai_raw.sqlite")',
		'copy_field(raw._metadata, xml)',
		'remove_field(raw)'
	);

	my $exporter = Catmandu->exporter('JSON', pretty => 1);
	$exporter->add_many($fixer->fix($importer));
}

process();

