## Usage
* Must be ran as an account with administrative rights

## Syntax
* perl macpasswdreset.pl

## How Does It Work?
This perl script will grab the names of users from the /Users/ directory. It will then prompt for the current administrators password and ask for the new password for all accounts on the machine.

It will then proceed to change every user's password to the new one. After that it will "expire" their password forcing the user to create a new one on sign in. In order to sign in and receive the new password prompt, users should type the new password supplied in the script.

The script will then perform the same tasks as above on the administrators account as well.