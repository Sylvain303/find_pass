# find_pass
[password-store](https://www.passwordstore.org/) greper to search and find pass entry by filename pattern 

## Purpose

Manage a lot of password and some time having the fullpath to manage duplicate or rename.

It displays both `pass` argument prefixed with `#`, so you can copy-paste to `pass show` for example.
It also displays the fullpath, so you can also copy-paste  to `mv` for example.

The algorithm also automatically call `pass show -c` for copying the password to clipboard if it manages
to have only one result.

## Usage

~~~bash
./find_pass linkedin
/home/sylvain/.password-store/Perso/Sylvain/linkedin.gpg
#  Perso/Sylvain/linkedin
reading 'Perso/Sylvain/linkedin'
Copied Perso/Sylvain/linkedin to clipboard. Will clear in 45 seconds.
~~~

## hardcoded value

a user local tmp dir in `~/tmp` no created by the script

~~~bash
local tmp=~/tmp/find_pass.tmp
~~~

your password-store path

~~~bash
find ~/.password-store/ -type f \
~~~

