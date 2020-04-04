# frozen_string_literal: true

include :exec, exit_on_nonzero_status: true unless include?(:exec)

subtool_apply do
	## https://github.com/dazuma/toys/issues/23#issuecomment-589031428
	# include :bundler unless include?(:bundler)
	include :exec, exit_on_nonzero_status: true unless include?(:exec)
end

alias_tool :db, :database

alias_tool :psql, 'database:psql'

alias_tool :c, :console

alias_tool :bench, :benchmark
alias_tool :b, :benchmark

alias_tool :g, :generate
