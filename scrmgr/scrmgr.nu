#!/usr/bin/env nu

def form-script-name [script_name: string] {
	return ($script_name | path basename | str replace "_" "-" | path parse | get stem)
}

def confirm [prompt: string, --default: string] {
	let $default = if $default != null and ($default | str downcase) == 'y' {
		true 
	} else {
	 	false
	}

	mut yes_label = "y"
	mut no_label = "y"
	if $default != null {
		$yes_label = if $default { "Y" } else { "y" }
		$no_label = if not $default { "N" } else { "n" }
	}
	let formed_prompt = $"($prompt) [($yes_label)/($no_label)] "

	while true {
		let $user_input = (input $formed_prompt) | str downcase | str trim

		if $user_input == 'y' {
			return true
		} else if $user_input == 'n' {
			return false
		} else if ($user_input | str trim) == '' and $default != null {
			return $default
		}
	}
}


def main [] {
	print "You must specify a subcommand. "
}

def 'main ls' [] {
	if not ($env.UTILS_DIR | path exists) {
		error make {
			msg: $"Utilities directory doesn't exist \(($env.UTILS_DIR))."
		}
	}

	let script_list = ls -la | where { |file| $file.type != dir and ($file.mode | str contains 'x') }
		| select name type target created

	if ($script_list | is-empty) == 0 {
		print $"No scripts installed in '($env.UTILS_DIR)'."
	} else {
		echo $script_list
	}
}

# Uninstalls a script of the given name.
def 'main rm' [
	# Name of the script.
	installed_script_name: string,

	# Quietly quit if the referenced script doesn't exist.
	--quiet(-q)

	# Promps the user for confirmation
	--confirm(-c)
] {
	let filepath = ($env.UTILS_DIR | path join $installed_script_name)

	if not ($filepath | path exists) {
		if not $quiet {
			error make {
				msg: $"No script found with name ($installed_script_name) \(supposedly installed in ($filepath))."
			}
		} else {
			exit 1
		}
	}


	if $confirm and not (confirm $"Are you sure you want to remove '($filepath)'?" --default 'y') {
		print "Operation cancelled."
		exit 0
	}

	print $"Removing script installed in ($filepath)..."
	rm $filepath
	print $"Script '($filepath)' removed."
}

# Installs a script in the utils directory. ($UTILS_DIR)
def 'main install' [
	# Name of the script
	script_name: string
] {
	let utils_dir = $env.UTILS_DIR

	if not ($script_name | path exists) {
		error make {
			msg: $"File not found: '($script_name)'"
		}
	}

	if not ($utils_dir | path exists) {
		error make {
			msg: $"The utilities directory doesn't exist: '($utils_dir)'"
		}
	}

	let link_filepath = ($utils_dir | path join (form-script-name $script_name))

	print $"Creating link '($link_filepath)' for script '($script_name)'..."
	ln -s ($script_name | path expand) $link_filepath
	print "Script installed."
}