require 'rspec_api_documentation/writers/formatter'

module RspecApiDocumentation
  module Writers
    class AppendJsonWriter < JsonWriter
      def write
        index_file = docs_dir.join("index.json")
        if File.exist?(index_file) && (output = File.read(index_file)).length >= 2
          existing_index_hash = JSON.parse(output)
        end
        File.open(index_file, "w+") do |f|
          f.write Formatter.to_json(AppendJsonIndex.new(index, configuration, existing_index_hash))
        end
        write_examples
      end

      def self.clear_docs(docs_dir)
        nil #noop
      end
    end

    class AppendJsonIndex < JSONIndex
      def initialize(index, configuration, existing_index_hash = nil)
        @index = index
        @configuration = configuration
        @existing_index_hash = clean_index_hash(existing_index_hash)
        @existing_index_hash_index = get_section_hash_index(@existing_index_hash)
      end

      def as_json(opts = nil)
        @existing_index_hash[:resources][@existing_index_hash_index] = section_hash(sections.first)
        @existing_index_hash
      end

      def clean_index_hash(existing_index_hash)
        unless existing_index_hash.is_a?(Hash) && existing_index_hash["resources"].is_a?(Array) #check format
          existing_index_hash = {:resources => []}
        end
        existing_index_hash.deep_symbolize_keys
      end

      def get_section_hash_index(existing_index_hash)
        existing_index_hash[:resources].each_with_index do |resource, index|
          resource_names = sections.map{|s| s[:resource_name]}
          return index if resource_names.include? resource[:name]
        end
        existing_index_hash[:resources].length
      end
    end
  end
end
