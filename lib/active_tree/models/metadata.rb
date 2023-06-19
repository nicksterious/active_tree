class ActiveTree::Metadata < ActiveRecord::Base

    belongs_to :model, polymorphic: true, required: true

    def self.table_name
	return "#{ ::ACTIVE_TREE_OPTIONS[:table_name] }_metadata" if defined? ::LCA_OPTIONS
	return "active_tree_models_metadata"
    end
    
    validates_presence_of :key

end