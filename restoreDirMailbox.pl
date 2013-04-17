#!/usr/bin/perl -w
use strict;


####### MAIN ##########

my $account = shift;
my $backupId = shift;
my $backupIdFull ='';
my (@listedir) = @ARGV;


checkParam();
restoreAccountBak();

foreach (@listedir){
	saveDirAccountBak($_);
	restoreDirAccount($_);
}

delAccountBak();


#Full backup for an account
#zmbackup -f - demo1.domain.com -a guest@demo1.domain.com

#Restore
#zmrestore -a $account -lb $backupIdFULL -ca -pre bak_
#zmrestore -a $account  -restoreToIncrLabel $backupId -lb $backupIdFull -br -ca -pre bak_

#Create directory into inbox
#zmmailbox -z -m guest@demo1.domain.com cf /inbox/Rep

#Rename directory
#zmmailbox -z -m bak_guest@demo1.domain.com rf /inbox/toto/foo /inbox/toto/foo_bak

##############################



#Check script parameters
sub checkParam{
	if(($account && $account =~ /^[^ ]+@[^ ]+$/) && (!$backupId) ){
		print `zmbackupquery -a $account`;
		exit 0;
	}
	
	if(($account && $account =~ /^[^ ]+@[^ ]+$/) && ($backupId && $backupId =~ /^(full|incr)[^ ]+$/) && (@listedir && $#listedir >= 0)){
		if ($backupId =~ /^incr[^ ]+$/){
			my @query = `zmbackupquery -a $account`;
			my $flag = 0;
			foreach (@query){
				$flag = 1 if $_ =~ /^[ ]+Label:[ ]+$backupId/;
				if($_ =~ /^[ ]+Label:[ ]+(full.*)/ && $flag eq 1){
					$backupIdFull = $1;
					chomp($backupIdFull);
					last;
				}
			}
			if(!$backupIdFull || $backupIdFull eq ''){
				echo_red("backup full non trouvé");
				exit 0;
			}
		}
		return 1;
	}
	
	echo_white("$0 <user\@domain.com> <LabelBackup> <dir/subdir...>");
	echo_blue("\t<dir/subdir> : For a directory into \"Boite de Reception\" you have to prefix with ",1); echo_red("inbox/",1); echo_blue(" example inbox/dir/sudir");
	exit 0;
}


### restore account to bak_compte
sub restoreAccountBak{
	echo_green("restoreAccountBak $account --> bak_$account");
#	print "zmrestore -a $account -ca -pre bak_\n";

	if($backupIdFull eq ''){
		print `zmrestore -a $account -lb $backupId -ca -pre bak_`;
	}else{
		print `zmrestore -a $account  -restoreToIncrLabel $backupId -lb $backupIdFull -br -ca -pre bak_`;
	}
}


### Backup account directory in /tmp
sub saveDirAccountBak{
	my $dir = shift;
	echo_green("saveDirAccountBak - $dir");


#	print `zmmailbox -z -m bak_$account rf /inbox/$dir /inbox/$dir\_bak`;
	print `zmmailbox -z -m bak_$account rf "/$dir" "/$dir\_bak"`;
#	print `zmmailbox -z -m bak_$account getRestURL "/inbox/$dir\_bak?fmt=zip" > /tmp/$account.zip`;
	print `zmmailbox -z -m bak_$account getRestURL "/$dir\_bak?fmt=zip" > /tmp/$account.zip`;
}

### Restore directory in rep_bak
sub restoreDirAccount{
	my $dir = shift;
	echo_green("restoreDirAccount - $dir");
#	print "zmmailbox -z -m $account postRestURL \"/?fmt=zip\" /tmp/$account.zip\n"; 
	print `zmmailbox -z -m $account postRestURL "/?fmt=zip" /tmp/$account.zip`;
}

### Delete account_bak
sub delAccountBak{
	echo_green("delAccountBak - bak_$account");
#	print "zmprov da bak_$account\n"; 
	print `zmprov da bak_$account`;
}



sub echo_red {
    print defined($_[1]) ? "\033[0;31m$_[0]\033[0;37m" : "\033[0;31m$_[0]\033[0;37m\n";
}

sub echo_green {
    print defined($_[1]) ? "\033[0;32m$_[0]\033[0;37m" : "\033[0;32m$_[0]\033[0;37m\n";
}
     
sub echo_yellow {
    print defined($_[1]) ? "\033[0;33m$_[0]\033[0;37m" : "\033[0;33m$_[0]\033[0;37m\n";
}
     
sub echo_blue {
    print defined($_[1]) ? "\033[0;34m$_[0]\033[0;37m" : "\033[0;34m$_[0]\033[0;37m\n";
}

sub echo_pink {
    print defined($_[1]) ? "\033[0;35m$_[0]\033[0;37m" : "\033[0;35m$_[0]\033[0;37m\n";
}

sub echo_cyan {
    print defined($_[1]) ? "\033[0;36m$_[0]\033[0;37m" : "\033[0;36m$_[0]\033[0;37m\n";
}

sub echo_white {
	print defined($_[1]) ? "\033[0;37m$_[0]\033[0;37m" : "\033[0;37m$_[0]\033[0;37m\n";
}

sub echo_grey {
	print defined($_[1]) ? "\033[1;30m$_[0]\033[0;37m" : "\033[1;30m$_[0]\033[0;37m\n";
}
