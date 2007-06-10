
# $Id: Makefile.PL,v 2.8 2007/06/10 01:07:00 Daddy Exp $

use inc::Module::Install;
name('WWW-Search-Jobs');
version(2.025);
author('Martin Thurn <mthurn@cpan.org>');
abstract('Query job-related web search engines');
license('perl');
requires(perl => 5.004);
requires('WWW::Search');

&WriteAll;

__END__
