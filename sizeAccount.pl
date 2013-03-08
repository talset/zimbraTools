#!/usr/bin/perl

# Author: Florian Lambert <florian.lambert@digitalshot.fr>

# Find instantly account size with mysql size_checkpoint
# You have to fix the following variables if necessary
#
#HOW TO :
#
#ssh zimbra@domain.com
# su - zimbra
# ./sizeAccount.pl 

use DBI;

######## VARIABLES ######################
my $database="zimbra";
my $hostname="localhost";
my $port = "7306";
my $login = "zimbra";
my $mdp = $1 if `zmlocalconfig --show zimbra_mysql_password` =~ /= (.*)/;
my $mdpldap = $1 if `zmlocalconfig --show zimbra_ldap_password` =~ /= (.*)/;
my $hostldap = $1 if `zmlocalconfig --show ldap_host` =~ /= (.*)/;;
#########################################

my $dsn = "DBI:mysql:database=$database;host=$hostname;port=$port;mysql_socket=/opt/zimbra/db/mysql.sock";
my $connect = DBI->connect($dsn, $login, $mdp) or die "Echec connexion";

my $requete = "SELECT account_id,size_checkpoint from mailbox;";

my $res = $connect->prepare($requete);                             
$res->execute();

my %sortaccount;
while(my @row = $res->fetchrow_array){
	$sortaccount{$row[0]} = $row[1];
}


$res -> finish;
$connect -> disconnect;


##Use ldap to find Display Name
use Net::LDAP;

my $ldap = Net::LDAP->new(
           "$hostldap",
           port => "389",
           version => 3,
           timeout => 60, 
           );  

my $mesg = $ldap->bind ( "uid=zimbra,cn=admins,cn=zimbra", password => "$mdpldap" );
$mesg->code && die $mesg->error;

$mesg = $ldap->search(
        base   => '', 
        scope  => 'subtree',
        filter => '(objectClass=zimbraAccount)',
        attrs  => [ qw( uid displayName zimbraId zimbraMailDeliveryAddress ) ]
);

$mesg->code && die $mesg->error;

$ldap->unbind();
my %accountinfo;

foreach my $entry ($mesg->all_entries) {
                my $uid = $entry->get_value('uid');
                my $zimbraId = $entry->get_value('zimbraId');
                my $displayName = $entry->get_value('displayName');
                my $mail = $entry->get_value('zimbraMailDeliveryAddress');

	    	if($sortaccount{$zimbraId}){
			$accountinfo{$zimbraId} =  "$mail;$displayName";
		}

}

$ldap->unbind();

foreach my $key (sort {$sortaccount{$a} <=> $sortaccount{$b} } keys %sortaccount){
	my $sizeMB  = sprintf("%.1f", $sortaccount{$key}/1024/1024);
	print "$accountinfo{$key};$sizeMB MB\n"
}
