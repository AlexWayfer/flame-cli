# frozen_string_literal: true

desc 'Generate model'

required_arg :name

def run
	BaseGenerator.new(:model, name).write
end
