# frozen_string_literal: true

require 'memery'
require 'paint'
require 'time'

## Migration file
class MigrationFile # rubocop:disable Metrics/ClassLength
	CONTENT = proc do |content|
		content ||= +<<~DEFAULT
			change do
			end
		DEFAULT

		## /^(?!$)/ - searches for a position that starts at the
		## "start of line" position and
		## is not followed by the "end of line" position

		<<~STR
			# frozen_string_literal: true

			Sequel.migration do
				#{content.gsub!(/^(?!$)/, "\t").strip!}
			end
		STR
	end

	DISABLING_EXT = '.bak'

	class << self
		include Memery

		def database_schema_migrations
			@database_schema_migrations ||=
				db_connection[:schema_migrations].select_map(:filename)
		end

		def find(query, only_one: true, enabled: true, disabled: true)
			filenames = Dir[File.join(DB_MIGRATIONS_DIR, "*#{query}*")]
			filenames.select! { |filename| File.file? filename }
			files = filenames.map { |filename| new filename: filename }.sort!
			files.reject!(&:disabled) unless disabled
			files.select!(&:disabled) unless enabled

			return files unless only_one
			return files.first if files.size < 2

			raise 'More than one file mathes the query'
		end

		memoize def applied
			database_schema_migrations.map { |one| new filename: one }
		end

		memoize def existing
			find '*', only_one: false, disabled: false
		end

		memoize def applied_not_existing
			existing_names = existing.map(&:basename)

			applied.reject do |one|
				existing_names.include? one.basename
			end
		end

		memoize def existing_not_applied
			existing.reject do |one|
				database_schema_migrations.include? one.basename
			end
		end
	end

	attr_accessor :version, :name, :disabled

	def initialize(filename: nil, name: nil, content: nil)
		self.filename = filename
		self.name = name if name
		@content = content
	end

	## Accessors

	def basename
		File.basename(@filename)
	end

	def filename=(value)
		parse_filename value if value.is_a? String
		@filename = value
	end

	def name=(value)
		@name = value.tr(' ', '_').downcase
	end

	def disabled=(value)
		@disabled =
			case value
			when String
				[DISABLING_EXT, DISABLING_EXT[1..-1]].include? value
			else
				value
			end
	end

	def <=>(other)
		version <=> other.version
	end

	def applied?
		self.class.database_schema_migrations.include?(basename)
	end

	## Behavior

	def print
		datetime = Time.parse(version).strftime('%F %R')

		puts [
			Paint["[#{version}]", :white],
			Paint[datetime, disabled ? :white : :cyan],
			Paint[fullname, disabled ? :white : :default],
			(Paint['(not applied)', :red] unless applied?)
		].join(' ')
	end

	def generate
		self.version = new_version
		FileUtils.mkdir_p File.dirname new_filename
		File.write new_filename, CONTENT.call(@content)
		puts "Migration #{relative_filename} created."
	end

	def reversion
		rename version: new_version
	end

	def disable
		abort 'Migration already disabled' if disabled

		rename disabled: true

		puts "Migration #{relative_filename} disabled."
	end

	def enable
		abort 'Migration already enabled' unless disabled

		rename disabled: false

		puts "Migration #{relative_filename} enabled."
	end

	private

	def fullname
		result = name.tr('_', ' ').capitalize
		disabled ? "- #{result} (disabled)" : result
	end

	def parse_filename(value = @filename)
		basename = File.basename value
		self.version, parts = basename.split('_', 2)
		self.name, _ext, self.disabled = parts.split('.')
	end

	def new_version
		Time.now.strftime('%Y%m%d%H%M%S')
	end

	def rename(vars = {})
		vars.each { |key, value| send :"#{key}=", value }

		return unless @filename.is_a? String

		File.rename @filename, new_filename
		self.filename = new_filename
	end

	def new_filename
		new_basename = "#{version}_#{name}.rb#{DISABLING_EXT if disabled}"
		File.join DB_MIGRATIONS_DIR, new_basename
	end

	def relative_filename
		new_filename.gsub("#{ROOT_DIR}/", '')
	end
end
