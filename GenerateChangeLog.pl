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
				#print("push : $prevTag.$type : @{$type}\n");
				push(@{$prevTag.$type}, @{$type});
				undef(@{$type});
			}
		}
	}
}

#####################################################################
########################### Process #####################################
#####################################################################

print "Git changelog generator\n";
print "-----------------------\n";

my $result = `git log --pretty=tformat:"#COMMIT#%+d%+cd%+H%n subject:%s%n body:%b%n" --date=short --decorate=short`;
@array = split(/#COMMIT#/, $result);
$patternGlobal = '(.*?)\n(\d{4})-(\d{2})-(\d{2})\n(\w*)\n subject:\s*(.*?)\n';
#$patternMsg = '(' . join("|", @typeKeys) . ')\s*\((.*?)\)\s*:\s*(.*?)\n body:(.*?)';
$patternMsg = '^(' . join("|", @typeKeys) . ')\s*\((.*?)\)\s*:\s*(.*)';

foreach $line (@array){
	if ($line =~ m/$patternGlobal/i) {
		# --------------------
		# Get Group values
		$tag = getTag($1);
		initTag(\$tag);
		$hash = $5;
		
		if($tag ne $prevTag){
			# #print("Tag : $tag\n");
			saveTagData();
			$prevTag = $tag;
			$date = "$4/$3/$2";
		}
		
		# $tmp = $6;		
		if ($6 =~ m/$patternMsg/i) {
			# #print("6: $tmp\n");
			# #print("good : $1, $2, $3\n");
			$type = lc $1;
			$scope = lc $2;
			$subjet = lc $3;
			
			push(@{$type}, $subjet);
		}
	}
	
	if($stop){
		last if $hash eq $stop;
	}
}

saveTagData();

for($i = 0; $i < @tagArray; $i++){
	$tag = @tagArray[$i];
	$date = @tagDate[$i];
	print("\n$versionMd Version : $tag ($date)\n");

	foreach $type (@typeKeys){
		@array = @{$tag.$type};
		#print("$tag, $type : @array\n");
		if ( scalar @array){
			$typeName = ucfirst $types{$type};
			print("\n$titleMd$typeName\n$enumMd ");
			print(join("\n$enumMd ", @array));
			print("\n");
		}
	}
}