[![Tests](https://github.com/nicksterious/active_tree/actions/workflows/ci.yml/badge.svg)](https://github.com/nicksterious/active_tree/actions/workflows/ci.yml) [![Ruby Gem](https://github.com/nicksterious/active_tree/actions/workflows/rubygems.yml/badge.svg)](https://github.com/nicksterious/active_tree/actions/workflows/rubygems.yml) [![Gem Version](https://badge.fury.io/rb/active_tree.svg)](https://badge.fury.io/rb/active_tree) 

# ActiveTree

This gem implements a denormalized database model for tree data backed up by the Postgres LTREE extension.

## Installation

This gem is at home within a Rails 6+ console-only, API or full fledged application on top of a Postgres database.

Add this line to your application's Gemfile:

```ruby
gem 'active_tree'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install active_tree
    
Upon installing the gem you must run the install process in your Rails application's root:

    $ rails g active_tree:install
    
This will generate a `config/active_tree.yml` which you may customize to your needs, an initializer and a migration file which you can also customize to add any database columns your models will require.

## Usage

Include the ActiveTreeAble concern into one of your models which will own lifecycle trees (owner model):

```ruby
    class User < ApplicationRecord
        include ActiveTree::ActiveTreeAble
        # ...
    end
```

This will extend your model and enable the following functionality:

```ruby
# query with ActiveRecord syntax
User.last.active_trees
User.find_by(name: "Acme").active_trees.select("product_name, sum(product_price) as total_price").group(:product_name)
User.last.active_trees.where(...)
User.last.active_trees.where(...).group(...)
User.last.active_trees.where(...).limit(...).offset(...)
    
# AR query with ltree syntax
User.last.active_trees.disabled.match_path("*.ProductName.*")
User.last.active_trees.match_path("*{5,10}.CategoryName.*.ProductName.*")
User.last.active_trees.active.match_path("*.CategoryName.*.SubcategoryName.*.ProductName.*").where( product_price: [100..150]).sum(:product_price)

ActiveTree::Model.match_path("Top.Category.*").products.match_path("*.Scooter*").where( product_price: [ 1000..10000 ]).average(:product_price)
ActiveTree::Model.where(name: "RC Airplane").products.match_path("*.Battery.*").sum(:product_price)
ActiveTree::Model.where(owner: User.last).match_path("*{10,20}.*Category.*")
ActiveTree::Model.match_path("*.Product.*")
        
# pg_ltree queries
User.last.active_trees.last.parent
ActiveTree::Model.match_path("*.Category.*").children
    
# pg_ltree combined with AR syntax
User.last.active_trees(type: "Sellable::Product").children.match_path("*.Battery").children
    
# all queries can be directed to a specific partition:
ActiveTree::Model.owned_by( owner_id ).match_path("*.Category.*").where(currency: "USD").products.sum(:product_price)
    
```

To see what syntax to use for path traversal please check out the following resources:
* pg_ltree gem https://github.com/sjke/pg_ltree
* Postgres ltree extension documentation https://www.postgresql.org/docs/9.1/ltree.html

The ActiveTree gem is designed to be compatible with PostgREST. PostgREST is an amazing tool that generates a CRUD REST API for your Postgres database, read more about it here: https://postgrest.org

If the `create_postgrest_roles` setting is on each new owner will be assigned a Postgres role allowing them to access data within their partition using PostgREST. Your owner model will be extended with a `.generate_jwt` method you can use to generate the PostgREST authentication token.

## Metadata

The `ActiveTree::Model` comes with a JSONB column where you can store random information structured in any required way. Subclasses of the Model can implement methods to store/retrieve JSONB data as well as validations.

The `ActiveTree::Metadata` model can store key-value pairs queryable through ActiveRecord simple queries or joins:

```ruby
ActiveTree::Model.match_path("*.Battery.*").metadata.where(key: "Shipping weight").sum(:value)
```

## Partitioning

All data is partitioned for each owner using the owner_id as partition index. Through the yml configuration you can choose how the gem behaves when deleting an owner record - either delete the partition and all the data, or detach the partition and keep the data for later use.

Through subsequent ActiveRecord migrations the data can be federated from a separate Postgres server. 

The main table as well as its partitions can be queried through PostgREST using the role attached to the owner model.

## Caveats

`pg_ltree` .child / .parent queries do not work across different models due to an ActiveRecord limitation that requires results to be related via inheritance. 

## Roadmap

* postgres RECURSIVE queries
* builders
* seeds/fixtures


## Contributing

Bug reports, pull requests and feature suggestions are welcome on GitHub at https://github.com/nicksterious/active_tree

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

