# frozen_string_literal: true

## Class for questions
class Question
	def initialize(text, possible_answers)
		@text = text
		@possible_answers = Set.new(possible_answers) << 'quit' << 'help'
	end

	def answer
		while @answer.nil?
			ask
			@answer = @possible_answers.find do |possible_answer|
				possible_answer.start_with? @real_answer
			end
			print_help if @answer.nil?
		end
		@answer
	end

	private

	def print_question
		print "#{@text} [#{@possible_answers.map(&:chr).join(',')}] : "
	end

	def print_help
		@possible_answers.each do |possible_answer|
			puts "#{possible_answer.chr} - #{possible_answer}"
		end
	end

	def ask
		print_question
		@real_answer = STDIN.gets.chomp.downcase
		case @real_answer
		when 'h'
			print_help
			ask
		when 'q'
			exit
		end
	end
end
