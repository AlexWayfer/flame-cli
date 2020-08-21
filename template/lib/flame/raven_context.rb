# frozen_string_literal: true

## Required via `Bundler.require` in `application.rb`
# require 'flame/raven_context'

module Flame
	## Redefine `user` object
	class RavenContext
		private

		def user
			# @controller&.send(:authenticated)&.account
		end
	end
end
