
# $Id: Makefile.PL,v 2.7 2007/06/10 00:18:43 Daddy Exp $

use inc::Module::Install;
name('WWW-Search-Jobs');
version(2.024);
author('Martin Thurn <mthurn@cpan.org>');
abstract('Query job-related web search engines');
license('perl');
requires(perl => 5.004);
requires('WWW::Search');

&WriteAll;

__END__
