# frozen_string_literal: true

describe 'Flame::CLI' do
	describe '--help' do
		subject { `#{FLAME_CLI} --help` }

		let(:expected_lines) do
			[
				'Usage:',
				'flame \[OPTIONS\] SUBCOMMAND \[ARG\] \.{3}',
				'Subcommands:',
				'initialize, init, new +create new entity',
				'Options:',
				'-h, --help'
			]
		end

		it { is_expected.to match_lines expected_lines }
	end
end
