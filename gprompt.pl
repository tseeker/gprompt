#!/usr/bin/perl
################################################################################
# GADGETOPROMPT
# A really useless bash prompt generator that most likely only works on Linux
# and requires Perl.
################################################################################

# Have a look at README.md for some documentation
# Licensed under the WTFPL version 2, which should be in the LICENSE file.

use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use POSIX qw(strftime :termios_h);
use Cwd qw(abs_path getcwd);


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
	# - Add an empty line before the prompt? 0=no, 1=always, 2=not at the top
	# of the terminal, 3=only if the previous command didn't finish with \n
	layout_empty_line => 3 ,

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

	# JOBS
	# - Always display?
	jobs_always => 0 ,

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

	# PYTHON
	# - Display Python version (0=no, 1=if venv is set, 2=always)
	pyenv_py_version => 1 ,
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

		# Text appended to a line without EOL when layout_empty_line is 3
		'noeol_text' => '<NO EOL>' ,
		# Colors and style for the above text
		'noeol_fg' => 1 ,
		'noeol_bg' => -1 ,
		'noeol_style' => 'b' ,

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

		# Job count - Prefix and suffix text
		'jobs_prefix' => '&' ,
		'jobs_suffix' => '',
		# Job count - Background color
		'jobs_bg' => -1 ,
		# Job count - Style and foreground color for the job count
		'jobs_count_style' => 'b' ,
		'jobs_count_fg' => -1 ,
		# Job count - Style and foreground color for the prefix
		'jobs_prefix_style' => '' ,
		'jobs_prefix_fg' => -1 ,
		# Job count - Style and foreground color for the suffix
		'jobs_suffix_style' => '' ,
		'jobs_suffix_fg' => -1 ,

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
		'pyenv_text' => 'PY:',
		'pyenv_sep' => '/',
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
our %INPUT = ();
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

sub flush_term_and_read_pos($)
{
	my $ttyIn = shift;
	my ($input, $col, $line) = ("", "", "");
	my @pending = ();
	my $state = 0;
	while (sysread $ttyIn, $input, 1) {
		if ($state == 0) {
			if ($input eq "\033") {
				$state = 1;
			} else {
				push @pending, $input;
			}
		} elsif ($state == 1) {
			$state = 2 if $input eq '[';
		} elsif ($state == 2) {
			if ($input eq ';') {
				$state = 3;
			} else {
				$line .= $input;
			}
		} elsif ($state == 3) {
			last if $input eq 'R';
			$col .= $input;
		}
	}
	return $col, $line, @pending;
}

sub get_cursor_pos
{
	local $| = 1;
	open(my $ttyIn, '<:bytes' , '/dev/tty');
	open(my $ttyOut, '>:bytes' , '/dev/tty');

	# Enable raw mode
	my $term = POSIX::Termios->new;
	my $ttyInFd = fileno $ttyIn;
	$term->getattr($ttyInFd);
	my $oTerm = $term ->getlflag;
	$term->setlflag($oTerm & ~( ECHO | ECHOK | ICANON ));
	$term->setcc(VTIME, 1);
	$term->setattr($ttyInFd, TCSANOW);

	# Read position
	syswrite $ttyOut, "\033[6n", 4;
	my ($col, $line, @pending) = flush_term_and_read_pos $ttyIn;

	# Restore input using TIOCSTI (0x5412)
	foreach my $pByte (@pending) {
		ioctl $ttyIn, 0x5412, $pByte;
	}
	# Enable cooked mode
	$term->setlflag($oTerm);
	$term->setcc(VTIME, 0);
	$term->setattr($ttyInFd, TCSANOW);

	close $ttyIn;
	close $ttyOut;

	return $line, $col;
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
		%THEME = (
			%{ &default_theme } ,
			%{ &load_theme } ,
			%{ $CONFIG{layout_theme_overrides} }
		);
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
	my ( $state , $section ) = @_;
	unless ( exists $state->{ $section } ) {
		no strict 'refs';
		my $sFunc = 'readstate_' . $section;
		$state->{ $section } = &$sFunc;
	}
	unless ( exists $SCACHE{ $section } ) {
		no strict 'refs';
		my $rFunc = 'render_' . $section;
		$SCACHE{ $section } = [ &$rFunc( $state->{ $section } ) ];
	}
	return @{ $SCACHE{ $section } };
}

sub gen_prompt_sections
{
	my ( $state , $reverse , @input ) = @_;
	@input = reverse @input if $reverse;
	my @output = ( );
	foreach my $section ( @input ) {
		my @section = gen_prompt_section( $state , $section );
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

sub gen_empty_line
{
	my $lel = $CONFIG{layout_empty_line};
	my $nl;
	my $out = "";
	if ($lel > 1) {
		my ($line, $col) = get_cursor_pos;
		$nl = ( $lel == 2 && $line != 1 ) || ( $lel == 3 && $col != 1 );
		if ( $lel == 3 && $col != 1 ) {
			$out .= render('input', {
				content => [
					{
						style => themed 'noeol_style' ,
						fg => themed 'noeol_fg' ,
						bg => themed 'noeol_bg' ,
					},
					( themed 'noeol_text' )
				]
			});
		}
	} else {
		$nl = $lel
	}
	$out .= "\\n" if $nl;
	return $out;
}

sub gen_top_line
{
	my $state = shift;
	my @left = @{ $CONFIG{layout_left} };
	my @right = @{ $CONFIG{layout_right} };
	my $midGen = $CONFIG{layout_middle};
	return "" unless ( @left || @right || $midGen );

	# Generate content
	my @middle = ( );
	my $mc = themed 'bg_middle';
	@left = gen_prompt_sections( $state , 0 , @left );
	if ( defined $midGen ) {
		@middle = ( gen_prompt_section( $state , $midGen ) );
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
	@right = gen_prompt_sections( $state , 1 , @right );

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
	my $state = shift;
	my @input = @{ $CONFIG{layout_input} };
	return "" unless @input || $CONFIG{layout_input_always};
	my $len = 0;
	@input = adapt_to_width( \$len , 'input' ,
			gen_prompt_sections( $state , 0 , @input ) );
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
	my $state = shift;
	my @parts = @{ $CONFIG{term_generators} };
	return '' unless @parts && $CONFIG{term_set_title};
	@parts = gen_prompt_sections( $state , 0 , @parts );
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

sub printBashInit
{
	my $gpPath = abs_path($0);
	print <<"EOF";
_gprompt_set_return() {
	return "\${1:-0}"
}
gprompt_command() {
	_GPROMPT_PREV_STATUS=\$?
	local jobs=(\$(jobs -p))
	eval "\$_GPROMPT_PREVIOUS_PCMD"
	eval "\$( perl \Q$gpPath\E "rc:\$_GPROMPT_PREV_STATUS" "jobs:\${#jobs[@]}" )"
	_gprompt_set_return "\$_GPROMPT_PREV_STATUS"
}
_gprompt_clear() {
	clear -x
	_gprompt_set_return "\${_GPROMPT_PREV_STATUS:-0}"
	gprompt_command
	echo -n "\${PS1\@P}\r"
}
shopt -s checkwinsize
if [[ \$PROMPT_COMMAND != *"gprompt_command"* ]]; then
	_GPROMPT_PREVIOUS_PCMD="\$PROMPT_COMMAND"
	PROMPT_COMMAND="gprompt_command"
fi
bind -x \$'"\\C-l":_gprompt_clear'
EOF
	exit 0;
}

sub readArguments
{
	printBashInit if @ARGV == 1 && $ARGV[0] eq 'init';
	if (@ARGV == 1 && $ARGV[0] =~ /^\d+$/) {
		# Backward compatibility
		$INPUT{rc} = $ARGV[0];
	} else {
		foreach my $arg (@ARGV) {
			next unless $arg =~ /^([a-z]+):(.*)$/;
			$INPUT{$1} = $2;
		}
	}
}

sub main
{
	readArguments;

	$HASCWD = defined( getcwd );
	chdir '/' unless $HASCWD;

	load_config;
	chop( $COLUMNS = `tput cols` );
	$RESET = $CONFIG{cfg_sgr0_reset} ? tput_sequence( 'sgr0' ) : "\033[0m";
	$RESET = '\\[' . $RESET . '\\]';
	%TLEN = compute_trans_lengths;
	my $state = {};
	my $pg = gen_term_title( $state );
	my $ps1 = $pg;
	$ps1 .= gen_empty_line( $state );
	$ps1 .= gen_top_line( $state );
	my ( $ill , $ilt ) = gen_input_line( $state );
	$ps1 .= $ilt;
	my $ps2 = $pg . gen_ps2( $ill );
	print "export PS1=\"$ps1\" PS2=\"$ps2\"\n";
}

main;

# }}}
# SECTION RENDERERS ========================================================={{{

# Date/time -----------------------------------------------------------------{{{

sub readstate_datetime
{
	my @cur_time = localtime time;
	return { t => [@cur_time] };
}

sub render_datetime
{
	my $state = shift;
	my @cur_time = @{ $state->{t} };
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

sub readstate_cwd
{
	my $state = { exists=> $HASCWD };
	$state->{home} = $ENV{HOME} if exists $ENV{HOME};
	if ($HASCWD) {
		$state->{cwd} = getcwd;
	} elsif (exists $ENV{PWD}) {
		$state->{cwd} = $ENV{PWD};
	}
	return $state;
}

sub render_cwd
{
	my $state = shift;
	my @out = ( );
	my @cols;
	unless ( $state->{exists} ) {
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
		return @out unless exists $state->{cwd};
	} else {
		@cols = map { themed $_ } qw( cwd_bg_color cwd_fg_color );
	}

	my $cwd = $state->{cwd};
	( my $dir = $cwd ) =~ s!^.*/!!;
	if (exists $state->{home}) {
		my $home = $state->{home};
		( $dir = $cwd ) =~ s!^\Q$home\E(\z|/.*)$!~$1!;
	}

	my $max_len = int( $COLUMNS * $CONFIG{cwd_max_width} / 100 );
	$max_len = length( $dir ) if length( $dir ) > $max_len;
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

sub readstate_userhost
{
	my $is_remote = 0;
	foreach my $ev ( qw( SSH_CLIENT SSH2_CLIENT SSH_TTY ) ) {
		if ( exists($ENV{$ev}) && $ENV{$ev} ne '' ) {
			$is_remote = 1;
			last;
		}
	}

	use Sys::Hostname;
	return {
		rmt => $is_remote ,
		user => ( getpwuid( $< ) || '(?)' ) ,
		host => hostname
	}
}

sub render_userhost
{
	my $state = shift;
	my ( $un , $hn , $rm ) = map {
			$CONFIG{"uh_$_"}
		} qw( username hostname remote );
	return () unless $un || $hn || $rm;

	my @out = ();
	if ( $un ) {
		push @out , $state->{user};
	}
	if ( $hn == 1 || ( $hn == 2 && $state->{rmt} ) ) {
		push @out , { fg => themed 'uh_host_fg', style => 'd' };
		push @out , '@' if @out;
		push @out , $state->{host};
	}
	if ( $rm && $state->{rmt} ) {
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

sub readstate_prevcmd
{
	return { rc => $INPUT{rc} };
}

sub render_prevcmd
{
	my $state = shift;
	my ( $ss , $sc , $pc , $cl ) = map {
			$CONFIG{ "pcmd_$_" }
		} qw( show_symbol show_code pad_code colors );
	return () unless exists $state->{rc};
	my $status = $state->{rc};
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

sub readstate_load
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

	return $load;
}

sub render_load
{
	my $load = shift;
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
# Jobs ----------------------------------------------------------------------{{{

sub readstate_jobs
{
	return ( exists $INPUT{jobs} ) ? $INPUT{jobs} : -1;
}

sub _render_jobs_part
{
	my ($text, $themeName) = @_;
	my $style = themed "jobs_${themeName}_style";
	return (
		{
			style => $style ? $style : 'none' ,
			fg => themed "jobs_${themeName}_fg" ,
		},
		$text
	);
}

sub render_jobs
{
	my $jobs = shift;
	return () if ( $jobs == 0 && !$CONFIG{jobs_always} ) || $jobs < 0;

	my @output = ();
	my $section = themed 'jobs_prefix';
	@output = _render_jobs_part($section, 'prefix') if $section;
	@output = (@output, _render_jobs_part($jobs, 'count'));
	$section = themed 'jobs_suffix';
	@output = (@output, _render_jobs_part($section, 'prefix')) if $section;

	return {
		bg => themed( 'jobs_bg' ) ,
		content => [ @output ]
	};
}

# }}}
# Git repository information ------------------------------------------------{{{

sub _readstate_git_branch
{
	chop( my $branch = `git symbolic-ref -q HEAD` );
	my $detached = ( $? != 0 );
	if ( $detached ) {
		chop( $branch = `git rev-parse --short -q HEAD` );
		$branch = "($branch)";
	} else {
		$branch =~ s!^refs/heads/!!;
	}
	return { d => $detached, id => $branch };
}

sub _readstate_git_repstate
{
	my $state = shift;
	if ( open( my $fh ,
			'git rev-parse --git-dir --is-inside-git-dir '
			. '--is-bare-repository 2>/dev/null|' ) ) {
		chop( my $gd = <$fh> );
		chop( my $igd = <$fh> );
		chop( my $bare = <$fh> );
		close $fh;

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
		$state->{rs} = $str if $str;
	}
}

sub _readstate_git_status
{
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
	return [ @counters ];
}

sub readstate_git
{
	return undef unless $HASCWD;
	system( 'git rev-parse --is-inside-work-tree >/dev/null 2>&1' );
	return undef if $? != 0;
	my $state = {};

	# Branch information
	$state->{br} = _readstate_git_branch;

	# Repository state
	_readstate_git_repstate( $state );

	# Status
	$state->{status} = _readstate_git_status if $CONFIG{git_show_status};

	# Stash information
	if ($CONFIG{git_show_stash}
			&& open( my $fh , 'git stash list 2>/dev/null|' )) {
		my @lines = grep { $_ =~ /^stash/ } <$fh>;
		close( $fh );
		my $nl = scalar( @lines );
		$state->{stash} = $nl if $nl;
	}

	return $state;
}

sub _render_git_branch
{
	my $state = shift;

	# Get branch and associated warning level
	my $branch = $state->{id};
	my $detached = $state->{d};
	my $branch_warning;
	if ( $detached ) {
		$branch_warning = $CONFIG{git_detached_warning};
	} else {
		my %branch_tab = (
			( map { $_ => 1 } @{ $CONFIG{git_branch_warn} } ) ,
			( map { $_ => 2 } @{ $CONFIG{git_branch_danger} } ) ,
		);
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
	my $state = shift;
	return () unless exists $state->{rs};
	return {
		bg => themed 'git_repstate_bg' ,
		content => [
			{fg=>themed 'git_repstate_fg'},
			$state->{rs}
		]
	};
}

sub _render_git_status
{
	my $state = shift;
	return () unless exists $state->{status};
	my @counters = @{ $state->{status} };

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
	my $state = shift;
	return () unless exists $state->{stash};
	return {
		bg => themed('git_stash_bg') ,
		content => [
			{fg=>themed('git_stash_fg')} ,
			themed('git_stash_symbol') ,
			{style=>'b'},
			$state->{stash} ,
			{style=>'none'},
		]
	};
}

sub render_git
{
	my $state = shift;
	return () unless defined $state;
	my @out = ( _render_git_branch( $state->{br} ) );
	@out = ( @out , _render_git_repstate( $state ) );
	@out = ( @out , _render_git_status( $state ) );
	@out = ( @out , _render_git_stash( $state ) );
	return @out;
}

# }}}
# Python virtual environment ------------------------------------------------{{{

sub readstate_pyenv
{
	my $state = {};
	if ( exists $ENV{VIRTUAL_ENV} ) {
		$state->{env} = $ENV{VIRTUAL_ENV};
	} elsif (exists $ENV{CONDA_VIRTUAL_ENV}) {
		$state->{env} = $ENV{CONDA_VIRTUAL_ENV};
	}
	$state->{env} =~ s!.*/!! if exists $state->{env};

	my $vd = $CONFIG{pyenv_py_version};
	if ( $vd == 2 || ( $vd == 1 && exists $state->{env} ) ) {
		my $cmd = join('||',
			(map { "python$_ --version 2>/dev/null" } ('', 3, 2))
		);
		chop( my $pyver = `$cmd` );
		$state->{ver} = (split /\s+/, $pyver, 2)[1];
	}

	return $state;
}

sub render_pyenv
{
	my $state = shift;
	my $vd = $CONFIG{pyenv_py_version};
	my $env = exists( $state->{env} ) ? $state->{env} : '';
	my $ver = exists( $state->{ver} ) ? $state->{ver} : '';
	return unless $env || ( $vd == 2 && $ver );
	my @output = (
		{ fg=> themed 'pyenv_fg', style => 'd' },
		(themed 'pyenv_text')
	);
	@output = (@output, { style => 'b' }, $env ) if $env;
	@output = (@output, { style => 'd' }, (themed 'pyenv_sep')) if $env && $vd;
	if ($vd == 2 || ( $vd == 1 && $env )) {
		@output = (@output, {style => 'none' }, $ver);
	}
	return {
		bg => themed 'pyenv_bg' ,
		content => [ @output ]
	};
}

# }}}

# }}}
