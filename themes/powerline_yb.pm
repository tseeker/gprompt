# powerline_gyr
{
	# Padding character
	'padding' => ' ',

	# Extra colors for transition strings
	'transition' => [ 233 ] ,
	# Default foreground color
	'fg' => 15,
	# Color gradient used in various parts
	fg0 => 226 , bg0 => 21 ,
	fg1 => 184 , bg1 => 61 ,
	fg2 => 21 ,  bg2 => 143 ,
	fg3 => 18 ,  bg3 => 226 ,

	# Left side of top line
	'bg_left' => 239,
	'fg_left' => thref 'fg',
	'left_prefix' => '\b1 ' ,
	'left_separator' => '\f0\b2'."\x{e0b0}".'\f2\b1'."\x{e0b0}" ,
	'left_suffix' => '\f0\b2'."\x{e0b0}".'\f2\b1'."\x{e0b0}".' ' ,
	# Middle of top line
	'bg_middle' => 235,
	'fg_middle' => thref 'fg',
	'middle_prefix' => '',
	'middle_separator' => "\\f2\x{2590}\x{258c}",
	'middle_suffix' => '',
	# Right side of top line
	'bg_right' => 239,
	'fg_right' => thref 'fg',
	'right_prefix' => '\f2\b0'."\x{e0b2}".'\f1\b2'."\x{e0b2}".'\b1' ,
	'right_separator' => '\f2\b0'."\x{e0b2}".'\f1\b2'."\x{e0b2}" ,
	'right_suffix' => '\b0 ' ,
	# Input line
	'bg_input' => 238,
	'fg_input' => thref 'fg',
	'input_prefix' => '\b1 ' ,
	'input_separator' => '\f0\b2'."\x{e0b0}".'\f2\b1'."\x{e0b0}" ,
	'input_suffix' => '\f0\b2'."\x{e0b0}".'\f2\b1'."\x{e0b0}".' ' ,
	# Secondary prompt
	'bg_ps2' => 234,
	'ps2_suffix' => '\f0\b2'."\x{e0b0}".'\f2\b1'."\x{e0b0}".' ' ,

	# Current working directory - Truncation string
	'cwd_trunc' => "\x{2026}",
	# Current working directory - Foreground / background colors
	'cwd_fg_color' => SECTION_DEFAULT ,
	'cwd_bg_color' => SECTION_DEFAULT ,
	# Current working directory - Colors when directory is missing
	'cwd_missing_fg_color' => thref 'bg3' ,
	'cwd_missing_bg_color' => SECTION_DEFAULT ,

	# User@host - Remote host symbol
	'uh_remote_symbol' => "\x{21a5}",
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
	'pcmd_ok_sym' => "\x{2713}",
	'pcmd_err_sym' => "\x{2717}",
	# Previous command state - OK text / background color
	'pcmd_ok_fg' => thref( 'fg3' ) ,
	'pcmd_ok_bg' => SECTION_DEFAULT ,
	# Previous command state - Error text / background color
	'pcmd_err_fg' => thref( 'fg0' ) ,
	'pcmd_err_bg' => SECTION_DEFAULT ,
	# Previous command state - Other text foreground
	'pcmd_text_fg' => SECTION_DEFAULT ,

	# Load average - Symbol or text
	'load_title' => "\x{219f}",
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
	'git_branch_symbol' => "\x{e0a0} " ,
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
	'git_untracked_symbol' => "\x{2744}",
	'git_untracked_bg' => thref 'bg3' ,
	'git_untracked_normal_fg' => thref 'fg3' ,
	'git_untracked_add_fg' => thref 'fg3' ,
	'git_untracked_mod_fg' => thref 'fg3' ,
	'git_untracked_del_fg' => thref 'fg3' ,
	# Git - Indexed symbol and colors
	'git_indexed_symbol' => "\x{2630}",
	'git_indexed_bg' => thref 'bg2' ,
	'git_indexed_normal_fg' => thref 'fg2' ,
	'git_indexed_add_fg' => thref 'fg2' ,
	'git_indexed_mod_fg' => thref 'fg2' ,
	'git_indexed_del_fg' => thref 'fg2' ,
	# Git - Add/modify/delete symbols
	'git_add_symbol' => '+' ,
	'git_mod_symbol' => "\x{b1}",
	'git_del_symbol' => "\x{2205}",
	# Git stash symbol and color
	'git_stash_symbol' => "\x{2021}",
	'git_stash_bg' => thref 'bg1' ,
	'git_stash_fg' => thref 'fg1' ,

	# Python virtual environment section colors
	'pyenv_fg' => SECTION_DEFAULT,
	'pyenv_bg' => SECTION_DEFAULT,
}
