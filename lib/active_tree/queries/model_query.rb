class ActiveTree::ModelQuery < ActiveTree::Query
    attr_accessor :initial_scope

    def initialize(initial_scope = ::ActiveTree::Model.all)
	@initial_scope = initial_scope
    end # initialize

    def call(params)
	scope = simple_search(initial_scope, :id, params[:id])
	[:owner_type, :owner_id, :status, :data_external_id, :data_provider, :type, :parent_entity_id, :parent_entity_type, :path_slug].each do |query|
	    scope = simple_search(scope, query, params[query])
	end

	scope = by_search(scope, params[:search])

	scope
    end # call


    # Partial search by name
    def by_search(scope, search = nil)
	search ? scope.where("lower(name) like ?", "%#{search.downcase}%") : scope
    end # by_search


    # Simple search by attribute and exact value
    def simple_search(scope, attribute = nil, value = nil)
	valid?(attribute, value) ? scope.where(attribute => value) : scope
    end # simple search

end