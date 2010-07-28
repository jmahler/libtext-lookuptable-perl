use ExtUtils::MakeMaker;

WriteMakefile(
	NAME		=> 'Text::LookUpTable',
	VERSION_FROM => 'lib/Text/LookUpTable.pm',
	AUTHOR => 'Jeremiah Mahler <jmmahler@gmail.com>',
	PREREQ_PM => {
		"Text::Aligner" => 0.01,
		"File::Slurp" => 0,
	},
);
