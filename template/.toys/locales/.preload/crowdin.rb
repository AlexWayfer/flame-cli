# frozen_string_literal: true

def crowdin(command, branch)
	crowdin_config_file = File.join('config', 'crowdin.yml')

	branch ||= `git branch | grep -e "^*" | cut -d' ' -f 2`.strip

	sh "crowdin --config #{crowdin_config_file} -b #{branch.tr('/', '_')} " +
		command
end
