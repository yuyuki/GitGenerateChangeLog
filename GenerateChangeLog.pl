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

# Set key searched inside the commit message and set the label written in the Markdown
%types = ("feat" => "Features", "fix" => "Bug Fixes");

# Set the markdown style of every Tag found
$versionMd = "#";
# Set the markdown style of every types found
$titleMd = "##";
# Set the markdown style of every subject found
$enumMd = "-";

#####################################################################
######################### Global variable ##################################
#####################################################################
$stop  = $ARGV[0];
$prevTag = "";
@tagArray = ();
@tagDate = ();
$date = "";
@typeKeys = keys %types;

#####################################################################
########################### Function ####################################
#####################################################################

sub getTag {
	if (@_[0] =~ m/tag: (.*?)[,)]/s) {
		return $1;
	}
	return "";
}

sub initTag{		
		my $tag = $_[0];
				
		if($$tag eq ""){
			$$tag = $prevTag;
		}
				
		if($$tag eq ""){
			$prevTag = $$tag = "Last Release";
		}
}

sub saveTagData{
	if($prevTag ne ""){
		# Save Tag & Date
		push(@tagArray, $prevTag);
		push(@tagDate, $date);
			
		# push table inside tag array
		foreach $type (@typeKeys){
			if( scalar @{$type}){
				push(@{$prevTag.$type}, @{$type});
				undef(@{$type});
			}
		}
	}
}

#####################################################################
########################### Process #####################################
#####################################################################

@array = split(/#COMMIT#/, `git log --pretty=tformat:"#COMMIT#%+d%+cd%+H%n subject:%s%n body:%b%n" --date=short --decorate=short`);
$pattern = '(.*)\n(\d{4})-(\d{2})-(\d{2})\n(\w*)\n subject: *\((' . join("|", @typeKeys) . ')\) (.*?) : *(.*?)\n body:(.*?)';

foreach $line (@array){
	if ($line =~ m/$pattern/i) {
		# --------------------
		# Get Group values
		$tag = getTag($1);
		
		initTag(\$tag);
						
		$hash = $5;
		$type = lc $6;
		$scope = lc $7;
		$subjet = lc $8;
		$body = $9;
		# --------------------

		if($tag ne $prevTag){
			saveTagData();
			$prevTag = $tag;
			$date = "$4/$3/$2";
		}

		push(@{$type}, $subjet);
	}
	
	last if $hash eq $stop;
}

saveTagData();

for($i = 0; $i < @tagArray; $i++){
	$tag = @tagArray[$i];
	$date = @tagDate[$i];
	print("\n$versionMd Version : $tag ($date)\n");

	foreach $type (@typeKeys){
		@array = @{$tag.$type};
		if ( scalar @array){
			$type = ucfirst $types{$type};
			print("\n$titleMd$type\n$enumMd ");
			print(join("\n$enumMd ", @array));
			print("\n");
		}
	}
}