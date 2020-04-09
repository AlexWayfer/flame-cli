# frozen_string_literal: true

require 'clamp'

require_relative 'cli/new'

module Flame
	## CLI for Flame
	class CLI < Clamp::Command
		subcommand %w[initialize init new], 'create new entity', Flame::CLI::New
	end
end
