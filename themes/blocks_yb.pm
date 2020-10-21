# blocks_yb
{
	# Padding character
	'padding' => "\x{2500}",

	# Extra colors for transition strings
	'transition' => [ 0, 189 ],
	# Default background/foreground colors
	'bg' => 0,
	'fg' => 7,
	# Color gradient used in various parts
	fg0 => 69,  bg0 => -1,
	fg1 => 117, bg1 => -1,
	fg2 => 178, bg2 => -1,
	fg3 => 226, bg3 => -1,

	# Left side of top line
	'bg_left' => thref 'bg',
	'fg_left' => thref 'fg',
	'left_prefix' => "\\b2\\f3\x{256d}\x{2504} ",
	'left_separator' => "\\b2\\f3 \x{2508} ",
	'left_suffix' => "\\b2\\f3 \x{2504}\x{2562}",
	# Middle of top line
	'bg_middle' => thref 'bg',
	'fg_middle' => 189,
	'middle_prefix' => ' ',
	'middle_separator' => ' | ',
	'middle_suffix' => ' ',
	# Right side of top line
	'bg_right' => thref 'bg',
	'fg_right' => thref 'fg',
	'right_prefix' => "\\b2\\f3\x{256b}\x{2504} ",
	'right_separator' => "\\b2\\f3 \x{2508} ",
	'right_suffix' => "\\b2\\f3 \x{2504}(",
	# Input line
	'bg_input' => thref 'bg',
	'fg_input' => thref 'fg',
	'input_prefix' => "\\b2\\f3\x{2570}\x{2504}",
	'input_separator' => "\\b2\\f3\x{2508}",
	'input_suffix' => "\\b2\\f3\x{2500}> ",
	# Secondary prompt
	'bg_ps2' => thref 'bg',
	'ps2_suffix' => "\\b2\\f3\x{250a} ",

	# Current working directory - Truncation string
	'cwd_trunc' => "\x{2026}",
	# Current working directory - Foreground / background colors
	'cwd_fg_color' => -1 ,
	'cwd_bg_color' => -1 ,

	# User@host - Remote host symbol
	'uh_remote_symbol' => "\x{21a5}",
	# User@host - User - Foreground and background colors
	'uh_user_fg' => thref 'fg0' ,
	'uh_user_bg' => thref 'bg0' ,
	# User@host - Root - Foreground and background colors
	'uh_root_fg' => thref 'fg3' ,
	'uh_root_bg' => thref 'bg3' ,

	# Date/time - Colors
	'dt_time_fg' => -1 ,
	'dt_date_fg' => -1 ,
	'dt_bg' => -1 ,

	# Previous command state - Symbols
	'pcmd_ok_sym' => "\x{2713}",
	'pcmd_err_sym' => "\x{2717}",
	# Previous command state - OK text / background color
	'pcmd_ok_fg' => thref 'fg0',
	'pcmd_ok_bg' => -1 ,
	# Previous command state - Error text / background color
	'pcmd_err_fg' => thref 'fg3',
	'pcmd_err_bg' => -1 ,
	# Previous command state - Other text foreground
	'pcmd_text_fg' => -1 ,

	# Load average - Symbol or text
	'load_title' => "\x{219f}",
	# Load average - Low load colors
	'load_low_fg' => -1,
	'load_low_bg' => -1,
	# Load average - Medium load colors
	'load_med_fg' => thref 'fg2',
	'load_med_bg' => thref 'bg2',
	# Load average - High load colors
	'load_high_fg' => thref 'fg3' ,
	'load_high_bg' => thref 'bg3' ,

	# Git - Branch symbol
	'git_branch_symbol' => "\x{255f}\x{256f}",
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
	'pyenv_fg' => -1,
	'pyenv_bg' => -1,
}