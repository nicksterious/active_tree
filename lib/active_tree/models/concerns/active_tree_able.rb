require "jwt"

# read https://www.postgresqltutorial.com/postgresql-schema/

module ActiveTree
    module ActiveTreeAble
    	extend ActiveSupport::Concern

        included do

    	    has_many :active_trees, class_name: "::ActiveTree::Model", foreign_key: :owner_id, as: :owner
    	    after_create :active_tree_create_storage
    	    before_destroy :active_tree_delete_storage

            # instance methods
        	def store
        	    ActiveTree::Store.new id, ACTIVE_TREE_OPTIONS
        	end # store

        	def active_tree_role
        	    store.role_name
        	end # role

            # Generates a JWT token the client (SPA) can pass to PostgREST for privilege escalation
        	def generate_jwt
        	    payload = { role: active_tree_role }
        	    ::JWT.encode payload, ACTIVE_TREE_OPTIONS[:jwt_secret], ACTIVE_TREE_OPTIONS[:jwt_encryption]
        	end # .generate_jwt


            # Creates table partition and role for owner
        	def active_tree_create_storage
		    store.up!
        	end # create_storage


            # Deletes or detaches the partition and removes the role for this owner
        	def active_tree_delete_storage
        	    store.down!
        	end # delete_storage

    	end # ClassMethods
    end
end
