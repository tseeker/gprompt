# ascii_gyr
{
	# Padding character
	'padding' => '-',

	# Extra colors for transition strings
	'transition' => [ TERM_DEFAULT , 230 ] ,
	# Default background/foreground colors
	'bg' => TERM_DEFAULT,
	'fg' => 7,
	# Color gradient used in various parts
	fg0 => 2 ,  bg0 => SECTION_DEFAULT ,
	fg1 => 10 , bg1 => SECTION_DEFAULT ,
	fg2 => 11 , bg2 => SECTION_DEFAULT ,
	fg3 => 9 ,  bg3 => SECTION_DEFAULT ,

	# Left side of top line
	'bg_left' => thref 'bg',
	'fg_left' => thref 'fg',
	'left_prefix' => '\b2\f3[' ,
	'left_separator' => '\b2\f3][' ,
	'left_suffix' => '\b2\f3]' ,
	# Middle of top line
	'bg_middle' => thref 'bg',
	'fg_middle' => 230,
	'middle_prefix' => ' ',
	'middle_separator' => ' | ',
	'middle_suffix' => ' ',
	# Right side of top line
	'bg_right' => thref 'bg',
	'fg_right' => thref 'fg',
	'right_prefix' => '\b2\f3(' ,
	'right_separator' => '\b2\f3|' ,
	'right_suffix' => '\b2\f3)' ,
	# Input line
	'bg_input' => thref 'bg',
	'fg_input' => thref 'fg',
	'input_prefix' => '\b2\f3[' ,
	'input_separator' => '\b2\f3][' ,
	'input_suffix' => '\b2\f3]> ' ,
	# Secondary prompt
	'bg_ps2' => thref 'bg',
	ps2_suffix => '\b2\f3| ' ,

	# Current working directory - Truncation string
	cwd_trunc => '...' ,
	# Current working directory - Foreground / background colors
	'cwd_fg_color' => SECTION_DEFAULT ,
	'cwd_bg_color' => SECTION_DEFAULT ,

	# User@host - Remote host symbol
	'uh_remote_symbol' => '(r)',
	# User@host - User - Foreground and background colors
	'uh_user_fg' => thref 'fg0' ,
	'uh_user_bg' => thref 'bg0' ,
	# User@host - Root - Foreground and background colors
	'uh_root_fg' => thref 'fg3' ,
	'uh_root_bg' => thref 'bg3' ,

	# Date/time - Colors
	'dt_time_fg' => SECTION_DEFAULT ,
	'dt_date_fg' => SECTION_DEFAULT ,
	'dt_bg' => SECTION_DEFAULT ,

	# Previous command state - Symbols
	'pcmd_ok_sym' => ':-)',
	'pcmd_err_sym' => ':-(',
	# Previous command state - OK text / background color
	'pcmd_ok_fg' => thref 'fg0',
	'pcmd_ok_bg' => SECTION_DEFAULT ,
	# Previous command state - Error text / background color
	'pcmd_err_fg' => thref 'fg3',
	'pcmd_err_bg' => SECTION_DEFAULT ,
	# Previous command state - Other text foreground
	'pcmd_text_fg' => SECTION_DEFAULT ,

	# Load average - Symbol or text
	'load_title' => 'ld',
	# Load average - Low load colors
	'load_low_fg' => SECTION_DEFAULT,
	'load_low_bg' => SECTION_DEFAULT,
	# Load average - Medium load colors
	'load_med_fg' => thref 'fg2',
	'load_med_bg' => thref 'bg2',
	# Load average - High load colors
	'load_high_fg' => thref 'fg3' ,
	'load_high_bg' => thref 'bg3' ,

	# Git - Branch symbol
	'git_branch_symbol' => 'B ',
	# Git - Branch colors - No warning
	'git_branch_ok_bg' => thref 'bg0' ,
	'git_branch_ok_fg' => thref 'fg0' ,
	# Git - Branch colors - Weak warning
	'git_branch_warn_bg' => thref 'bg2' ,
	'git_branch_warn_fg' => thref 'fg2' ,
	# Git - Branch colors - Strong warning
	'git_branch_danger_bg' => thref 'bg3' ,
	'git_branch_danger_fg' => thref 'fg3' ,
	# Git - Repo state colors
	'git_repstate_bg' => thref 'bg1' ,
	'git_repstate_fg' => thref 'fg1' ,
	# Git - Padding character for status sections
	'git_status_pad' => '' ,
	# Git - Untracked symbol and colors
	'git_untracked_symbol' => 'U ',
	'git_untracked_bg' => thref 'bg3' ,
	'git_untracked_normal_fg' => thref 'fg3' ,
	'git_untracked_add_fg' => thref 'fg3' ,
	'git_untracked_mod_fg' => thref 'fg3' ,
	'git_untracked_del_fg' => thref 'fg3' ,
	# Git - Indexed symbol and colors
	'git_indexed_symbol' => 'I ',
	'git_indexed_bg' => thref 'bg2' ,
	'git_indexed_normal_fg' => thref 'fg2' ,
	'git_indexed_add_fg' => thref 'fg2' ,
	'git_indexed_mod_fg' => thref 'fg2' ,
	'git_indexed_del_fg' => thref 'fg2' ,
	# Git - Add/modify/delete symbols
	'git_add_symbol' => '+' ,
	'git_mod_symbol' => '~',
	'git_del_symbol' => '-',
	# Git stash symbol and color
	'git_stash_symbol' => 'S ',
	'git_stash_bg' => thref 'bg1' ,
	'git_stash_fg' => thref 'fg1' ,

	# Python virtual environment section colors
	'pyenv_fg' => SECTION_DEFAULT,
	'pyenv_bg' => SECTION_DEFAULT,
}
