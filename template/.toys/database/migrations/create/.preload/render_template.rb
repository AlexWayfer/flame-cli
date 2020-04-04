# frozen_string_literal: true

def render_template(filename)
	require 'erb'
	filename = File.join DB_MIGRATIONS_DIR, 'templates', "#{filename}.rb.erb"
	renderer = ERB.new(File.read(filename))
	renderer.filename = filename
	renderer.result(binding)
end
