class ActiveTree::Model < ActiveRecord::Base

    include ActiveTree::Statusable

    self.primary_key = :id

    ltree :path

    def self.table_name
        return ::ACTIVE_TREE_OPTIONS[:table_name] if defined? ::ACTIVE_TREE_OPTIONS
        return "active_tree_models"
    end

    belongs_to :owner, polymorphic: :true, required: true

    scope :match_path, -> (some_path) { where("path ~ ?", "#{some_path}") }

    validates_presence_of :name, allow_blank: false
    validates_presence_of :path, allow_blank: false

    has_many :metadata, class_name: "::ActiveTree::Metadata", dependent: :destroy, as: :model

    before_validation :set_defaults
    def set_defaults
        self.path ||= name.delete(" ").gsub(/[^0-9a-z ]/i, '') if name
        self.path_slug = path.parameterize if path
        self.metadata_inline ||= {}
    end


    # Scoping by owner in order to select the partition
    #
    # @param owner_id [Integer] the partition owner
    def self.owned_by(owner_id)
        # if we're looking for anything else but an integer, revert to the base class
        return self if !owner_id.is_a? Integer

        partition_suffix = "_#{owner_id}"

        #table = "#{ self.table_name }#{ partition_suffix }"
        table = ActiveTree::Store.new(owner_id).partition_name

        ApplicationRecord.connection.schema_cache.clear!
        return self if !ApplicationRecord.connection.schema_cache.data_source_exists? table

        # duplicate the class
        model_class = Class.new self
        original_class_name = self.name

        # ...for this owner
        class_name = "#{name}#{partition_suffix}"

        # specify the table
        model_class.define_singleton_method(:table_name) do
            table
        end

        # specify the name
        model_class.define_singleton_method(:name) do
            class_name
        end

	model_class.define_singleton_method(:sti_name) do
	    original_class_name
	end

        # override the STI name lmfao
        model_class.define_singleton_method(:find_sti_class) do |p|
            original_class_name.constantize
        end

        # proceed
        model_class
    end # .owned_by

end
