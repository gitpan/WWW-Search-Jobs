use ExtUtils::MakeMaker;
WriteMakefile(
              'NAME'	=> 'WWW::Search::Jobs',
              'VERSION' => 2.01,
              'PREREQ_PM' => {
                              'WWW::Search::Scraper' => 0,
                             },
             );
