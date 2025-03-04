require 'active_record'
require 'active_support/inflector'

module LosPollosMapperos
  class CLI
    def self.run
      begin
        require File.expand_path("../../../config/environment", __FILE__)
      rescue LoadError
        puts "Error: Unable to load the Rails environment. Please run this gem in a Rails application directory."
        exit(1)
      end

      begin
        ActiveRecord::Base.connection.active?
      rescue StandardError => e
        puts "Error: Database connection failed - #{e.message}"
        exit(1)
      end

      tables = ActiveRecord::Base.connection.tables
      tables_to_update = {}

      tables.each do |table_name|
        begin
          columns = ActiveRecord::Base.connection.columns(table_name)
        rescue StandardError => e
          puts "Warning: Could not fetch columns for table #{table_name} (skipping) - #{e.message}"
          next
        end

        mappings_for_table = {}
        columns.each do |col|
          LosPollosMapperos.configuration.mappings.each do |key, mapping|
            if col.sql_type =~ mapping[:regex]
              mappings_for_table[col.name] = mapping[:graphql_type]
              break
            end
          end
        end

        if mappings_for_table.any?
          tables_to_update[table_name] = mappings_for_table
        end
      end

      if tables_to_update.empty?
        puts "No columns matching the configured mappings were found in the 'public' schema."
        exit(0)
      end

      puts "Found columns matching the configured mappings in the following tables:"
      tables_to_update.each do |table, mapping|
        puts "Table: #{table} -> columns: #{mapping.keys.join(', ')}"
      end

      tables_to_update.each_with_index do |(table_name, mappings_for_table), index|
        puts "\n[#{index+1}/#{tables_to_update.size}] Processing table '#{table_name}' with columns: #{mappings_for_table.keys.join(', ')}"

        model_name = table_name.singularize.camelize
        if Object.const_defined?(model_name)
          model_class = Object.const_get(model_name)
          if model_class < ActiveRecord::Base && model_class.table_name == table_name
            model_name = model_class.name
          end
        end

        candidates = []
        conventional_paths = [
          File.join('app/graphql/objects', "#{model_name.underscore}.rb"),
          File.join('app/graphql/objects', "#{model_name.underscore}_type.rb")
        ]
        conventional_paths.each { |path| candidates << path if File.exist?(path) }

        if candidates.empty?
          search_dir = 'app/graphql/objects/**/*.rb'
          Dir.glob(search_dir).each do |file|
            begin
              content = File.read(file)
            rescue StandardError
              next
            end
            if content.include?(model_name) || content.include?(table_name)
              candidates << file
            end
          end
          candidates.uniq!
          if candidates.size > 3
            candidates.sort_by! do |file|
              score = 0
              base = File.basename(file).downcase
              score += 2 if base.include?(model_name.underscore)
              score += 1 if base.include?(table_name)
              begin
                content = File.read(file)
                score += content.scan(/#{model_name}/).size
              rescue StandardError
                score += 0
              end
              -score
            end
            candidates = candidates.first(3)
          end
        end

        graphql_file = nil
        if candidates.empty?
          puts "❌ No GraphQL file found for model #{model_name} (table #{table_name}). Skipping this table."
          next
        elsif candidates.size == 1
          graphql_file = candidates.first
          puts "✔️ Found GraphQL file: #{graphql_file}"
        else
          puts "Multiple possible files found for model #{model_name}:"
          candidates.each_with_index do |file, idx|
            puts "  #{idx+1}. #{file}"
          end
          print "Select the correct file (1-#{candidates.size}) and press Enter: "
          user_choice = $stdin.gets
          if user_choice.nil?
            puts "\nNo selection made - skipping this table."
            next
          end
          choice = user_choice.strip.to_i
          if choice.between?(1, candidates.size)
            graphql_file = candidates[choice - 1]
            puts "✔️ Selected: #{graphql_file}"
          else
            puts "❌ Invalid choice. Skipping this table."
            next
          end
        end

        begin
          original_content = File.read(graphql_file)
        rescue StandardError => e
          puts "❌ Error reading file #{graphql_file}: #{e.message}"
          next
        end

        new_content = original_content.dup

        mappings_for_table.each do |col_name, new_graphql_type|
          new_content.gsub!(/field\s+:#{col_name}\s*,\s*(Int|Integer)\b/, "field :#{col_name}, #{new_graphql_type}")
        end

        if new_content == original_content
          puts "No fields to update in file #{graphql_file} (already updated or not present)."
          next
        end

        original_lines = original_content.split("\n")
        new_lines = new_content.split("\n")
        puts "Proposed changes in file #{graphql_file}:"
        original_lines.each_with_index do |old_line, idx|
          new_line = new_lines[idx]
          if old_line != new_line
            puts "- #{old_line.strip}"
            puts "+ #{new_line.strip}"
          end
        end

        print "Save these changes? (y/n): "
        confirm = $stdin.gets
        unless confirm
          puts "\nNo input received - skipping saving changes for this file."
          next
        end

        if confirm.strip.downcase == 'y'
          begin
            File.write(graphql_file, new_content)
            puts "✅ Changes saved to file #{graphql_file}."
          rescue StandardError => e
            puts "❌ Error saving file #{graphql_file}: #{e.message}"
          end
        else
          puts "⏩ Changes for file #{graphql_file} were skipped."
        end
      end

      puts "\nProcess completed."
    end
  end
end
