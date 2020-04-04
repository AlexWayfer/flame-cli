# frozen_string_literal: true

require 'yaml'

## Class for Locale file
class Locale
	attr_reader :code, :hash

	EXT = '.yml'

	def self.load
		Dir[File.join(ROOT_DIR, 'locales', "*#{EXT}")].map do |file|
			new File.basename(file, EXT), YAML.load_file(file)
		end
	end

	def initialize(code, hash)
		@code = code
		@hash = hash
	end

	## Compares generic values and returns rich diff
	class HashCompare
		def initialize(hash, other_hash)
			@hash = hash
			@other_hash = other_hash
		end

		def different_keys
			@hash.each_with_object({}) do |(key, value), result|
				difference = generic_difference(value, @other_hash[key])
				next if difference.nil? || difference.empty?

				result[key] = difference
			end
		end

		private

		def generic_difference(value, other_value)
			return value if value.class != other_value.class

			case value
			when Hash
				self.class.new(value, other_value).different_keys
			when Array
				differences_in_array(value, other_value)
			when nil
				value
			end
		end

		def differences_in_array(array, other_array)
			return array if array.size != other_array.size

			array.zip(other_array).map do |object, other_object|
				next if !object.is_a?(Hash) || !other_object.is_a?(Hash)

				difference = self.class.new(object, other_object).different_keys
				difference unless difference.empty?
			end.compact
		end
	end

	def diff(other)
		HashCompare.new(hash, other.hash).different_keys
	end
end
