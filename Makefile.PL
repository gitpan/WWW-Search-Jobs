
# $Id: Makefile.PL,v 2.5 2006/02/23 02:53:18 Daddy Exp $

use inc::Module::Install;
name('WWW-Search-Jobs');
version(2.022);
author('Martin Thurn <mthurn@cpan.org>');
abstract('Query job-related web search engines');
license('perl');
requires(perl => 5.004);
requires('WWW::Search');

&WriteAll;
