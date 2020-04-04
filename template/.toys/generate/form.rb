# frozen_string_literal: true

desc 'Generate form'

required_arg :name

def run
	generator = BaseGenerator.new(:form, name)

	*modules, class_name = generator.camelized_name.split('::')

	generator.write(
		modules: modules,
		class_name: class_name,
		class_indentation: "\t" * modules.size,
		parent_form: model_forms.include?(class_name) ? class_name : 'Base'
	)
end

private

using GorillaPatch::Inflections

def model_forms
	Dir["#{ROOT_DIR}/forms/_model/*.rb"].map do |file|
		File.basename(file, '.rb').sub(/^_/, '').camelize
	end
end
