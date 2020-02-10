
#
#$Id$#
use utf8;
use LWP;
use LWP::UserAgent;
use URI::Escape;
use JSON::XS;


#buzz
# shard urls
#my $shard_urls = [
#		  'http://solr-sdr-dev:8111/solr/core-1x',
#		  'http://solr-sdr-dev:8111/solr/core-2x'
#		 ];

#production

# single shard
my $shard_urls =['http://solr-sdr-search-1:8081/solr/core-1x'];

# my $shard_urls =[
		 
# 		 'http://solr-sdr-search-1:8081/solr/core-1x',
# 		 'http://solr-sdr-search-2:8081/solr/core-2x',
# 		 'http://solr-sdr-search-3:8081/solr/core-3x',
# 		 'http://solr-sdr-search-4:8081/solr/core-4x',
# 		 'http://solr-sdr-search-5:8081/solr/core-5x',
# 		 'http://solr-sdr-search-6:8081/solr/core-6x',
# 		 'http://solr-sdr-search-7:8081/solr/core-7x',
# 		 'http://solr-sdr-search-8:8081/solr/core-8x',
# 		 'http://solr-sdr-search-9:8081/solr/core-9x',
# 		 'http://solr-sdr-search-10:8081/solr/core-10x',
# 		 'http://solr-sdr-search-11:8081/solr/core-11x',
# 		 'http://solr-sdr-search-12:8081/solr/core-12x'
# 		];


my $query = '*%3A*';

my $rest='/export?';

#$rest .= '&fq=language008_full:("Armenian" OR "Persian")';

my $fields='id_dv';
my $sort_field='id_dv';
my $dir ='desc';

$ua = LWP::UserAgent->new;
$ua->agent("SolrTester ");

my $url;
foreach  my $shard_url (@{$shard_urls})
{
    print STDERR "shard $shard_url\n";
    $url = $shard_url . $rest . '&q=' . $query .  '&fl=' . $fields .  '&sort=' . $sort_field . '+' . $dir;
    print STDERR "$url\n";
    get_ids($url);    
}


#----------------------------------------------------------------------
sub get_ids
{
    my $url = shift;
     
    print STDERR "debug $url\n";

    my $res = $ua->get($url);
    
#    my $res = $ua->post($url);

    if ($res->is_success) 
    {
        print STDERR "got  records\n";
        
        my $content= $res->content;    
	my $parsed = parse_JSON_results(\$content);

#{"responseHeader":{"status":0},"response":{"numFound":3185,"docs":[{"id_dv":"aeu.ark:/13960/t9184k94v"}
	my $num_found = $parsed->{'response'}->{'numFound'};
	$n_found = commify($num_found);    
	print STDERR "$n_found results\n";
	#output_ids($parsed);
	output_fields($parsed);
    }
    else 
    {
        print $res->status_line, "\n";
        print STDERR $res->status_line, "\n";
    }
}

#----------------------------------------------------------------------
sub output_ids
{
    my $json = shift;
    my $ary=$json->{response}->{docs};
    
    foreach my $hash (@{$ary})
    {
	my $id =$hash->{'id_dv'};
	print "$id\n";
    }
}
	
#----------------------------------------------------------------------
sub output_fields
{
    my $json = shift;
    my $ary=$json->{response}->{docs};
    
    foreach my $hash (@{$ary})
    {
	my $id =$hash->{'id_dv'};
	print "$id\n";
    }
}
	
	
# ---------------------------------------------------------------------
sub parse_JSON_results
{   

    my $ref = shift;

    # Warning json won't escape xml entities such as "&" ">" etc.
    my $coder = JSON::XS->new->utf8->pretty->allow_nonref;
    my $parsed = $coder->decode ($$ref);
    
    return $parsed;
    
}
# ---------------------------------------------------------------------
sub commify {
    my $text = reverse $_[0];       
    $text =~s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text
}



