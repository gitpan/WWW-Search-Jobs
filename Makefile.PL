
# $Id: Makefile.PL,v 2.10 2008/02/01 02:53:56 Daddy Exp $

use inc::Module::Install;
name('WWW-Search-Jobs');
version(2.027);
author('Martin Thurn <mthurn@cpan.org>');
abstract('Query job-related web search engines');
license('perl');
requires(perl => 5.004);

build_requires('ExtUtils::testlib');
requires('HTML::TokeParser');
requires('HTTP::Request::Common');
build_requires('Test::More');
build_recommends('Test::Pod');
requires('WWW::Search');
requires('WWW::SearchResult');

WriteAll();

__END__
