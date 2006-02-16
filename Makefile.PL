
# $Id: Makefile.PL,v 2.4 2006/02/16 02:22:24 Daddy Exp $

use inc::Module::Install;
name('WWW-Search-Jobs');
version(2.021);
author('Martin Thurn <mthurn@cpan.org>');
abstract('Query job-related web search engines');
license('perl');
requires(perl => 5.004);
requires('WWW::Search');

&WriteAll;
