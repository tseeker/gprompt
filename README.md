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
* `layout_left`, `layout_middle`, `layout_right` and `layout_input` configure
  the generators that will provide the contents of the top left, top center,
  top right and bottom left sections of the prompt. All 4 variables are lists
  of generator names; by default, the top bar is empty (the script does not
  render it) and the input prompt only uses the `userhost` and `cwd` generators,
  emulating a rather basic `\u@\h:\w` prompt.
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
