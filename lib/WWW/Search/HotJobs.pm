#!/usr/local/bin/perl -w

#
# AltaVista.pm
# by John Heidemann
# Copyright (C) 1996-1998 by USC/ISI
# $Id: AltaVista.pm,v 1.8 2000/08/08 16:48:51 mthurn Exp $
#
# Complete copyright notice follows below.
#


package WWW::Search::HotJobs;

=head1 NAME

WWW::Search::HotJobs - class for searching HotJobs


=head1 SYNOPSIS

    require WWW::Search;
    $search = new WWW::Search('HotJobs');


=head1 DESCRIPTION

This class is an HotJobs specialization of WWW::Search.
It handles making and interpreting HotJobs searches
F<http://www.HotJobs.com>.

This class exports no public interface; all interaction should
be done through WWW::Search objects.


=head1 OPTIONS

None at this time (2001.04.25)

=over 8

=item search_url=URL

Specifies who to query with the HotJobs protocol.
The default is at
C<http://www.HotJobs.com/cgi-bin/job-search>.

=item search_debug, search_parse_debug, search_ref
Specified at L<WWW::Search>.

=back


=head1 SEE ALSO

To make new back-ends, see L<WWW::Search>,
or the specialized HotJobs searches described in options.


=head1 HOW DOES IT WORK?

C<native_setup_search> is called before we do anything.
It initializes our private variables (which all begin with underscores)
and sets up a URL to the first results page in C<{_next_url}>.

C<native_retrieve_some> is called (from C<WWW::Search::retrieve_some>)
whenever more hits are needed.  It calls the LWP library
to fetch the page specified by C<{_next_url}>.
It parses this page, appending any search hits it finds to 
C<{cache}>.  If it finds a ``next'' button in the text,
it sets C<{_next_url}> to point to the page for the next
set of results, otherwise it sets it to undef to indicate we're done.


=head1 AUTHOR and CURRENT VERSION

C<WWW::Search::HotJobs> is written and maintained
by Glenn Wood, <glenwood@dnai.com>.

The best place to obtain C<WWW::Search::HotJobs>
is from Martin Thurn's WWW::Search releases on CPAN.
Because HotJobs sometimes changes its format
in between his releases, sometimes more up-to-date versions
can be found at
F<http://alumni.caltech.edu/~glenwood/SOFTWARE/WWW_SEARCH_HotJobs/index.html>.


=head1 COPYRIGHT

Copyright (c) 2001 Glenn Wood
All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

--------------------------
             
Search.pm and Search::AltaVista.pm (of which HotJobs.pm is a derivative)
is Copyright (c) 1996-1998 University of Southern California.
All rights reserved.                                            

Redistribution and use in source and binary forms are permitted
provided that the above copyright notice and this paragraph are
duplicated in all such forms and that any documentation, advertising
materials, and other materials related to such distribution and use
acknowledge that the software was developed by the University of
Southern California, Information Sciences Institute.  The name of the
University may not be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.


=cut



#####################################################################

require Exporter;
@EXPORT = qw();
@EXPORT_OK = qw();
@ISA = qw(WWW::Search::Scraper Exporter);
$VERSION = '1.01';
#'

use Carp ();
use WWW::Search::Scraper(qw(generic_option addURL trimAdmClutter));
require WWW::SearchResult;

use strict;

sub undef_to_emptystring {
    return defined($_[0]) ? $_[0] : "";
}


# HotJobs JobSearch submission form . . . 
# <FORM METHOD="post" ACTION="/cgi-bin/job-search" onSubmit="return setJobType(this, this.hjax)">  
#<FONT SIZE="3" FACE="Arial" COLOR="#0166CA"><B>Refine Search</B></FONT><BR>
#<NOBR><INPUT TYPE=TEXT NAME=KEYWORDS SIZE=25 MAXLENGTH=64 VALUE="Perl Java">
#<INPUT TYPE=SUBMIT VALUE="Search"></NOBR>
#<INPUT TYPE=HIDDEN NAME=ERROR_TEMPLATE VALUE="/htdocs/channels/tech/job-search-page-error-tech.html">
#<INPUT TYPE=HIDDEN NAME=NULL_TEMPLATE VALUE="/htdocs/channels/tech/refine-search-null-tech.html">
#<INPUT TYPE="hidden" NAME="J__CITY" VALUE="">
#<INPUT TYPE="hidden" NAME="J__STATE" VALUE="">
#<INPUT TYPE="hidden" NAME="JOBSPERPAGE" VALUE="20">
#<INPUT TYPE=HIDDEN NAME=COMPANY VALUE="">
#<INPUT TYPE="hidden" NAME="J__MTIME_DAYSAGO" VALUE="">
#<INPUT TYPE="hidden" NAME="SORT" VALUE="MTIME">
#<INPUT TYPE="hidden" NAME="TEMPLATE" VALUE="/htdocs/channels/tech/job-search-tech.html">
#<INPUT TYPE="hidden" NAME="INDUSTRY" VALUE="MIS">	
#<INPUT TYPE="hidden" NAME="PARSE_NO_NULL" VALUE="1">
#<INPUT TYPE=HIDDEN NAME="J__POSITION" VALUE="">
#<INPUT TYPE=HIDDEN NAME="METROAREA" VALUE="1">
#<INPUT TYPE=HIDDEN NAME="AX_JOBS" VALUE="">
#<INPUT TYPE=HIDDEN NAME="HJ_JOBS" VALUE="">
#<INPUT TYPE=HIDDEN NAME=J__FUNCTION VALUE="MIS-CONSU">

#<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0">
#<TR>
#<TD colspan="6"><font face="Arial" size="2">Include jobs from:</font></TD>
#</TR>
#<TR>
#   <TD><INPUT TYPE=RADIO VALUE="3" NAME="hjax" checked>&nbsp;</TD><TD><a href="javascript:popupWindow('/htdocs/employer-search-firm-popup.html','450','420','0');" class=BLACK2>Employers and<BR>Search Firms</a></TD>
#   <TD><INPUT TYPE=RADIO VALUE="1" NAME="hjax" >&nbsp;</TD><TD><a href="javascript:popupWindow('/htdocs/employer-popup.html','450','200','0');" class=BLACK2>Employers<BR> Only</a></TD>
#   <TD><INPUT TYPE=RADIO VALUE="2" NAME="hjax" >&nbsp;</TD><TD><a href="javascript:popupWindow('/htdocs/search-firm-popup.html','450','200','0');" class=BLACK2>Search<BR> Firms Only</a></TD>
# </TR>
#</TABLE><BR>
# Input TEXT NAME="KEYWORDS", VALUE=string of keywords
# Input HIDDEN J__CITY, J__STATE, JOBSPERPAGE, COMPANY, J__MTIME_DAYSAGO, SORT=MTIME, INDUSTRY=MIS(?), PARSE_NO_NULL=1, 
#     METROAREA=1, AX_JOBS, HJ_JOBS, J__FUNCTION=MIS-CONSU
# Radio Button NAME="hjax", VALUE=(1,2,3)
# </FORM>


=head1 XML Scaffolding

Look at the idea from the perspective of the XML "scaffold" I'm suggesting for parsing the response HTML.

(This is XML, but looks superficially like HTML)

<HTML>
<BODY>
        <TABLE NAME="name" or NUMBER="number">
                <TR TYPE="header"/>
                        <TR TYPE = "detail*">
                        <TD BIND="title" />
                        <TD BIND="description" />
                        <TD BIND="location" />
                        <TD BIND="url" PARSE="anchor" />
                </TR>
        </TABLE>
</BODY>
</HTML>

This scaffold describes the relevant skeleton of an HTML document; there's HTML and BODY elements, of course.
Then the <TABLE> entry tells our parser to skip to the TABLE in the HTML named "name", or skip "number" TABLE entries
(default=0, to pick up first TABLE element.)
Then the TABLE is described. The first <TR> is described as a "header" row. 
The parser throws that one away. The second <TR> is a "detail" row (the "*" means multiple detail rows, of course). 
The parser picks up each <TD> element, extracts it's content, and places that in the hash entry corresponding to its 
BIND= attribute. Thus, the first TD goes into $result->_elem('title')
(I needed to learn to use LWP::MemberMixin. Thanks, another lesson learned!)  
The second TD goes into $result->_elem('description'), etc. 
(Of course, some of these are _elem_array, but these details will be resolved later). 
The PARSE= in the url TD suggests a way for our parser to do special handling of a data element.
The generic scaffold parser would take this XML and convert it to a hash/array to be processed at run time;
we wouldn't actually use XML at run time. A backend author would use that hash/array in his native_setup_search() code,
calling the "scaffolder" scanner with that hash as a parameter.

As I said, this works great if the response is TABLE structured,
but I haven't seen any responses that aren't that way already.

This converts to an array tree that looks like this:

    my $scaffold = [ 'HTML', 
                     [ [ 'BODY', 
                       [ [ 'TABLE', 'name' ,                  # or 'name' = undef; multiple <TABLE number=n> mean n 'TABLE's here ,
                         [ [ 'NEXT', 1, 'NEXT &gt;' ] ,       # meaning how to find the NEXT button.
                           [ 'TR', 1 ] ,                      # meaning "header".
                           [ 'TR', 2 ,                        # meaning "detail*"
                             [ [ 'TD', 1, 'title' ] ,         # meaning clear text binding to _elem('title').
                               [ 'TD', 1, 'description' ] ,
                               [ 'TD', 1, 'location' ] ,
                               [ 'TD', 2, 'url' ]             # meaning anchor parsed text binding to _elem('title').
                             ]
                         ] ]
                       ] ]
                     ] ]
                  ];
 

=cut                     

# private
sub native_setup_search
{
    my($self, $native_query, $native_options_ref) = @_;
    $self->user_agent('user');
    $self->{_next_to_retrieve} = 0;
    if (!defined($self->{_options})) {
	$self->{_options} = {
	    'hjax' => '3',
	    'ERROR_TEMPLATE' => '/htdocs/channels/tech/job-search-page-error-tech.html',
	    'NULL_TEMPLATE' => '/htdocs/channels/tech/refine-search-null-tech.html',
	    'J__CITY' => '',
	    'J__STATE' => '',
	    'JOBSPERPAGE' => '20',
	    'COMPANY' => '',
	    'J__MTIME_DAYSAGO' => '',
	    'SORT' => 'MTIME',
	    'TEMPLATE' => '/htdocs/channels/tech/job-search-tech.html',
	    'INDUSTRY' => 'MIS',
	    'PARSE_NO_NULL' => '1',
	    'METROAREA' => '1',
	    'AX_JOBS' => '',
	    'HJ_JOBS' => '',
	    'J__FUNCTION' => 'MIS-CONSU',
	    'search_url' => 'http://www.hotjobs.com/cgi-bin/job-search'
        };
    };
    $self->{'_http_method'} => 'POST';
    $self->{'_options'}{'scrapeFrame'} = 
       [ 'HTML', 
         [ [ 'BODY', 'Your search yielded the following', '' , # Make the parsing easier for scrapeTable() by stripping off the adminstrative clutter.
           [ [ 'TABLE', '#2' ,                     # or 'name' = undef; multiple <TABLE number=n> means n 'TABLE's here ,
             [ [ 'NEXT', 1, 'NEXT &gt;' ] ,        # meaning how to find the NEXT button.
               [ 'TR' ] ,                          # meaning nonsense data row (in this case "header").
               [ 'HIT*' ,                          # meaning the content of this array element represents hits!
                  [ [ 'TR',                             # meaning "detail*"
                      [
                        [ 'TD', 'number' ] ,            # meaning clear text binding to _elem('title').
                        [ 'TD', 'title', \&addURL ] ,   # meaning that the job description link is here, 
                        [ 'TD', 'nonsense' ] ,          #    with the title as its hypertext.
                        [ 'TD', 'description' ] ,
                      ]
                    ] ,
                    [ 'TR' ,                            # meaning "detail*"
                      [
                        [ 'TD', 'unknown' ] ,           # 
                        [ 'TD', 'unknown' ] ,           #
                        [ 'TD', 'unknown' ] ,
                        [ 'TD', 'location' ] ,
                      ]
                  ] ]
               ]
             ] 
         ] ]
         ] ]
      ];

 
    my($options_ref) = $self->{_options};
    if (defined($native_options_ref)) {
	# Copy in new options.
	foreach (keys %$native_options_ref) {
	    $options_ref->{$_} = $native_options_ref->{$_};
	};
    };
    # Process the options.
    # (Now in sorted order for consistency regarless of hash ordering.)
    my($options) = '';
    foreach (sort keys %$options_ref) {
	# printf STDERR "option: $_ is " . $options_ref->{$_} . "\n";
	next if (generic_option($_));
	$options .= $_ . '=' . $options_ref->{$_} . '&';
    };
    $self->{_debug} = $options_ref->{'search_debug'};
    $self->{_debug} = 2 if ($options_ref->{'search_parse_debug'});
    $self->{_debug} = 0 if (!defined($self->{_debug}));
    
    # Finally figure out the url.
    $self->{_base_url} = 
	$self->{_next_url} =
	$self->{_options}{'search_url'} .
	"?" . $options .
	"KEYWORDS=" . $native_query;
    print STDERR $self->{_base_url} . "\n" if ($self->{_debug});
}

1;
