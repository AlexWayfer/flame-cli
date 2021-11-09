# frozen_string_literal: true

describe 'Flame::CLI::New' do
	describe '--help' do
		subject { `#{FLAME_CLI} new --help` }

		let(:expected_lines) do
			[
				'Usage:',
				'flame new \[OPTIONS\] SUBCOMMAND \[ARG\] \.{3}',
				'Subcommands:',
				'application, app +Generate new application directory',
				'Options:',
				'-h, --help +print help'
			]
		end

		it { is_expected.to match_lines expected_lines }
	end
end
