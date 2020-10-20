#!/usr/bin/perl
# SHINY PERL PROMPT, lol
# Use with : export PROMPT_COMMAND='eval "$(perl path/to/spp.pl $?)"'

use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use POSIX qw(strftime);

our %CONFIG = (
	# LAYOUT
	# - Theme and local overrides
	layout_theme => 'powerline_yb' ,
	layout_theme_overrides => {} ,
	# - Section generators for the left side of the top bar
	layout_left => [
		'datetime' ,
		'userhost' ,
		#'load' ,
		#'prevcmd' ,
		#'git' ,
	] ,
	# - Section generator for the central part of the top bar (undef if unused)
	layout_middle => 'cwd' ,
	# - Section generators for the right side of the top bar
	layout_right => [
		#'datetime' ,
		#'userhost' ,
		'load' ,
		#'prevcmd' ,
		'git' ,
	] ,
	# - Section generators for the input bar
	layout_input => [
		#'datetime' ,
		#'userhost' ,
		#'load' ,
		'prevcmd' ,
		#'git' ,
	] ,
	# - Always generate input line?
	layout_input_always => 0 ,

	# CURRENT WORKING DIRECTORY
	# - Max width as a percentage of the terminal's width
	cwd_max_width => 35 ,

	# USER@HOST
	# - Display username? 0=no, 1=yes
	uh_username => 1 ,
	# - Display hostname? 0=no, 1=always, 2=remote only
	uh_hostname => 2 ,
	# - Display symbol for remote hosts?
	uh_remote => 1 ,

	# DATE/TIME
	# - Display date?
	dt_show_date => 0 ,
	# - Display time?
	dt_show_time => 1 ,
	# - Date format
	dt_date_fmt => '%Y-%m-%d' ,
	# - Time format
	dt_time_fmt => '%H:%M' ,

	# PREVIOUS COMMAND STATE
	# - Display OK/failed symbol?
	pcmd_show_symbol => 1 ,
	# - Display status code? 0=no, 1=always, 2=on failure
	pcmd_show_code => 1 ,
	# - Pad status code display? 0 = no, -1 = left aligned, 1 = right aligned
	pcmd_pad_code => -1 ,
	# Success/failure colors for 0=nothing, 1=symbol, 2=code, 3=both
	pcmd_colors => 1 ,

	# LOAD AVERAGE
	# - Minimal load average before the section is displayed
	load_min => 13 ,

	# GIT
	# - Branches for which the prompt should emit a strong warning
	git_branch_danger => [ 'main' , 'master' ] ,
	# - Branches for which the prompt should emit a weak warning
	git_branch_warn => [ 'dev' , 'develop' ] ,
	# - Warning mode for detached heads (0=none, 1=weak, 2=strong)
	git_detached_warning => 2 ,
	# - Show git status?
	git_show_status => 1 ,
	# - Show git stash count?
	git_show_stash => 1 ,
);


#===============================================================================
# THEMES

our %THEMES = ();

sub thref { bless {(@_==2)?(t=>$_[0],r=>$_[1]):(r=>$_[0])}, 'ThemeRef'; }

# Powerline based, using yellow and blue
$THEMES{powerline_yb} = {
	# Padding character
	padding => ' ' ,
	# Left side of top line
	left_prefix => '\b1 ' ,
	left_separator => '\f0\b2\f2\b1' ,
	left_suffix => '\f0\b2\f2\b1 ' ,
	# Middle of top line
	middle_prefix => '' ,
	middle_separator => ' | ' ,
	middle_suffix => '' ,
	# Right side of top line
	right_prefix => '\f2\b0\f1\b2\b1' ,
	right_separator => '\f2\b0\f1\b2' ,
	right_suffix => '\b0 ' ,
	# Input line
	input_prefix => '\b1 ' ,
	input_separator => '\f0\b2\f2\b1' ,
	input_suffix => '\f0\b2\f2\b1 ' ,
	# Secondary prompt suffix
	ps2_suffix => '\f0\b2\f2\b1 ' ,

	# Color gradient to use
	bg0 => 21 , bg1 => 61 , bg2 => 143 , bg3 => 226 ,
	fg3 => 18 , fg2 => 21 , fg1 => 184 , fg0 => 226 ,
	# Default foreground color
	fg => 15 ,

	# Extra colors for transition strings
	transition => [ 233 ] ,
	# Default left side colors
	bg_left => 239 ,
	fg_left => thref( 'fg' ) ,
	# Default middle colors
	bg_middle => 235 ,
	fg_middle => thref( 'fg' ) ,
	# Default right side background color
	bg_right => thref( 'bg_left' ) ,
	fg_right => thref( 'fg' ) ,
	# Default input prompt background color
	bg_input => 238 ,
	fg_input => thref( 'fg' ) ,
	# Secondary prompt backaground
	bg_ps2 => 234 ,

	# Current working directory - Truncation string
	cwd_trunc => '…' ,
	# Current working directory - Foreground / background colors
	cwd_fg_color => -1 ,
	cwd_bg_color => -1 ,

	# User@host - Remote host symbol
	uh_remote_symbol => '↥' ,
	# User@host - User - Foreground and background colors
	uh_user_fg => thref( 'fg0' ) ,
	uh_user_bg => thref( 'bg0' ) ,
	# User@host - Root - Foreground and background colors
	uh_root_fg => thref( 'fg3' ) ,
	uh_root_bg => thref( 'bg3' ) ,

	# Date/time - Colors
	dt_time_fg => -1 ,
	dt_date_fg => -1 ,
	dt_bg => -1 ,

	# Previous command state - Symbols
	pcmd_ok_sym => '✓' ,
	pcmd_err_sym => '✗' ,
	# Previous command state - OK text / background color
	pcmd_ok_fg => thref( 'fg3' ) ,
	pcmd_ok_bg => -1 ,
	# Previous command state - Error text / background color
	pcmd_err_fg => thref( 'fg0' ) ,
	pcmd_err_bg => -1 ,
	# Previous command state - Other text foreground
	pcmd_text_fg => -1 ,

	# Load average - Symbol or text
	load_title => '↟' ,
	# Load average - Low load colors
	load_low_fg => -1 ,
	load_low_bg => -1 ,
	# Load average - Medium load colors
	load_med_fg => thref( 'fg1' ) ,
	load_med_bg => thref( 'bg1' ) ,
	# Load average - High load colors
	load_high_fg => thref( 'fg3' ) ,
	load_high_bg => thref( 'bg3' ) ,

	# Git - Branch symbol
	git_branch_symbol => ' ' ,
	# Git - Branch colors - No warning
	git_branch_ok_bg => thref( 'bg0' ) ,
	git_branch_ok_fg => thref( 'fg0' ) ,
	# Git - Branch colors - Weak warning
	git_branch_warn_bg => thref( 'bg2' ) ,
	git_branch_warn_fg => thref( 'fg2' ) ,
	# Git - Branch colors - Strong warning
	git_branch_danger_bg => thref( 'bg3' ) ,
	git_branch_danger_fg => 0 ,
	# Git - Repo state colors
	git_repstate_bg => thref( 'bg1' ) ,
	git_repstate_fg => thref( 'fg1' ) ,
	# Git - Padding character for status sections
	git_status_pad => '' ,
	# Git - Untracked symbol and colors
	git_untracked_symbol => '❄' ,
	git_untracked_bg => thref( 'bg3' ) ,
	git_untracked_normal_fg => thref( 'fg3' ) ,
	git_untracked_add_fg => thref( 'fg3' ) ,
	git_untracked_mod_fg => thref( 'fg3' ) ,
	git_untracked_del_fg => thref( 'fg3' ) ,
	# Git - Indexed symbol and colors
	git_indexed_symbol => '☰' ,
	git_indexed_bg => thref( 'bg2' ) ,
	git_indexed_normal_fg => thref( 'fg2' ) ,
	git_indexed_add_fg => thref( 'fg2' ) ,
	git_indexed_mod_fg => thref( 'fg2' ) ,
	git_indexed_del_fg => thref( 'fg2' ) ,
	# Git - Add/modify/delete symbols
	git_add_symbol => '+' ,
	git_mod_symbol => '±' ,
	git_del_symbol => '∅' ,
	# Git stash symbol and color
	git_stash_symbol => '‡' ,
	git_stash_bg => thref( 'bg1' ) ,
	git_stash_fg => thref( 'fg1' ) ,
};

#===============================================================================
# MAIN PROGRAM

chop( our $COLUMNS = `tput cols` );
our %TCCACHE = ();

sub tput_sequence
{
	my $args = shift;
	return $TCCACHE{ $args } if exists $TCCACHE{ $args };
	open( my $fh , "tput $args|" );
	my $value = <$fh>;
	close( $fh );
	return ( $TCCACHE{ $args } = "\\[$value\\]" );
}

sub set_color
{
	my ( $type , $index ) = @_;
	return tput_sequence( "seta$type $index" );
}

our $THEME = undef;
sub theme_resolve
{
	my ( $theme , $key ) = @_;
	my $value = $theme->{ $key };
	if ( ref( $value ) eq 'ThemeRef' ) {
		my $rt = exists( $value->{t} ) ? $THEMES{ $value->{t} } : $theme;
		$theme->{ $key } = theme_resolve( $rt , $value->{r} );
		$value = $theme->{ $key };
	}
	return $value;
}
sub themed($)
{
	my $k = shift;
	unless ( defined $THEME ) {
		$THEME = {
			%{ $THEMES{ $CONFIG{layout_theme} } } ,
			%{ $CONFIG{layout_theme_overrides} } ,
		};
		my @to_resolve = grep { ref($THEME->{$_}) eq 'ThemeRef' } keys %$THEME;
		foreach my $k ( @to_resolve ) {
			theme_resolve( $THEME , $k );
		}
	}
	return $THEME->{ $k };
}

sub get_section_length
{
	my $section = shift;
	my $len = 0;
	foreach my $item ( @{ $section->{content} } ) {
		next if ref $item;
		$len += length $item;
	}
	return $len;
}

sub get_length
{
	my $len = 0;
	foreach my $section ( @_ ) {
		$len += get_section_length( $section );
	}
	return $len;
}

sub gen_transition
{
	my $transition = shift;
	my @colors = ( @_ , @{ themed 'transition' } );
	my $state = 0;
	my $pc;
	my $out = [ ];
	foreach my $char ( split // , $transition ) {
		if ( $state == 1 ) {
			if ( $char eq 'f' || $char eq 'b' ) {
				$pc = $char;
				$state = 2;
			} else {
				$state = 0;
				push @$out , "\\$char";
			}
		} elsif ( $state == 2 ) {
			$char = '0' unless $char =~ /^\d$/;
			push @$out , { $pc . 'g' => $colors[ int($char) ] };
			$state = 0;
		} elsif ( $char eq '\\' ) {
			$state = 1;
		} else {
			push @$out , $char;
		}
	}
	return { content => $out };
}

sub compute_trans_lengths
{
	my %out = ();
	foreach my $side ( qw( left right input ) ) {
		foreach my $type ( qw( prefix separator suffix ) ) {
			my $k = $side . '_' . $type;
			$out{ $k } = get_section_length( gen_transition(
					themed $k , 1 , 2 ) );
		}
	}
	return %out;
}
our %TLEN = compute_trans_lengths;

sub gen_prompt_section
{
	no strict 'refs';
	my $section = shift;
	my $func = 'render_' . $section;
	return &$func( );
}

sub gen_prompt_sections
{
	my $reverse = shift;
	my @input = @_;
	@input = reverse @input if $reverse;
	my @output = ( );
	foreach my $section ( @input ) {
		my @section = gen_prompt_section( $section );
		@section = reverse @section if $reverse;
		@output = ( @output , @section );
	}
	return @output;
}

sub adapt_to_width
{
	my ( $length , $side , @input ) = @_;
	my $minTransLen = $TLEN{ $side . '_prefix' } + $TLEN{ $side . '_suffix' };
	my @output = ( );
	foreach my $section ( @input ) {
		my $slen = get_section_length( $section );
		my $rlen = $minTransLen
			+ scalar( @output ) * $TLEN{ $side . '_separator' };
		last if $$length + $slen + $rlen > $COLUMNS;
		push @output , $section;
		$$length += $slen;
	}
	if ( @output ) {
		$$length += $minTransLen
			+ ( scalar( @output ) - 1 ) * $TLEN{ $side . '_separator' };
	}
	return @output;
}

sub add_transitions
{
	my $name = shift;
	my $cBefore = shift;
	my $cAfter = shift;

	my $prefix = themed( $name . '_prefix' );
	my $separator = themed( $name . '_separator' );
	my $suffix = themed( $name . '_suffix' );
	my $bgDefault = themed( 'bg_' . $name );

	my $prevBg = undef;
	my $curBg = $cBefore;
	my @out = ( );
	foreach my $section ( @_ ) {
		$prevBg = $curBg;
		$curBg = ( exists $section->{bg} ) ? $section->{bg} : -1;
		$curBg = $bgDefault if $curBg < 0;
		my $trans = scalar(@out) ? $separator : $prefix;
		@out = ( @out ,
			gen_transition( $trans , $prevBg , $curBg ) ,
			$section ,
		);

	}
	@out = ( @out , gen_transition( $suffix , $curBg , $cAfter ) ) if @out;
	return @out;
}

sub render
{
	my $name = shift;

	my $out = '';
	my $mustSetFg = undef;
	my $mustSetBg = undef;
	my $bgDefault = themed( 'bg_' . $name );
	my $fgDefault = themed( 'fg_' . $name );
	foreach my $section ( @_ ) {
		$mustSetBg = $section->{bg} if exists $section->{bg};
		foreach my $part ( @{ $section->{content} } ) {
			if ( ref $part ) {
				$mustSetBg = $part->{bg} if exists $part->{bg};
				$mustSetFg = $part->{fg} if exists $part->{fg};
			} else {
				if ( defined $mustSetBg ) {
					$mustSetBg = $bgDefault if $mustSetBg < 0;
					$out .= set_color( 'b' , $mustSetBg );
				}
				if ( defined $mustSetFg ) {
					$mustSetFg = $fgDefault if $mustSetFg < 0;
					$out .= set_color( 'f' , $mustSetFg );
				}
				$part =~ s/\\/\\\\/g;
				$part =~ s/"/\\\"/g;
				$out .= $part;
				$mustSetBg = $mustSetFg = undef;
			}
		}
	}
	return $out;
}

sub gen_top_line
{
	my @left = @{ $CONFIG{layout_left} };
	my @right = @{ $CONFIG{layout_right} };
	my $midGen = $CONFIG{layout_middle};
	return "" unless ( @left || @right || defined( $midGen ) );

	# Generate content
	my ( @lm , @middle , @mr ) = ( );
	my $mc = themed 'bg_middle';
	@left = gen_prompt_sections( 0 , @left );
	if ( defined $midGen ) {
		@middle = ( gen_prompt_section( $midGen ) );
		if ( @middle ) {
			@lm = (
				gen_transition( themed('middle_prefix') , $mc , $mc ) ,
				{ bg => themed('bg_middle') } ,
			);
			@mr = gen_transition( themed('middle_suffix') , $mc , $mc );
			foreach my $entry ( @middle ) {
				delete $entry->{bg};
			}
		}
	}
	@right = gen_prompt_sections( 1 , @right );

	# Adapt to width
	my $len = get_length( ( @lm , @middle , @mr ) );
	@left = adapt_to_width( \$len , 'left' , @left );
	@right = reverse adapt_to_width( \$len , 'right' , reverse @right );

	# Prepare padding
	my @mpad = ();
	if ( $len < $COLUMNS ) {
		push @mpad , {
			content => [ themed('padding') x ( $COLUMNS - $len ) ]
		};
	}

	# Render
	my $txt = render( 'left' , add_transitions( 'left' , 0 , $mc , @left ) );
	$txt .= render( 'middle' , @lm , @middle , @mr , @mpad );
	$txt .= render( 'right' , add_transitions( 'right' , $mc , 0 , @right ) );
	return $txt . tput_sequence( 'sgr0' ) . "\\n";
}

sub gen_input_line
{
	my @input = @{ $CONFIG{layout_input} };
	return "" unless @input || $CONFIG{layout_input_always};
	my $len = 0;
	@input = adapt_to_width( \$len , 'input' ,
			gen_prompt_sections( 0 , @input ) );
	push @input , {content=>['']} unless @input;
	return ( $len ,
		render( 'input' , add_transitions( 'input' , 0 , 0 , @input ) )
			 . tput_sequence( 'sgr0' )
	);
}

sub gen_ps2
{
	my $ill = shift;
	my @line = gen_transition( themed('ps2_suffix') , themed('bg_ps2') , 0 );
	my $len = get_length( @line );
	if ( $len < $ill ) {
		unshift @line , {
			bg => themed('bg_ps2') ,
			content => [ ' ' x ( $ill - $len ) ]
		};
	}
	return render( 'ps2' , @line ) . tput_sequence( 'sgr0' );
}

my $ps1 = gen_top_line;
my ( $ill , $ilt ) = gen_input_line;
$ps1 .= $ilt;
my $ps2 = gen_ps2( $ill );
print "export PS1=\"$ps1\" PS2=\"$ps2\"\n";


#===============================================================================
# SECTION RENDERERS

#-------------------------------------------------------------------------------
# DATE/TIME

sub render_datetime
{
	my @cur_time = localtime time;
	my @out = ( );
	if ( $CONFIG{dt_show_date} ) {
		push @out , {fg=>themed 'dt_date_fg'};
		push @out , ( strftime $CONFIG{dt_date_fmt}, @cur_time )
	}
	if ( $CONFIG{dt_show_time} ) {
		push @out, ' ' if @out;
		push @out , {fg=>themed 'dt_time_fg'};
		push @out , ( strftime $CONFIG{dt_time_fmt}, @cur_time )
	}
	return { bg => themed 'dt_bg' , content => [@out] };
}

#-------------------------------------------------------------------------------
# Current working directory

sub render_cwd
{
	use Cwd;
	my $cwd = getcwd;

	( my $dir = $cwd ) =~ s!^.*/!!;
	my $max_len = int( $COLUMNS * $CONFIG{cwd_max_width} / 100 );
	$max_len = length( $dir ) if length( $dir ) > $max_len;

	( $dir = $cwd ) =~ s!^$ENV{HOME}(\z|/.*)$!~$1!;
	my $offset = length( $dir ) - $max_len;
	if ( $offset > 0 ) {
		$dir = substr $dir , $offset , $max_len;
		my $t = themed 'cwd_trunc';
		$dir =~ s!^[^/]*/!$t/!;
	}

	return {
		bg => themed 'cwd_bg_color' ,
		content => [ {fg=>themed 'cwd_fg_color'} , $dir ]
	};
}

#-------------------------------------------------------------------------------
# USER/HOST

sub render_userhost
{
	use Sys::Hostname;
	my ( $un , $hn , $rm ) = map {
			$CONFIG{"uh_$_"}
		} qw( username hostname remote );
	return () unless $un || $hn || $rm;

	my $is_remote = 0;
	if ( $hn == 2 || $CONFIG{uh_remote} ) {
		foreach my $ev ( qw( SSH_CLIENT SSH2_CLIENT SSH_TTY ) ) {
			if ( exists($ENV{$ev}) && $ENV{$ev} != '' ) {
				$is_remote = 1;
				last;
			}
		}
	}

	my $str = '';
	if ( $un ) {
		$str .= getlogin || getpwuid( $< ) || '(?)';
	}
	if ( $hn == 1 || ( $hn == 2 && $is_remote ) ) {
		$str .= '@' if $str;
		$str .= hostname;
	}
	if ( $rm && $is_remote ) {
		$str .= themed 'uh_remote_symbol';
	}
	return () unless $str;

	return {
		bg => themed( ( $> == 0 ) ? 'uh_root_bg' : 'uh_user_bg' ) ,
		content => [
			{ fg => themed( ( $> == 0 ) ? 'uh_root_fg' : 'uh_user_fg' ) } ,
			$str
		] ,
	};
}

#-------------------------------------------------------------------------------
# PREVIOUS COMMAND STATE

sub render_prevcmd
{
	my ( $ss , $sc , $pc , $cl ) = map {
			$CONFIG{ "pcmd_$_" }
		} qw( show_symbol show_code pad_code colors );
	my $status = scalar(@ARGV) ? $ARGV[0] : 255;
	$sc = ( $sc == 1 || ( $sc == 2 && $status ) );
	return () unless $sc || $ss;

	my $col = themed( ( $status == 0 ) ? 'pcmd_ok_fg' : 'pcmd_err_fg' );
	my @out = ();
	if ( $ss ) {
		push @out , { fg => ( ( $cl & 1 ) != 0 ) ? $col : -1 };
		push @out , themed( ( $status == 0 ) ? 'pcmd_ok_sym' : 'pcmd_err_sym' );
	}
	if ( $sc ) {
		push @out , ' ' if @out;
		push @out , { fg => ( ( ( $cl & 2 ) != 0 ) ? $col : -1 ) };
		if ( $pc ) {
			my $str = sprintf '%' . ( $pc * 3 ) . 's' , $status;
			my $pad = themed 'padding';
			$str =~ s/ /$pad/g;
			push @out , $str;
		} else {
			push @out , $status;
		}
	}

	return {
		bg => themed( ( $status == 0 ) ? 'pcmd_ok_bg' : 'pcmd_err_bg' ) ,
		content => [ @out ] ,
	};
}

#-------------------------------------------------------------------------------
# LOAD AVERAGE

sub render_load
{
	my $ncpu;
	if ( open( my $fh , '</proc/cpuinfo' ) ) {
		while ( my $l = <$fh> ) {
			$ncpu++ if $l =~ /^[Pp]rocessor/;
		}
		close $fh;
	} else {
		$ncpu = 1;
	}

	my $load;
	return () unless open( my $fh , '/proc/loadavg' );
	chop( $load = <$fh> );
	close $fh;
	$load =~ s/ .*$//;
	$load = int( $load * 100 / $ncpu );
	return () if $load < $CONFIG{load_min};

	my $cat;
	if ( $load < 34 ) {
		$cat = 'low';
	} elsif ( $load < 68 ) {
		$cat = 'med';
	} else {
		$cat = 'high';
	}

	$load = (themed 'load_title') . $load . '%';
	return {
		bg => themed( 'load_' . $cat . '_bg' ) ,
		content => [ {fg=>themed( 'load_' . $cat . '_fg' )}, $load ]
	};
}

#-------------------------------------------------------------------------------
# GIT REPOSITORY INFORMATION

sub _render_git_branch
{
	# Get branch and associated warning level
	chop( my $branch = `git symbolic-ref -q HEAD` );
	my $detached = ( $? != 0 );
	my $branch_warning;
	if ( $detached ) {
		chop( $branch = `git rev-parse --short -q HEAD` );
		$branch = "($branch)";
		$branch_warning = $CONFIG{git_detached_warning};
	} else {
		$branch =~ s!^refs/heads/!!;
		my %branch_tab = (
			( map { $_ => 1 } @{ $CONFIG{git_branch_warn} } ) ,
			( map { $_ => 2 } @{ $CONFIG{git_branch_danger} } ) ,
		);
		#use Data::Dumper; print STDERR Dumper( \%branch_tab );
		$branch_warning = exists( $branch_tab{ $branch } )
				? $branch_tab{ $branch } : 0;
	}
	$branch_warning = qw(ok warn danger)[ $branch_warning ];
	return {
		bg => themed( 'git_branch_' . $branch_warning . '_bg' ) ,
		content => [
			{fg => themed( 'git_branch_' . $branch_warning . '_fg' )} ,
			themed( 'git_branch_symbol' ) . $branch
		]
	};
}

sub _render_git_repstate
{
	return () unless open( my $fh ,
			'git rev-parse --git-dir --is-inside-git-dir '
			. '--is-bare-repository 2>/dev/null|' );
	chop( my $gd = <$fh> );
	chop( my $igd = <$fh> );
	chop( my $bare = <$fh> );

	my $str = undef;
	if ( $bare eq 'true' ) {
		$str = 'bare';
	} elsif ( $igd eq 'true' ) {
		$str = 'in git dir';
	} else {
		if ( -f "$gd/MERGE_HEAD" ) {
			$str = 'merge';
		} elsif ( -d "$gd/rebase-apply" || -d "$gd/rebase-merge" ) {
			$str = 'rebase';
		} elsif ( -f "$gd/CHERRY_PICK_HEAD" ) {
			$str = 'cherry-pick';
		}
	}
	return () unless defined $str;
	return {
		bg => themed 'git_repstate_bg' ,
		content => [
			{fg=>themed 'git_repstate_fg'},
			$str
		]
	};
}

sub _render_git_status
{
	# Read status information
	my %parts = (
		'\?\?' => 0 ,
		'.M' => 1 ,
		'.D' => 2 ,
		'A.' => 3 ,
		'M.' => 4 ,
		'D.' => 5 ,
	);
	my @counters = ( 0 ) x 6;
	if ( open( my $fh , 'git status --porcelain 2>/dev/null |' ) ) {
		while ( my $line = <$fh> ) {
			my $sol = substr $line , 0 , 2;
			foreach my $re ( keys %parts ) {
				$counters[ $parts{ $re } ] ++
					if $sol =~ /^$re$/;
			}
		}
		close $fh;
	}

	# Generate status sections
	my @sec_names = ( 'untracked' , 'indexed' );
	my @sec_parts = ( 'normal' , 'add' , 'mod' , 'del' );
	my @part_syms = map { themed( 'git_' . $_ . '_symbol' ) } @sec_parts[1..3];
	my $pad = themed( 'git_status_pad' );
	my @out = ();
	foreach my $sidx ( 0..1 ) {
		my $pidx0 = $sidx * 3;
		next unless $counters[ $pidx0 ]
				|| $counters[ $pidx0 + 1 ]
				|| $counters[ $pidx0 + 2 ];

		my $sec_name = $sec_names[ $sidx ];
		my @fg = map {
				themed( 'git_' . $sec_name . '_' . $_ . '_fg' )
			} @sec_parts;
		my @subsecs = ();
		foreach my $i ( 0..2 ) {
			next unless $counters[ $pidx0 + $i ];
			@subsecs = ( @subsecs ,
				{fg=>$fg[ $i + 1 ]} ,
				$pad . $part_syms[ $i ] ,
				{fg=>$fg[ 0 ]} ,
				$counters[ $pidx0 + $i ]
			);
		}
		push @out , {
			bg => themed( 'git_' . $sec_name . '_bg' ) ,
			content => [
				{fg=>$fg[0]} ,
				themed( 'git_' . $sec_name . '_symbol' ) ,
				@subsecs
			]
		};
	}

	return @out,
}

sub _render_git_stash
{
	return () unless open( my $fh , 'git stash list 2>/dev/null|' );
	my @lines = grep { $_ =~ /^stash/ } <$fh>;
	close( $fh );

	my $nl = scalar( @lines );
	return () unless $nl;
	return {
		bg => themed('git_stash_bg') ,
		content => [
			{fg=>themed('git_stash_fg')} ,
			themed('git_stash_symbol') . $nl
		]
	};
}

sub render_git
{
	my @out = ( );
	system( 'git rev-parse --is-inside-work-tree >/dev/null 2>&1' );
	return @out if $? != 0;
	@out = ( @out , _render_git_branch , _render_git_repstate );
	@out = ( @out , _render_git_status ) if $CONFIG{git_show_status};
	@out = ( @out , _render_git_stash ) if $CONFIG{git_show_stash};
	return @out;
}
