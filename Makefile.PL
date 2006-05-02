
# $Id: Makefile.PL,v 2.6 2006/05/02 12:14:37 Daddy Exp $

use inc::Module::Install;
name('WWW-Search-Jobs');
version(2.023);
author('Martin Thurn <mthurn@cpan.org>');
abstract('Query job-related web search engines');
license('perl');
requires(perl => 5.004);
requires('WWW::Search');

&WriteAll;
