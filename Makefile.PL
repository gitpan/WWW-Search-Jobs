
# $Id: Makefile.PL,v 2.9 2007/06/11 22:13:26 Daddy Exp $

use inc::Module::Install;
name('WWW-Search-Jobs');
version(2.026);
author('Martin Thurn <mthurn@cpan.org>');
abstract('Query job-related web search engines');
license('perl');
requires(perl => 5.004);
requires('WWW::Search');

&WriteAll;

__END__
