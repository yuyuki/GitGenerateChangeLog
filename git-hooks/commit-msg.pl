#!/usr/bin/env perl

## git changelog generator
## -----------------------
## Usage: GenerateChangeLog [commit hash]
## -----------------------
## Copyright : Jaufré Devosse
## License   : MIT
## -----------------------
## base on this convention : "AngularJS Git Commit Message Conventions" at https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit
## -----------------------

#####################################################################
########################## Configuration ##################################
#####################################################################

# Set types permit in commit message
@types = ("feat", "fix", "refactor","chore","test", "style", "doc");
# Set scopes permit in commit message
@scopes = ("core", "script", "framework", "solution");

#####################################################################
########################### Process #####################################
#####################################################################

$filename = ".git/COMMIT_EDITMSG";

open my $fh, '<', $filename or die "error opening $filename: $!";
my $data = do { local $/; <$fh> };

$data .= "\n";

$pattern = '\A(' . join("|", @types) . ') \((' . join("|", @scopes) . ')\):[^ ].{10,100}';

if ($data !~ m/$pattern/simg) {
	print("The commit message is not well formed.\n");
	print("It must be like this : \n");
	print("\t\ttype (scope):<subject>\n\t\t\n\t\t[body]\n\t\t\n\t\t[WorkItem : #XXXXX]");
	print("\n\nType can be : " . join(", ", @types));
	print("\nScope can be : " . join(", ", @scopes));
	print("\nSubject can not be longer than  100 characters!");
	print("\nBody & WorkItem are optional.\n\n");

	return false;
}