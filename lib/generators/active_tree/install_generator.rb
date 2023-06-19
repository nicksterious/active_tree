require "rails/generators/active_record"

module ActiveTree
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration
      source_root File.join(__dir__, "templates")

      def copy_migration
        migration_template "migration.rb.tt", "db/migrate/install_active_tree.rb", migration_version: migration_version
      end

      def copy_initializer
	    copy_file 'initializer.rb.tt', 'config/initializers/active_tree.rb'
      end

      def copy_config
        conf_file = "config/active_tree.yml"
        copy_file "config.yml.tt", conf_file
        contents = File.read( conf_file ).gsub("changeme", ('a'..'z').to_a.shuffle.first(4).join )
        File.open(conf_file, 'wb') { |file| file.write(contents) }
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
