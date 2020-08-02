# frozen_string_literal: true

require 'flame/raven_context'

module Flame
	## Redefine `user` object
	class RavenContext
		private

		def user
			# @controller&.send(:authenticated)&.account
		end
	end
end
