#!/usr/bin/perl
################################################################################
# GADGETOPROMPT
# A really useless bash prompt generator the most likely only works on Linux and
# requires Perl.
################################################################################

# Have a look at README.md for some documentation
# Licensed under the WTFPL version 2, which should be in the LICENSE file.

use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use POSIX qw(strftime);
use Cwd;


# DEFAULT CONFIGURATION ====================================================={{{

our %CONFIG = (
	# CONFIGURATION
	# - Issue warnings about configuration files
	cfg_warn_files => 1 ,
	# - Allow overrides from environment
	cfg_from_env => 0 ,
	# - System theme dirs
	cfg_sys_themes => [ '/usr/share/gprompt/themes' ] ,
	# - User theme dirs
	cfg_user_themes => [ '.local/share/gprompt/themes' , '.gprompt-themes' ] ,
	# - Use tput sgr0 for resets
	cfg_sgr0_reset => 0 ,

	# LAYOUT
	# - Theme and local overrides
	layout_theme => '' ,
	layout_theme_overrides => {} ,
	# - Section generators for the left side of the top bar
	layout_left => [ ] ,
	# - Section generator for the central part of the top bar (undef if unused)
	layout_middle => '' ,
	# - Section generators for the right side of the top bar
	layout_right => [ ] ,
	# - Section generators for the input bar
	layout_input => [ qw( userhost cwd ) ] ,
	# - Always generate input line?
	layout_input_always => 0 ,

	# TERMINAL TITLE
	# - Set title from the prompt? 0=no, 1=normal, 2=minimized, 3=both
	term_set_title => 1 ,
	# - Generators to use
	term_generators => [ qw( userhost cwd ) ] ,
	# - Separator
	term_separator => ':' ,

	# CURRENT WORKING DIRECTORY
	# - Max width as a percentage of the terminal's width
	cwd_max_width => 50 ,

	# USER@HOST
	# - Display username? 0=no, 1=yes
	uh_username => 1 ,
	# - Display hostname? 0=no, 1=always, 2=remote only
	uh_hostname => 1 ,
	# - Display symbol for remote hosts?
	uh_remote => 0 ,

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
	pcmd_show_code => 2 ,
	# - Pad status code display? 0 = no, -1 = left aligned, 1 = right aligned
	pcmd_pad_code => 0 ,
	# Success/failure colors for 0=nothing, 1=symbol, 2=code, 3=both
	pcmd_colors => 1 ,

	# LOAD AVERAGE
	# - Minimal load average before the section is displayed
	load_min => 0 ,

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

# Default theme -------------------------------------------------------------{{{

sub default_theme
{
	return {
		# Padding character
		'padding' => ' ',

		# Extra colors for transition strings
		'transition' => [ 7 ] ,
		# Left side of top line
		'bg_left' => -2,
		'fg_left' => -2,
		'left_prefix' => '' ,
		'left_separator' => ' ' ,
		'left_suffix' => '\f2 | ' ,
		# Middle of top line
		'bg_middle' => -2,
		'fg_middle' => -2,
		'middle_prefix' => ' ',
		'middle_separator' => ' ',
		'middle_suffix' => ' ',
		# Right side of top line
		'bg_right' => -2,
		'fg_right' => -2,
		'right_prefix' => '\f2 | ' ,
		'right_separator' => ' ' ,
		'right_suffix' => '' ,
		# Input line
		'bg_input' => -2,
		'fg_input' => -2,
		'input_prefix' => '' ,
		'input_separator' => '\f2:' ,
		'input_suffix' => '\f2 ; ' ,
		# Secondary prompt
		'bg_ps2' => -2,
		ps2_suffix => ' : ' ,

		# Current working directory - Truncation string
		cwd_trunc => '...' ,
		# Current working directory - Foreground / background colors
		'cwd_fg_color' => 12 ,
		'cwd_bg_color' => -1 ,
		# Current working directory - Colors when directory is missing
		'cwd_missing_fg_color' => 1 ,
		'cwd_missing_bg_color' => -1 ,

		# User@host - Remote host symbol
		'uh_remote_symbol' => '(r)',
		# User@host - User - Foreground and background colors
		'uh_user_fg' => 10 ,
		'uh_user_bg' => -1 ,
		# User@host - Root - Foreground and background colors
		'uh_root_fg' => 9 ,
		'uh_root_bg' => -1 ,
		# User@host - Hostname and remote host color
		'uh_host_fg' => 10 ,

		# Date/time - Colors
		'dt_time_fg' => -1 ,
		'dt_date_fg' => -1 ,
		'dt_bg' => -1 ,

		# Previous command state - Symbols
		'pcmd_ok_sym' => 'O',
		'pcmd_err_sym' => 'X',
		# Previous command state - OK text / background color
		'pcmd_ok_fg' => -1 ,
		'pcmd_ok_bg' => -1 ,
		# Previous command state - Error text / background color
		'pcmd_err_fg' => -1 ,
		'pcmd_err_bg' => -1 ,
		# Previous command state - Other text foreground
		'pcmd_text_fg' => -1 ,

		# Load average - Symbol or text
		'load_title' => 'ld',
		# Load average - Low load colors
		'load_low_fg' => -1,
		'load_low_bg' => -1,
		# Load average - Medium load colors
		'load_med_fg' => -1 ,
		'load_med_bg' => -1 ,
		# Load average - High load colors
		'load_high_fg' => -1 ,
		'load_high_bg' => -1 ,

		# Git - Branch symbol
		'git_branch_symbol' => 'B ',
		# Git - Branch colors - No warning
		'git_branch_ok_bg' => -1 ,
		'git_branch_ok_fg' => -1 ,
		# Git - Branch colors - Weak warning
		'git_branch_warn_bg' => -1 ,
		'git_branch_warn_fg' => -1 ,
		# Git - Branch colors - Strong warning
		'git_branch_danger_bg' => -1 ,
		'git_branch_danger_fg' => -1 ,
		# Git - Repo state colors
		'git_repstate_bg' => -1 ,
		'git_repstate_fg' => -1 ,
		# Git - Padding character for status sections
		'git_status_pad' => '' ,
		# Git - Untracked symbol and colors
		'git_untracked_symbol' => 'U ',
		'git_untracked_bg' => -1 ,
		'git_untracked_normal_fg' => -1 ,
		'git_untracked_add_fg' => -1 ,
		'git_untracked_mod_fg' => -1 ,
		'git_untracked_del_fg' => -1 ,
		# Git - Indexed symbol and colors
		'git_indexed_symbol' => 'I ',
		'git_indexed_bg' => -1 ,
		'git_indexed_normal_fg' => -1 ,
		'git_indexed_add_fg' => -1 ,
		'git_indexed_mod_fg' => -1 ,
		'git_indexed_del_fg' => -1 ,
		# Git - Add/modify/delete symbols
		'git_add_symbol' => '+' ,
		'git_mod_symbol' => '~',
		'git_del_symbol' => '-',
		# Git stash symbol and color
		'git_stash_symbol' => 'S ',
		'git_stash_bg' => -1 ,
		'git_stash_fg' => -1 ,

		# Python virtual environment section colors
		'pyenv_fg' => -1,
		'pyenv_bg' => -1,
	};
}

# }}}
# }}}
# MAIN PROGRAM =============================================================={{{

our $HASCWD;
our $COLUMNS;
our $RESET;
our %TCCACHE = ();
our %TLEN = ();
our %SCACHE = ();
our %THEME = ();
our %STYLES = (
	none	=> '' ,
	b	    => 'bold' ,
	d	    => 'dim' ,
	u	    => 'smul' ,
	i	    => 'sitm' ,
	bu	    => 'bold,smul' ,
	iu	    => 'sitm,smul' ,
);

# Terminal commands ---------------------------------------------------------{{{

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

#}}}
# Theming support -----------------------------------------------------------{{{

sub thref($) { bless {r=>$_[0]}, 'ThemeRef'; }

sub TERM_DEFAULT()    { -2 }
sub SECTION_DEFAULT() { -1 }

sub load_theme
{
	my $theme = $CONFIG{layout_theme};
	return default_theme unless $theme;

	my $warn = $CONFIG{cfg_warn_files};
	my @tdirs = (
		( map { $ENV{HOME} . '/' . $_ } @{$CONFIG{cfg_user_themes}} ) ,
		@{$CONFIG{cfg_sys_themes}}
	);
	if ($CONFIG{cfg_from_env} && exists $ENV{GPROMPT_THEME_DIR}) {
		unshift @tdirs, $ENV{GPROMPT_THEME_DIR};
	}
	foreach my $dir ( @tdirs ) {
		my $path = "$dir/${theme}.pm";
		next unless -f $path;
		my $data = do $path;
		if ( $@ ) {
			warn "could not parse `$path': $@" if $warn;
		} elsif ( !defined $data ) {
			warn "could not do `$path': $!\n" if $warn;
		} elsif ( !$data ) {
			warn "could not run `$path'\n" if $warn;
		} elsif ( ref( $data ) ne 'HASH' ) {
			warn "`$path' does not contain a hash\n" if $warn;
		} else {
			return $data;
		}
	}

	return default_theme;
}

sub theme_resolve
{
	my ( $key , $stack ) = @_;

	$stack = {} unless defined $stack;
	if ( exists $stack->{ $key } ) {
		warn "inifinite loop in theme ($key)\n";
		return undef;
	}
	$stack->{ $key } = 1;
	
	my $value = $THEME{ $key };
	if ( ref( $value ) eq 'ThemeRef' ) {
		$THEME{ $key } = theme_resolve( $value->{r} );
		$value = $THEME{ $key };
	}

	return $value;
}

sub themed($)
{
	my $k = shift;
	unless ( %THEME ) {
		%THEME = ( %{ &load_theme } , %{ $CONFIG{layout_theme_overrides} } );
		my @to_resolve = grep { ref( $THEME{$_} ) eq 'ThemeRef' } keys %THEME;
		foreach my $k ( @to_resolve ) {
			theme_resolve( $k );
		}
	}
	return $THEME{ $k };
}

#}}}
# Rendering utilities -------------------------------------------------------{{{

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
	my $out = [ {style=>'none'} ];
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

sub gen_prompt_section
{
	my $section = shift;
	unless ( exists $SCACHE{ $section } ) {
		no strict 'refs';
		my $func = 'render_' . $section;
		$SCACHE{ $section } = [ &$func ];
	}
	return @{ $SCACHE{ $section } };
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

sub apply_style
{
	my ( $bg , $fg , $style ) = @_;
	my $out = $RESET;
	$out .= set_color( 'b' , $bg ) unless $bg == -2;
	$out .= set_color( 'f' , $fg ) unless $fg == -2;
	if ( $style ne 'none' ) {
		foreach my $ctrl ( split /,/, $STYLES{ $style } ) {
			$out .= tput_sequence( $ctrl );
		}
	}
	return $out;
}

sub render
{
	my $name = shift;

	my $out = '';
	my $mustSetFg = undef;
	my $mustSetBg = undef;
	my $mustSetStyle = undef;
	my $bgDefault = themed( 'bg_' . $name );
	my $fgDefault = themed( 'fg_' . $name );
	my ( $fg , $bg , $style ) = ( -2 , -2 , 'none' );
	foreach my $section ( @_ ) {
		$mustSetBg = $section->{bg} if exists $section->{bg};
		foreach my $part ( @{ $section->{content} } ) {
			if ( ref $part ) {
				$mustSetBg = $part->{bg} if exists $part->{bg};
				$mustSetFg = $part->{fg} if exists $part->{fg};
				$mustSetStyle = $part->{style} if exists $part->{style};
			} else {
				# Check background color changes
				if ( defined $mustSetBg ) {
					$mustSetBg = $bgDefault if $mustSetBg == -1;
					$mustSetBg = undef if $mustSetBg == $bg;
				}
				# Check foreground color changes
				if ( defined $mustSetFg ) {
					$mustSetFg = $fgDefault if $mustSetFg == -1;
					$mustSetFg = undef if $mustSetFg == $fg;
				}
				# Check style changes
				if ( defined( $mustSetStyle ) && ( $mustSetStyle eq $style
							|| !exists( $STYLES{ $style } ) ) ) {
					$mustSetStyle = undef;
				}
				# Change style and colors if necessary
				if ( defined( $mustSetBg ) || defined( $mustSetFg )
						|| defined( $mustSetStyle ) ) {
					if ( defined $mustSetBg ) {
						$bg = $mustSetBg;
						$mustSetBg = undef;
					}
					if ( defined $mustSetFg ) {
						$fg = $mustSetFg;
						$mustSetFg = undef;
					}
					if ( defined $mustSetStyle ) {
						$style = $mustSetStyle;
						$mustSetStyle = undef;
					}
					$out .= apply_style( $bg , $fg , $style );
				}
				$part =~ s/\\/\\\\/g;
				$part =~ s/"/\\\"/g;
				$out .= $part;
			}
		}
	}
	return $out;
}

#}}}
# Prompt parts --------------------------------------------------------------{{{

sub gen_top_line
{
	my @left = @{ $CONFIG{layout_left} };
	my @right = @{ $CONFIG{layout_right} };
	my $midGen = $CONFIG{layout_middle};
	return "" unless ( @left || @right || $midGen );

	# Generate content
	my @middle = ( );
	my $mc = themed 'bg_middle';
	@left = gen_prompt_sections( 0 , @left );
	if ( defined $midGen ) {
		@middle = ( gen_prompt_section( $midGen ) );
		if ( @middle ) {
			@middle = (
				add_transitions( 'middle' , themed( 'bg_left' ) ,
					themed( 'bg_right' ) , @middle )
			);
			foreach my $entry ( @middle ) {
				delete $entry->{bg};
			}
			unshift @middle , { bg => themed('bg_middle') };
		}
	}
	@right = gen_prompt_sections( 1 , @right );

	# Adapt to width
	my $len = get_length( ( @middle ) );
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
	$txt .= render( 'middle' , @middle , @mpad );
	$txt .= render( 'right' , add_transitions( 'right' , $mc , 0 , @right ) );
	return $txt . $RESET . "\\n";
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
		render( 'input' , add_transitions( 'input' , 0 , 0 , @input ) ) . $RESET
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
	return render( 'ps2' , @line ) . $RESET;
}

sub gen_term_title
{
	my @parts = @{ $CONFIG{term_generators} };
	return '' unless @parts && $CONFIG{term_set_title};
	@parts = gen_prompt_sections( 0 , @parts );
	my @str_parts = ();
	foreach my $part ( @parts ) {
		my $cur = '';
		foreach my $sub ( @{ $part->{content} } ) {
			next if ref $sub;
			$cur .= $sub;
		}
		$cur =~ s/[^\x20-\x7f]//g;
		push @str_parts , $cur if $cur;
	}
	return '' unless @str_parts;
	my $main = join( $CONFIG{term_separator} , @str_parts );
	my $out = '';
	$out .= "\\033]0;$main\\007" if $CONFIG{term_set_title} & 1;
	$out .= "\\033]1;$main\\007" if $CONFIG{term_set_title} & 2;
	$out = "\\[$out\\]" if $out;
	return $out;
}

#}}}
# Configuration loader ------------------------------------------------------{{{

sub get_config_overrides
{
	foreach my $k ( keys %CONFIG ) {
		next unless exists $ENV{ "GPROMPT_" . uc($k) };
		my $ev = $ENV{ "GPROMPT_" . uc($k) };
		next if $ev eq '';

		my $vt = ref $CONFIG{ $k };
		if ( !$vt ) {
			$CONFIG{ $k } = $ev;
		} elsif ( $vt eq 'ARRAY' ) {
			$CONFIG{ $k } = [ map {
					$_ =~ s/^\s+//; $_ =~ s/\s+$//; $_
				} ( split /,/ , $ev ) ];
		} elsif ( $vt eq 'HASH' ) {
			$CONFIG{ $k } = { map {
					$_ =~ s/^\s+//; $_ =~ s/\s+$//; split /:/ , $_ , 2
				} ( split /,/ , $ev ) };
		}
	}
}

sub load_config
{
	my @cfg_files = (
		'/etc/gprompt-defaults.rc' ,
		"$ENV{HOME}/.gprompt.rc"
	);
	foreach my $cfg_file ( @cfg_files ) {
		next unless -f $cfg_file;
		my $data = do $cfg_file;
		my $warn = $CONFIG{cfg_warn_files};
		if ( $@ ) {
			warn "could not parse `$cfg_file': $@" if $warn;
		} elsif ( !defined $data ) {
			warn "could not do `$cfg_file': $!\n" if $warn;
		} elsif ( !$data ) {
			warn "could not run `$cfg_file'\n" if $warn;
		} elsif ( ref( $data ) ne 'HASH' ) {
			warn "`$cfg_file' does not contain a hash\n" if $warn;
		} else {
			%CONFIG = ( %CONFIG , %$data );
		}
	}
	get_config_overrides if $CONFIG{cfg_from_env};
}

#}}}

sub main
{
	$HASCWD = defined( getcwd );
	chdir '/' unless $HASCWD;

	load_config;
	chop( $COLUMNS = `tput cols` );
	$RESET = $CONFIG{cfg_sgr0_reset} ? tput_sequence( 'sgr0' ) : "\033[0m";
	$RESET = '\\[' . $RESET . '\\]';
	%TLEN = compute_trans_lengths;
	my $pg = gen_term_title;
	my $ps1 = $pg . gen_top_line;
	my ( $ill , $ilt ) = gen_input_line;
	$ps1 .= $ilt;
	my $ps2 = $pg . gen_ps2( $ill );
	print "export PS1=\"$ps1\" PS2=\"$ps2\"\n";
}

main;

# }}}
# SECTION RENDERERS ========================================================={{{

# Date/time -----------------------------------------------------------------{{{

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

#}}}
# Current working directory -------------------------------------------------{{{

sub render_cwd
{
	my @out = ( );
	my $cwd = getcwd;
	my @cols;
	unless ( $HASCWD ) {
		@cols = map { themed $_ } qw(
				cwd_missing_bg_color cwd_missing_fg_color );
		push @out , {
			bg => $cols[0] ,
			content => [
				{
					fg => $cols[1] ,
					style => 'i' ,
				} ,
				'(no cwd)'
			] ,
		};
		return @out unless exists $ENV{PWD};
		$cwd = $ENV{PWD};
	} else {
		@cols = map { themed $_ } qw( cwd_bg_color cwd_fg_color );
		$cwd = getcwd;
	}

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

	push @out , {
		bg => $cols[0] ,
		content => [ {fg=>$cols[1]} , $dir ]
	};
	return @out;
}

# }}}
# User/Host -----------------------------------------------------------------{{{

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
			if ( exists($ENV{$ev}) && $ENV{$ev} ne '' ) {
				$is_remote = 1;
				last;
			}
		}
	}

	my @out = ();
	if ( $un ) {
		push @out , ( getpwuid( $< ) || '(?)' );
	}
	if ( $hn == 1 || ( $hn == 2 && $is_remote ) ) {
		push @out , { fg => themed 'uh_host_fg', style => 'd' };
		push @out , '@' if @out;
		push @out , hostname;
	}
	if ( $rm && $is_remote ) {
		push @out , {style => 'b'};
		push @out , ( themed 'uh_remote_symbol' );
	}
	return () unless @out;

	return {
		bg => themed( ( $> == 0 ) ? 'uh_root_bg' : 'uh_user_bg' ) ,
		content => [
			{ fg => themed( ( $> == 0 ) ? 'uh_root_fg' : 'uh_user_fg' ) } ,
			@out
		] ,
	};
}

# }}}
# Previous command state ----------------------------------------------------{{{

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
		@out = ( @out ,
			{
				fg => ( ( $cl & 1 ) != 0 ) ? $col : -1 ,
				style => 'b'
			} ,
			themed( $status == 0 ? 'pcmd_ok_sym' : 'pcmd_err_sym' ) ,
			{ style => 'none' } ,
		);
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

# }}}
# Load average --------------------------------------------------------------{{{

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

	return {
		bg => themed( 'load_' . $cat . '_bg' ) ,
		content => [
			{fg=>themed( 'load_' . $cat . '_fg' )},
			(themed 'load_title') ,
			{style=>'b'}, $load . '%' , {style=>'none'},
		]
	};
}

# }}}
# Git repository information ------------------------------------------------{{{

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
			themed( 'git_branch_symbol' ) ,
			{style=>'b'},
			$branch,
			{style=>'none'},
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
		'R.' => 4 ,
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
				{style=>'b'},
				@subsecs,
				{style=>'none'},
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
			themed('git_stash_symbol') ,
			{style=>'b'},
			$nl ,
			{style=>'none'},
		]
	};
}

sub render_git
{
	my @out = ( );
	return @out unless $HASCWD;
	system( 'git rev-parse --is-inside-work-tree >/dev/null 2>&1' );
	return @out if $? != 0;
	@out = ( @out , _render_git_branch , _render_git_repstate );
	@out = ( @out , _render_git_status ) if $CONFIG{git_show_status};
	@out = ( @out , _render_git_stash ) if $CONFIG{git_show_stash};
	return @out;
}

# }}}
# Python virtual environment ------------------------------------------------{{{

sub render_pyenv
{
	return () unless $ENV{VIRTUAL_ENV} || $ENV{CONDA_DEFAULT_ENV};
	my $env;
	if ( $ENV{VIRTUAL_ENV} ) {
		$env = $ENV{VIRTUAL_ENV};
	} else {
		$env = $ENV{CONDA_VIRTUAL_ENV};
	}
	$env =~ s!.*/!!;
	return {
		bg => themed 'pyenv_bg' ,
		content => [
			{fg=>themed 'pyenv_fg'} , 'PY:' ,
			{style=>'b'}, $env , {style=>'none'},
		] ,
	};
}

# }}}

# }}}
