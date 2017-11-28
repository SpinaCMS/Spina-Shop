# Spina::Shop
Note: we're still working on docs. For now, here's a quick summary of a conversion in our Slack channel:


Feel free to poke around, I just wouldn’t recommend using it for real projects yet
There’s no docs yet and we have to extract our tests from our private repos
If you want to see what it looks like, simply add the gem to your Spina app and install the migrations
No additional steps required
To create products and orders you need to setup a couple of models though:
you should have at least one `Spina::Shop::Country` (edited)
one `Spina::Shop::TaxGroup` which has at least one `Spina::Shop::TaxRate` (edited)
and one `Spina::Shop::SalesCategory` (edited)
These are necessary to create proper invoices and export data for accountancy software
Spina::Shop::Country is a descendant of Spina::Shop::Zone, which can be nested
For example: `Spina::Shop::Zone(name: "EU", code: "EU")` has many countries like `Spina::Shop::Country(name: "the Netherlands", code: "NL")` (edited)
If you do try it out: expect things to change. We’re currently messing with the way giftcards are applied for example.
Products by default have a couple of fields like `title` and `description`, but it’s also possible to add a wide variety of custom properties like PageParts for pages
They are all stored in a `jsonb` column, so Postgres is required
Products can belong to a `Spina::Shop::ProductCategory`
Each product category can have multiple `properties` which define the properties your products can have
A property can have a field_type. These are currently supported:
- select
- product
- textarea
- image
fallback: regular text_field

The select property can have a single value or multiple (it’ll work with tags or a dropdown)
