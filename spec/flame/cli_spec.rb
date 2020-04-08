# frozen_string_literal: true

describe 'Flame::CLI' do
	describe '--help' do
		subject { `#{FLAME_CLI} --help` }

		let(:expected_words) do
			[
				'Usage:', 'flame [OPTIONS] SUBCOMMAND [ARG]',
				'Subcommands:', 'initialize, init, new',
				'Options:', '-h, --help'
			]
		end

		it { is_expected.to match_words(*expected_words) }
	end
end
