#!/usr/bin/perl
use warnings;
use strict;

#################################
#								#
# Filename: macpasswdreset.pl	#
# Author: Adam Luvshis			#
# Designed for: RIT ITS Resnet	#
# Usage: macpasswdreset.pl		#
# Date: September 16,2015		#
# Version: 1.1	 				#
#################################

=pod
	Change Notes:
		-v1.1
			* Removed contact address
			* Changed backtick calls to use file handles
=cut


print "Grabbing list of users to change passwords for...\n";

##################
#	Variables	 #
##################
my $current_dir;
my @dir_list = ("/Users");
my @user_list = ();
my @users;

#####################

#The code between the WHILE loop opens up the /Users/ directory and checks to see if
#all the contents are directories. If it is a directory, check to see if the
#directory is not "/Users/.", "/Users/..", "/Users/localized", "/Users/Shared"
#If it is not any of those directories, strip off the /Users/ and then add it
#to an array to hold all of the available users on the machine
while(@dir_list != 0) {
	$current_dir = $dir_list[0]; #Current directroy = /Users/
	opendir(DIR, $current_dir); #Open the /Users/ directory
	shift(@dir_list); #remove the folder from the array so the while loop stops
	@users = map{"$current_dir/$_"}readdir(DIR); #Contains an array of ALL user folders
	if(@users != 0) { 
		foreach my $user(@users) {
			if(-d $user) {
				if($user !~ m/\/Users\/Shared/ && $user !~ m/\/Users\/\./) {
					if($user =~ m/\/Users\//) {
						$user =~ s/\/Users\///;
						push(@user_list,$user);	
					}
				}
			}	
		}	
	}
}

my $num_users = scalar(@user_list); #Get the number of users total
print "User list obtained. Total of $num_users user(s)\n";

#############################
#	Password Managemenet	#
#############################

#Enter the admin's password for the CURRENT account, used later as an authenticator
print "Please enter the current admin's password: ";
my $current_pass = <STDIN>;
chomp($current_pass);

#Enter the ticket number for the password twice
print "Please enter the new password: ";
my $new_pass = <STDIN>;
chomp($new_pass);

print "Please re-enter the new password: ";
my $new_pass_ver = <STDIN>;
chomp($new_pass_ver);


#Check to make sure the two passwords enter match. If not, ask to be re-entered
while(1) {
	if($new_pass eq $new_pass_ver) {
		last;	
	}	
	elsif($new_pass ne $new_pass_ver) {
		print "\n\nPasswords did not match. Re-enter them\n";
		print "Please enter the new password: ";
		$new_pass = <STDIN>;
		chomp($new_pass);
		
		print "Please re-enter the new password: ";
		$new_pass_ver = <STDIN>;
		chomp($new_pass_ver);			
	}
}

#################################
#		Account Management		#
#################################

my $auth_acc = `whoami`; #Grabs username of current admin account (should be logged in as this user)
chomp($auth_acc);

print "Changing and \"expiring\" users passwords\n";

#Lets make it so next time they sign in, requests new password -> See comments below this
#Loop through each user EXCEPT the AUTHENTICATOR ACCOUNT (LOCAL ADMIN) since it needs to be used to 
#change everyone elses password. Set the password to the new desired password. Then expire the password
#making a prompt come up next time they sign in to change the password
for(my $i = 0; $i < $num_users; $i++) {
	if($auth_acc ne $user_list[$i]) { #Do not reset password of the auth account now
		print "Currently changing and expiring $user_list[$i]s account\n";
		open(SET_PASSWORD, "pwpolicy -a \"$auth_acc\" -p \"$current_pass\" -u \"$user_list[$i]\" -setpassword \"$new_pass\" 2>&1 |") or die("$!");
		while(my $line = <SET_PASSWORD) {
			print $line;
		}
		close(SET_PASSWORD)

		open(EXPIRE_PASSWORD, "pwpolicy -a \"$auth_acc\" -p \"$current_pass\" -u \"$user_list[$i]\" -setpolicy newPasswordRequired=1 2>&1 |") or die("$!");
		while(my $line = <EXPIRE_PASSWIRD) {
			print $line;
		}
		close(EXPIRE_PASSWORD)
		sleep(1);
	}
}

#Great! We reset everyone's info but the current user we are logged in as. Let's change their 
#password and expire the account
open(SET_ADMIN_PASSWORD, "pwpolicy -a \"$auth_acc\" -p \"$current_pass\" -u \"$auth_acc\" -setpassword \"$new_pass\" 2>&1 |") or die("$!");
while(my $line = <SET_ADMIN_PASSWORD) {
	print $line;
}
close(SET_PASSWORD)

open(EXPIRE_ADMIN_PASSWORD, "pwpolicy -a \"$auth_acc\" -p \"$new_pass\" -u \"$auth_acc\" -setpolicy newPasswordRequired=1 2>&1 |") or die("$!");
while(my $line = <EXPIRE_PASSWIRD) {
	print $line;
}
close(EXPIRE_ADMIN_PASSWORD)

print "Password \"expiration\" complete. Next time user signs in password will need to be changed\n";
