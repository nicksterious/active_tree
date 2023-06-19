class ActiveTree::Store
    attr_accessor :options
    attr_accessor :debug_sql

    class StoreException < StandardError
	def initialize(msg="This is a custom exception", exception_type="custom")
    	    @exception_type = exception_type
            super(msg)
	end
    end

    def initialize(owner_id = nil, options = ACTIVE_TREE_OPTIONS)
	raise StoreException.new("Unspecified owner_id, please pass an unique identifier for the partitions: ActiveTree::Store.new(your_owner_id)") if !owner_id
	raise StoreException.new("owner_id must be an integer!") if !owner_id.is_a?(Integer)
	@owner_id = owner_id
	@options = options
	@debug_sql = false
    end

    def up!
	create_partition_for_owner # also adds indexes
	setup_role if @options[:create_postgrest_roles] == true
    end # up!

    def down!
	drop_role if @options[:create_postgrest_roles] == true
	remove_partition
    end # down!

    def clear_schema_cache
	ActiveRecord::Base.connection.schema_cache.clear!
    end # clear_schema_cache

    # partition management

    def has_partition?
	clear_schema_cache
	ActiveRecord::Base.connection.schema_cache.data_source_exists? partition_name
    end

    def create_partition_for_owner(indexes = [ :id, :owner_id, :type, :parent_entity_id, :path, [:data_provider, :data_external_id ] ])
	create_partition indexes
    end

    def create_partition(indexes = [])
	return false if has_partition?

	run "create table if not exists #{partition_name} partition of #{ @options[:table_name] } for values in ( #{@owner_id} )"

	indexes.each do |index|
	    create_index(index) if !has_index?( index )
	end if indexes.size > 0
    end # create_partition

    def partition_name
	"#{@options[:table_name]}_#{@owner_id}"
    end # partition_name

    def should_drop_partition?
	@options[:destroy_partition_on_owner_destroy] == true
    end

    def remove_partition
	if should_drop_partition?
	    drop_partition
	else
	    detach_partition
	end
    end # remove_partition

    def detach_partition
	return false if !has_partition?
	run "alter table #{@options[:table_name]} detach partition #{partition_name}"
    end # detach_partition
    def drop_partition
	return false if !has_partition?
	run "drop table #{partition_name}"
    end # drop partition

    # index management

    def partition_indexes
	clear_schema_cache
	ActiveRecord::Base.connection.indexes( partition_name ).map(&:name)
    end

    def has_index? name
	partition_indexes.include?( index_name(name).truncate(63) )
    end # has_index
    def create_index index
	return false if has_index? index
	name = index_name index
	using = name.include?("path") ? "using gist" : ""

	cols = [index].flatten.join(",")

	run "create index #{name} on #{partition_name} #{using} ( #{ cols } )"
    end # create_index
    def drop_index index
	return false if !has_index? index
	run "drop index if exists #{ index_name(index) }"
    end # drop_index

    def index_name identifier
	i = [identifier].flatten.join("_")
	"#{partition_name}_by_#{i}"
    end

    # TODO role management

    def setup_role
	drop_role
	create_role
    end # setup_role

    def role_name
	"active_tree_owner_#{@owner_id}_#{ @options[:owner_role_suffix] }"
    end # role_name

    def drop_role
	run "drop role if exists #{role_name}"
    end # drop role

    def create_role
	run "create role #{role_name}"
    end # create role

    def assign_to_partition
	run "grant all privileges on #{partition_name} to #{ role_name }"
    end

    # running SQL

    def run sql
	puts sql if @debug_sql
	ActiveRecord::Base.connection.execute sql
	true
    end

end