# Getting Started

Prerequisites:

- Spina installation

**Installation**

Add `gem 'spina-shop'` to your Gemfile and run the `bundle` command to install it.

Run `rails spina_shop:install:migrations` to add all required migrations and run `rails db:migrate` to create the tables.

**Overview**

Let's begin with an overview of the overall structure of Spina Shop. There's lots of models (a lot more than in Spina CMS alone).

Store 1 --> * Products

ProductBundles * <--> * Products
ProductCollections * <--> * Products
Countries (Zone) --> Orders, Customers, TaxRates, SalesCategories


SalesCategory