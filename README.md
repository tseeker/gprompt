GPrompt - useless gimmicky prompt for Bash on Linux
====================================================

GPrompt (short for GadgetoPrompt) is a gimmicky Bash prompt generator
that displays sort-of-useful information. It only works on Linux because
that's what I use. It adapts to the terminal's width, showing or hiding
information depending on the conditions.

## Features

GPrompt prompts may consist in one or two lines. The top line is separated
in three areas (left, midddle and right), while the second line (the "input"
line, where the cursor is) only has a single, left-aligned area. Each area
may be configured to display information from one of the generators. In
addition, the script may be configured to generate a terminal title and/or
terminal icon title.

## Installing GPrompt

GPrompt may be installed either at the system level or on a per-user basis.

### User installation

* Copy the script and associated themes to your home directory.

    mkdir -p ~/.local/share/gprompt/themes
    cp gprompt.pl ~/.local/share/gprompt
    cp themes/* ~/.local/share/gprompt/themes

* Add the following line to your `~/.bashrc`:

`export PROMPT_COMMAND='eval "$($HOME/.local/share/gprompt/gprompt.pl $?)"'`

### System-wide installation

* In the case of a system-wide installation, the script and associated themes
  must be copied to some shared location, e.g.

    mkdir -p /usr/share/gprompt/themes
    cp -R gprompt.pl themes/ /usr/share/gprompt

* Users may then use GPrompt by adding the following line to their `~/.bashrc`
  files (it could also be added to `/etc/skel/.bashrc`) :

`export PROMPT_COMMAND='eval "$(/usr/share/gprompt/gprompt.pl $?)"'`

## Configuration

GPrompt comes with a minimal (...-ish, this is a gadget after all)
configuration that will work out of the box. However, it can be customised
using both a system-wide configuration file and a per-user configuration file.
Values set in a configuration files override values that were previously
loaded, so it is possible to have a system-wide configuration that replaces
most of the defaults and a per-user configuration that only overrides a few of
the system-wide options. In addition, if the option is enabled from the
configuration files, it is possible to override settings using environment
variables.

The GPrompt configuration is a Perl hash reference, so the general syntax of
the file goes something like this:

    {
        'some_key' => 'some_value' ,
        'other_key' => [ 'list entry 1' , 'list entry 2' ] ,
    }

In order to override a configuration entry using an environment variable,
the variable must be named `GPROMPT_` followed by the uppercase name of
the configuration entry. If the configuration expects a list for the
value in question, the value of the environment variable will be split using
the comma character. If a table is expected, keys and values are expected
to be separated by a colon.

    export GPROMPT_LAYOUT_RIGHT=git,load
    export GPROMPT_LAYOUT_THEME_OVERRIDES=bg_left:230,bg_right:230

### Main configuration

The following variables control the configuration itself:

* `cfg_warn_files` indicates that the script should emit warnings when a file
  (configuration or theme) cannot be loaded due to some error (`0` or `1`,
  default `1`).
* `cfg_from_env` disables or enables configuration overrides from environment
  variables (`0` or `1`, default `0`).
* `cfg_sys_themes` must list system-wide directories which may contain GPrompt
  themes (list; default `/usr/share/gprompt/themes`).
* `cfg_user_themes` lists directories relative to the user's home which may
  contain GPrompt themes (list; default `.local/share/gprompt/themes` and
  `.gprompt-themes`).

The `layout_*` variables control the prompt's layout and general appearance:

* `layout_theme` is the name of the theme to use. The default theme will be used
  if it contains an empty string.
* `layout_theme_overrides` may contain local overrides to the theme's contents
  (table, empty by default).
* `layout_left`, `layout_right` and `layout_input` configure the generators that
  will provide the contents of the top left, top center, top right and bottom
  left sections of the prompt. All 3 variables are lists of generator names; by
  default, the top bar is empty (the script does not render it) and the input
  prompt only uses the `userhost` and `cwd` generators, emulating a rather basic
  `\u@\h:\w` prompt.
* `layout_middle` defines the generator from which the top middle section will
  be displayed. Background colors emitted by the generator are ignored. By
  default this entry contains an empty string.
* `layout_input_always` determines whether the input line should be rendered
  even if no generators are specified (`0` or `1`, default `0`).

The `term_*` variables control the prompt's ability to change the terminal's
title and/or icon title:

* `term_set_title` controls whether the title or icon title of the terminal
  should be changed. Possible values are `0` (no update), `1` (title), `2`
  (icon title), and `3` (both). By default, only the title is updated.
* `term_generators` contains the list of generators that will produce the title
  string (unicode characters in the generators' output will be removed).
* `term_separator` is a string that will be inserted between the various parts
  of the string.

Generators also require specific configuration variables. These are documented
in the generators' sections below.

### Theme files

Themes are also stored using Perl hashes. The file containing a theme `x` should
be named `x.pm` and located in one of the configured theme directories.

The following entries are used by the script's core :

* `padding` must contain a single character which is used for padding the top
  line's middle area, amongst other things.
* `transition` may contain a list of up to 8 color indices which can be used
  when generating transition strings from templates.
* 5 entries control each section's appearance.
  * The sections are identified by `left`, `middle`, `right` and `input` (top
    left, top middle, top right and bottom left, respectively).
  * Each section uses the following entries (replacing `${section}` with a
    section's identifier):
    * `bg_${section}` is the index of the background color of the section.
    * `fg_${section}` is the index of the foreground color of the section.
    * `${section}_prefix` is the template for the prefix of the section.
    * `${section}_separator` is the template for the separator that is inserted
      between generated areas in the section.
    * `${section}_suffix` is the template for the suffix of the section.
* `bg_ps2` is the index of the background color of the secondary prompt.
* `ps2_suffix` is the template for the suffix of the secondary prompt.

Templates are strings which may contain `\bX` and `\fX` escape sequences, where
`X` is a single digit, and which modify the background or foreground colors,
respectively. Values `0` and `1` correspond to the preceding and following
background color indices, while values between `2` and `9` will refer to the
contents of the `transition` list.

In addition to the entries above, theme definitions contain entries that are
specific to the various generators. These entries are documented below. When
the generator-specific entries list color indices, the special `-1` value may
be used to indicate that the current area's foreground or background color
should be used.

## Generators

### Current working directory

The `cwd` generator will output the current working directory. Its only
configuration variable, `cwd_max_width`, indicates the maximal percentage of the
terminal's width that the path may occupy before truncation occurs. The
following theme entries are required:

* `cwd_trunc` is the string that replaces the part of the path that is truncated
  when it is too long compared to the terminal's width.
* `cwd_fg_color` and `cwd_bg_color` are the foreground and background color
  indices for the section.

### Date/time

The `datetime` generator will output the current date, the current time, or
both. It is controlled by the following configuration entries:

* `dt_show_date` controls whether the date should be displayed.
* `dt_show_time` controls whether the time should be displayed.
* `dt_date_fmt` is a `strftime` format that will be used for the date.
* `dt_time_fmt` is a `strftime` format that will be used for the date.

In addition, the following entries must be set in the theme:

* `dt_bg` is the background color for the section.
* `dt_time_fg` is the foreground color for the time.
* `dt_date_fg` is the foreground color for the date.

### Git information

The `git` generator is meant to display information about the Git repository the
current directory is a part of. It is controlled by the following configuration
entries:

* `git_branch_danger` is a list of branch names that will cause the current
  branch to be displayed with the "danger" color set.
* `git_branch_warn` is a list of branch names that will cause the current branch
  to be displayed with the "warning" color set.
* `git_detached_warning` controls the color set that will be used when the head
  is detached: `0` for the normal set, `1` for the "warning" set and `2` for the
  "danger" set.
* `git_show_status` controls whether the status of the current repository should
  be displayed.
* `git_show_stash` controls whether the stash depth should be displayed.

The theme entries belowed control the Git information sections' appearance:

* `git_branch_symbol` is the prefix for the current branch's name.
* The color sets for the branch display section are controlled by entries named
  `git_branch_${set}_fg` and `git_branch_${set}_bg`. The `${set}` must be one of
  `ok`, `warn` or `danger`.
* `git_repstate_bg` / `git_repstate_fg` are the colors of the section that
  indicates special states (e.g. rebase in progress, bare repository...)
* `git_status_pad` is a string that will be inserted between the various parts
  of the status sections.
* Two sets of entries control the sections that correspond to untracked and
  indexed changes. These sections are identified by replacing `${type}` with
  either `untracked` and `indexed` in the names below.
  * `git_${type}_symbol` is the prefix for the section's text,
  * `git_${type}_bg` is the background color for the section,
  * `git_${type}_normal_fg` is the foreground color for the normal text in the
    section,
  * `git_${type}_add_fg`, `git_${type}_mod_fg` and `git_${type}_del_fg` define
    the foreground colors for the symbols that indicate new, modified or removed
    files, respectively.
* `git_add_symbol`, `git_mod_symbol` and `git_del_symbol` define the symbols
  that indicate new, modified or deleted files in the status sections.
* `git_stash_symbol` contains the prefix of the stash indicator,
* `git_stash_fg` and `git_stash_fg` define the background and foreground colors
  for the stash indicator.

### System load

The `load` generator will output the system's load average for the past minute
divided by the host's processor count. It is controlled by the `load_min`
configuration entry which specifies a percentage below which the section is not
displayed at all. The following theme entries are required:

* `load_title` is a string that is prepended to the generator's output.
* `load_low_fg` and `load_low_bg` are the foreground and background colors used
  when the load is beneath 34%.
* `load_med_fg` and `load_med_bg` are the foreground and background colors used
  when the load is between 34% and 66%.
* `load_high_fg` and `load_high_bg` are the foreground and background colors
  used when the load is higher than 66%.

### Previous command state

The `prevcmd` generator will output information about the previous command's
return value. It is controlled by the following configuration entries:

* `pcmd_show_symbol` controls whether a symbol that represents success or
  failure should be displayed.
* `pcmd_show_code` controls whether the return value should be displayed. It
  can be set to the usual `0` and `1` values to disable/enable, or to `2` to
  enable only when the return value indicates failure.
* `pcmd_pad_code` controls padding of the return value. `0` disables padding,
  `1` aligns to the left and `-1` to the right. The global padding character
  is used.
* `pcmd_colors` selects which parts of the output should use the theme's success
  or failure colors (`0` nothing, `1` symbol, `2` value, `3` both).

The following theme entries are needed:

* `pcmd_ok_sym` / `pcmd_err_sym` contain the symbols that represent success or
  failure, respectively.
* `pcmd_ok_fg` and `pcmd_ok_bg` define the foreground and background colors used
  to represent success. The foreground color may or may not be used, depending
  on the configuration.
* `pcmd_err_fg` and `pcmd_err_bg` define the foreground and background colors
  used to represent failure. The foreground color may or may not be used,
  depending on the configuration.
* `pcmd_text_fg` controls the foreground color of the strings that are excluded
  from using success/failure colors by the configuration.

### Python virtual environment

The `pyenv` generator will output the name of the currently active Python
virtual environment if there is one. The following theme entries are needed:

* `pyenv_fg` and `pyenv_bg` define the foreground and background colors for the
  section.

### User/host

The `userhost` generator will output the current user and host name. It is
controlled by the following configuration entries:

* `uh_username` controls whether the user name should be displayed.
* `uh_hostname` controls whether the host name should be displayed. It can be
  set to `0` (hidden), `1` (always display) or `2` (display on remote hosts
  only).
* `uh_remote` can be set to `1` in order to display an additional string on
  remote hosts.

In addition, the following entries must be set in the theme:

* `uh_remote_symbol` is the string to append to the section on remote hosts.
* `dt_user_fg` and `dt_user_bg` contain the foreground and background colors
  to use for normal, unprivileged users.
* `dt_root_fg` and `dt_root_bg` contain the foreground and background colors
  to use for the `root` account.
