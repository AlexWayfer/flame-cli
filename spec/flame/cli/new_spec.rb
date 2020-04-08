# frozen_string_literal: true

describe 'Flame::CLI::New' do
	describe '--help' do
		subject { `#{FLAME_CLI} new --help` }

		let(:expected_words) do
			[
				'Usage:', 'flame new [OPTIONS] SUBCOMMAND [ARG]',
				'Subcommands:', 'application, app',
				'Options:', '-h, --help'
			]
		end

		it { is_expected.to match_words(*expected_words) }
	end
end
