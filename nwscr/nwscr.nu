#!/usr/bin/env nu

# Creates a new script of the specified language.
def main [
	# Language of the script to create
    language: string,

    # Name of the script to create
    script_name: string,

    # Overwrites the script if it already existed.
    --overwrite(-o),

    # Adds an extension to the name of the output file (corresponds to the language specified).
    --extension(-x)
] {
	mut script_name = $script_name
	if (($script_name | path exists) and not $overwrite) {
		print $"(ansi red)File ($script_name) already exists. \(use --overwrite\)"
		exit 1
	}

	let script_dirname = ($script_name | path dirname)

	if not ($script_dirname | path exists) and $script_name == '' {
		print $"Script container directory created \(($script_dirname)\)"
		mkdir $script_dirname
	}

	let shebang = $"#!/usr/bin/env ($language)"

	if $extension {
		let extension = match ($language | str downcase) {
			'perl' => 'pl',
			'python' => 'py',
			'bash' | 'shell' | 'sh' => 'sh',
			'javascript' => 'js',
			_ => ($language | str downcase)
		}

		$script_name = $"($script_name).($extension)"
	}

	if $overwrite {
		$shebang | save $script_name --force
	} else {
		$shebang | save $script_name
	}
	
	chmod +x $script_name
}