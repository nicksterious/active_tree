# frozen_string_literal: true
require "active_support/all"

require "active_record"

require "pg_ltree"

require_relative "active_tree/version"
require_relative "active_tree/store"

require_relative "active_tree/models/concerns/statusable"
require_relative "active_tree/models/metadata"
require_relative "active_tree/models/model"

require_relative "active_tree/models/concerns/active_tree_able"
require_relative "active_tree/active_record"

# TODO add query objects and builders
require_relative "active_tree/queries/active_tree_query"
require_relative "active_tree/queries/model_query"
#require_relative "active_tree/builders/"

module ActiveTree
    class Error < StandardError; end

    # Your code goes here...

    class << self
    	attr_accessor :active_tree_models
    	attr_accessor :options
    end

    self.active_tree_models = []

    def self.active_tree_options
	    @options ||= begin
    	    path = Rails.root.join("config", "active_tree.yml").to_s
    	    if File.exist?(path)
    		    YAML.load(ERB.new(File.read(path)).result)
    	    else
        		{
        		    table_name: "active_tree_models",
        		    jwt_secret: "",
        		    jwt_encryption: "HS256"
        		}
    	    end
    	end
    end

    def self.env
        @env ||= ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
    end
end
