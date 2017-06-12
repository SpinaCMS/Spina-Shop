# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170612093609) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "btree_gin"
  enable_extension "unaccent"

  create_table "spina_accounts", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "postal_code"
    t.string   "city"
    t.string   "phone"
    t.string   "email"
    t.text     "preferences"
    t.string   "logo"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "kvk_identifier"
    t.string   "vat_identifier"
    t.boolean  "robots_allowed", default: false
  end

  create_table "spina_attachment_collections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spina_attachment_collections_attachments", force: :cascade do |t|
    t.integer "attachment_collection_id"
    t.integer "attachment_id"
  end

  create_table "spina_attachments", force: :cascade do |t|
    t.string   "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spina_layout_parts", force: :cascade do |t|
    t.string   "title"
    t.string   "name"
    t.integer  "layout_partable_id"
    t.string   "layout_partable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "spina_line_translations", force: :cascade do |t|
    t.integer  "spina_line_id", null: false
    t.string   "locale",        null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "content"
    t.index ["locale"], name: "index_spina_line_translations_on_locale", using: :btree
    t.index ["spina_line_id"], name: "index_spina_line_translations_on_spina_line_id", using: :btree
  end

  create_table "spina_lines", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spina_navigation_items", force: :cascade do |t|
    t.integer  "page_id",                   null: false
    t.integer  "navigation_id",             null: false
    t.integer  "position",      default: 0, null: false
    t.string   "ancestry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["page_id", "navigation_id"], name: "index_spina_navigation_items_on_page_id_and_navigation_id", unique: true, using: :btree
  end

  create_table "spina_navigations", force: :cascade do |t|
    t.string   "name",                           null: false
    t.string   "label",                          null: false
    t.boolean  "auto_add_pages", default: false, null: false
    t.integer  "position",       default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_spina_navigations_on_name", unique: true, using: :btree
  end

  create_table "spina_options", force: :cascade do |t|
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spina_page_parts", force: :cascade do |t|
    t.string   "title"
    t.string   "name"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "page_id"
    t.integer  "page_partable_id"
    t.string   "page_partable_type"
  end

  create_table "spina_page_translations", force: :cascade do |t|
    t.integer  "spina_page_id",     null: false
    t.string   "locale",            null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "title"
    t.string   "menu_title"
    t.string   "description"
    t.string   "seo_title"
    t.string   "materialized_path"
    t.index ["locale"], name: "index_spina_page_translations_on_locale", using: :btree
    t.index ["spina_page_id"], name: "index_spina_page_translations_on_spina_page_id", using: :btree
  end

  create_table "spina_pages", force: :cascade do |t|
    t.boolean  "show_in_menu",        default: true
    t.string   "slug"
    t.boolean  "deletable",           default: true
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.boolean  "skip_to_first_child", default: false
    t.string   "view_template"
    t.string   "layout_template"
    t.boolean  "draft",               default: false
    t.string   "link_url"
    t.string   "ancestry"
    t.integer  "position"
    t.boolean  "active",              default: true
  end

  create_table "spina_photo_collections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spina_photo_collections_photos", force: :cascade do |t|
    t.integer "photo_collection_id"
    t.integer "photo_id"
    t.integer "position"
  end

  create_table "spina_photos", force: :cascade do |t|
    t.string   "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spina_rewrite_rules", force: :cascade do |t|
    t.string   "old_path"
    t.string   "new_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spina_shop_addresses", force: :cascade do |t|
    t.string   "address_type"
    t.integer  "customer_id"
    t.string   "postal_code"
    t.string   "city"
    t.integer  "country_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "house_number"
    t.string   "house_number_addition"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "street1"
    t.string   "name"
    t.string   "company"
    t.string   "street2"
    t.index ["country_id"], name: "idx_shop_addresses_on_country_id", using: :btree
    t.index ["customer_id"], name: "idx_shop_addresses_on_customer_id", using: :btree
  end

  create_table "spina_shop_bundled_product_items", force: :cascade do |t|
    t.integer  "product_item_id"
    t.integer  "product_bundle_id"
    t.integer  "quantity",          default: 0, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["product_bundle_id"], name: "idx_shop_bundled_product_items_on_product_bundle_id", using: :btree
    t.index ["product_item_id"], name: "idx_shop_bundled_product_items_on_product_item_id", using: :btree
  end

  create_table "spina_shop_countries", force: :cascade do |t|
    t.string   "name"
    t.string   "code2"
    t.boolean  "eu_member",  default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spina_shop_customer_accounts", force: :cascade do |t|
    t.integer  "customer_id",            null: false
    t.string   "email",                  null: false
    t.string   "password_digest",        null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.index ["customer_id"], name: "idx_shop_customer_accounts_on_customer_id", using: :btree
    t.index ["email"], name: "idx_shop_customer_accounts_on_email", unique: true, using: :btree
    t.index ["password_reset_token"], name: "idx_shop_customer_accounts_on_password_reset_token", unique: true, using: :btree
  end

  create_table "spina_shop_customers", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
    t.integer  "number"
    t.date     "date_of_birth"
    t.integer  "country_id"
    t.index ["country_id"], name: "idx_shop_customers_on_country_id", using: :btree
  end

  create_table "spina_shop_delivery_options", force: :cascade do |t|
    t.string   "name"
    t.string   "carrier"
    t.decimal  "price",             precision: 8, scale: 2, default: "0.0", null: false
    t.integer  "tax_group_id"
    t.integer  "sales_category_id"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.boolean  "requires_shipping",                         default: false, null: false
    t.string   "description"
    t.index ["sales_category_id"], name: "idx_shop_delivery_options_on_sales_category_id", using: :btree
    t.index ["tax_group_id"], name: "idx_shop_delivery_options_on_tax_group_id", using: :btree
  end

  create_table "spina_shop_discount_actions", force: :cascade do |t|
    t.integer  "discount_id"
    t.string   "type"
    t.text     "preferences"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["discount_id"], name: "idx_shop_discount_actions_on_discount_id", using: :btree
  end

  create_table "spina_shop_discount_rules", force: :cascade do |t|
    t.integer  "discount_id"
    t.string   "type"
    t.text     "preferences"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["discount_id"], name: "idx_shop_discount_rules_on_discount_id", using: :btree
  end

  create_table "spina_shop_discounts", force: :cascade do |t|
    t.string   "code",                                  null: false
    t.date     "starts_at",                             null: false
    t.date     "expires_at"
    t.integer  "usage_limit",    default: 0,            null: false
    t.integer  "discount_value"
    t.string   "discount_type",  default: "percentage"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "type"
    t.text     "preferences"
    t.text     "description"
    t.index ["code"], name: "idx_shop_discounts_on_code", unique: true, using: :btree
  end

  create_table "spina_shop_discounts_orders", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "discount_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["discount_id"], name: "idx_shop_discounts_orders_on_discount_id", using: :btree
    t.index ["order_id"], name: "idx_shop_discounts_orders_on_order_id", using: :btree
  end

  create_table "spina_shop_favorites", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "customer_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "spina_shop_gift_cards", force: :cascade do |t|
    t.string   "code",                                                      null: false
    t.date     "expires_at",                                                null: false
    t.decimal  "value",             precision: 8, scale: 2, default: "0.0", null: false
    t.decimal  "remaining_balance", precision: 8, scale: 2, default: "0.0", null: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.index ["code"], name: "idx_shop_gift_cards_on_code", unique: true, using: :btree
  end

  create_table "spina_shop_gift_cards_orders", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "gift_card_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["gift_card_id"], name: "idx_shop_gift_cards_orders_on_gift_card_id", using: :btree
    t.index ["order_id", "gift_card_id"], name: "idx_shop_gift_cards_orders_on_order_id_and_gift_card_id", unique: true, using: :btree
    t.index ["order_id"], name: "idx_shop_gift_cards_orders_on_order_id", using: :btree
  end

  create_table "spina_shop_in_stock_reminders", force: :cascade do |t|
    t.string   "email"
    t.integer  "orderable_id"
    t.string   "orderable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["orderable_id"], name: "idx_shop_in_stock_reminders_on_orderable_id", using: :btree
  end

  create_table "spina_shop_invoice_lines", force: :cascade do |t|
    t.integer  "invoice_id"
    t.text     "description",                                             null: false
    t.integer  "quantity",                                default: 1,     null: false
    t.decimal  "unit_price",      precision: 8, scale: 2, default: "0.0", null: false
    t.decimal  "tax_rate",        precision: 8, scale: 2, default: "0.0", null: false
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.jsonb    "metadata",                                default: "{}",  null: false
    t.decimal  "discount_amount", precision: 8, scale: 2, default: "0.0", null: false
    t.index ["invoice_id"], name: "idx_shop_invoice_lines_on_invoice_id", using: :btree
  end

  create_table "spina_shop_invoices", force: :cascade do |t|
    t.integer  "order_id",                           null: false
    t.integer  "customer_id",                        null: false
    t.integer  "number",                             null: false
    t.boolean  "prices_include_tax", default: false, null: false
    t.date     "date",                               null: false
    t.integer  "country_id",                         null: false
    t.integer  "order_number",                       null: false
    t.integer  "customer_number",                    null: false
    t.string   "company_name"
    t.string   "customer_name",                      null: false
    t.string   "address_1",                          null: false
    t.string   "address_2"
    t.string   "address_3"
    t.string   "address_4"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "postal_code"
    t.string   "city"
    t.text     "identity_details"
    t.string   "identity_name"
    t.string   "invoice_number"
    t.jsonb    "export_data",        default: "{}",  null: false
    t.boolean  "exported",           default: false, null: false
    t.string   "country_name"
    t.index ["country_id"], name: "idx_shop_invoices_on_country_id", using: :btree
    t.index ["customer_id"], name: "idx_shop_invoices_on_customer_id", using: :btree
    t.index ["invoice_number"], name: "idx_shop_invoices_on_invoice_number", unique: true, using: :btree
    t.index ["number"], name: "idx_shop_invoices_on_number", unique: true, using: :btree
    t.index ["order_id"], name: "idx_shop_invoices_on_order_id", using: :btree
  end

  create_table "spina_shop_number_sequences", force: :cascade do |t|
    t.string   "name",                    null: false
    t.integer  "next_number", default: 1, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "spina_shop_order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "quantity",                                default: 0,    null: false
    t.decimal  "tax_rate",        precision: 8, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "unit_price",      precision: 8, scale: 2
    t.decimal  "unit_cost_price", precision: 8, scale: 2
    t.decimal  "weight",          precision: 8, scale: 3
    t.string   "orderable_type"
    t.integer  "orderable_id"
    t.jsonb    "metadata",                                default: "{}", null: false
    t.decimal  "discount_amount", precision: 8, scale: 2
    t.index ["order_id"], name: "idx_shop_order_items_on_order_id", using: :btree
    t.index ["orderable_id"], name: "idx_shop_order_items_on_orderable_id", using: :btree
  end

  create_table "spina_shop_order_transitions", force: :cascade do |t|
    t.string   "to_state",                 null: false
    t.json     "metadata",    default: {}
    t.integer  "sort_key",                 null: false
    t.integer  "order_id",                 null: false
    t.boolean  "most_recent",              null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["order_id", "most_recent"], name: "index_order_transitions_parent_most_recent", unique: true, where: "most_recent", using: :btree
    t.index ["order_id", "sort_key"], name: "index_order_transitions_parent_sort", unique: true, using: :btree
  end

  create_table "spina_shop_orders", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company"
    t.string   "email"
    t.string   "phone"
    t.string   "status"
    t.datetime "received_at"
    t.datetime "shipped_at"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "billing_country_id"
    t.boolean  "prices_include_tax",                                     default: false, null: false
    t.integer  "order_number"
    t.datetime "paid_at"
    t.datetime "delivered_at"
    t.datetime "order_picked_at"
    t.string   "delivery_postal_code"
    t.string   "delivery_city"
    t.integer  "delivery_country_id"
    t.boolean  "separate_delivery_address",                              default: false
    t.string   "billing_postal_code"
    t.string   "billing_city"
    t.string   "payment_id"
    t.datetime "failed_at"
    t.string   "payment_url"
    t.string   "payment_method"
    t.integer  "billing_house_number"
    t.string   "billing_house_number_addition"
    t.string   "ip_address"
    t.integer  "user_id"
    t.boolean  "pos",                                                    default: false, null: false
    t.string   "payment_issuer"
    t.integer  "delivery_house_number"
    t.string   "delivery_house_number_addition"
    t.date     "date_of_birth"
    t.integer  "delivery_option_id"
    t.string   "delivery_tracking_ids",                                                               array: true
    t.datetime "picked_up_at"
    t.decimal  "delivery_price",                 precision: 8, scale: 2
    t.decimal  "delivery_tax_rate",              precision: 8, scale: 2
    t.datetime "cancelled_at"
    t.datetime "confirming_at"
    t.integer  "duplicate_id"
    t.string   "billing_street1"
    t.string   "delivery_street1"
    t.string   "delivery_name"
    t.string   "billing_street2"
    t.string   "delivery_street2"
    t.jsonb    "delivery_metadata",                                      default: "{}",  null: false
    t.text     "note"
    t.string   "token"
    t.integer  "zone_id"
    t.index ["billing_country_id"], name: "idx_shop_orders_on_billing_country_id", using: :btree
    t.index ["order_number"], name: "idx_shop_orders_on_order_number", unique: true, using: :btree
  end

  create_table "spina_shop_product_bundle_parts", force: :cascade do |t|
    t.integer  "product_bundle_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "spina_shop_product_bundles", force: :cascade do |t|
    t.string   "name"
    t.decimal  "price",                 precision: 8, scale: 2
    t.boolean  "tax_included_in_price",                         default: true,  null: false
    t.integer  "tax_group_id"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.text     "description"
    t.integer  "sales_category_id"
    t.boolean  "must_be_of_age_to_buy",                         default: false
    t.index ["sales_category_id"], name: "idx_shop_product_bundles_on_sales_category_id", using: :btree
    t.index ["tax_group_id"], name: "idx_shop_product_bundles_on_tax_group_id", using: :btree
  end

  create_table "spina_shop_product_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "review_categories"
  end

  create_table "spina_shop_product_category_properties", force: :cascade do |t|
    t.string   "name"
    t.string   "property_type"
    t.boolean  "required",            default: false, null: false
    t.integer  "product_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "field_type"
    t.decimal  "minimum"
    t.decimal  "maximum"
    t.integer  "max_characters"
    t.boolean  "multiple",            default: false, null: false
    t.string   "prepend"
    t.string   "append"
    t.text     "options"
    t.string   "label"
    t.index ["product_category_id"], name: "idx_shop_product_category_properties_on_product_category_id", using: :btree
  end

  create_table "spina_shop_product_images", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alt_description"
    t.integer  "position"
    t.integer  "product_item_id"
    t.integer  "product_bundle_id"
    t.index ["product_bundle_id"], name: "idx_shop_product_images_on_product_bundle_id", using: :btree
    t.index ["product_id"], name: "idx_shop_product_images_on_product_id", using: :btree
    t.index ["product_item_id"], name: "idx_shop_product_images_on_product_item_id", using: :btree
  end

  create_table "spina_shop_product_items", force: :cascade do |t|
    t.string   "sku"
    t.string   "location"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tax_group_id"
    t.boolean  "tax_included_in_price",                         default: true,  null: false
    t.jsonb    "properties",                                    default: "{}",  null: false
    t.decimal  "weight",                precision: 8, scale: 3
    t.decimal  "price",                 precision: 8, scale: 2
    t.decimal  "cost_price",            precision: 8, scale: 2
    t.string   "ean"
    t.integer  "sales_category_id"
    t.boolean  "must_be_of_age_to_buy",                         default: false
    t.string   "name"
    t.boolean  "can_expire",                                    default: false, null: false
    t.date     "expiration_date"
    t.integer  "stock_level",                                   default: 0,     null: false
    t.string   "supplier_reference"
    t.boolean  "active",                                        default: false, null: false
    t.index ["product_id"], name: "idx_shop_product_items_on_product_id", using: :btree
    t.index ["sales_category_id"], name: "idx_shop_product_items_on_sales_category_id", using: :btree
    t.index ["tax_group_id"], name: "idx_shop_product_items_on_tax_group_id", using: :btree
  end

  create_table "spina_shop_product_parts", force: :cascade do |t|
    t.integer  "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spina_shop_product_relations", force: :cascade do |t|
    t.integer "product_id"
    t.integer "related_product_id"
    t.index ["product_id"], name: "idx_shop_product_relations_on_product_id", using: :btree
    t.index ["related_product_id"], name: "idx_shop_product_relations_on_related_product_id", using: :btree
  end

  create_table "spina_shop_product_reviews", force: :cascade do |t|
    t.integer  "customer_id"
    t.text     "review"
    t.string   "author"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.text     "review_summary"
    t.string   "email"
    t.decimal  "score",          precision: 3, scale: 1
    t.integer  "product_id"
    t.integer  "shop_review_id"
    t.index ["customer_id"], name: "idx_shop_product_reviews_on_customer_id", using: :btree
    t.index ["product_id"], name: "idx_shop_product_reviews_on_product_id", using: :btree
  end

  create_table "spina_shop_product_translations", force: :cascade do |t|
    t.integer  "spina_shop_product_id", null: false
    t.string   "locale",                null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "name"
    t.text     "description"
    t.string   "seo_title"
    t.string   "seo_description"
    t.string   "materialized_path"
    t.index ["locale"], name: "idx_shop_product_translations_on_locale", using: :btree
    t.index ["spina_shop_product_id"], name: "idx_shop_product_translations_on_spina_product_id", using: :btree
  end

  create_table "spina_shop_products", force: :cascade do |t|
    t.integer  "product_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.jsonb    "properties",                                   default: "{}",  null: false
    t.string   "name"
    t.float    "average_review_score"
    t.integer  "sales_count"
    t.decimal  "lowest_price",         precision: 8, scale: 2
    t.string   "supplier"
    t.boolean  "active",                                       default: false, null: false
    t.index ["name"], name: "idx_shop_products_on_name", using: :gin
    t.index ["product_category_id"], name: "idx_shop_products_on_product_category_id", using: :btree
  end

  create_table "spina_shop_sales_categories", force: :cascade do |t|
    t.string   "name"
    t.jsonb    "codes",      default: "{}", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.jsonb    "metadata",   default: "{}", null: false
  end

  create_table "spina_shop_shop_reviews", force: :cascade do |t|
    t.string   "author"
    t.text     "review_pros"
    t.text     "review_cons"
    t.decimal  "score"
    t.decimal  "score_communication"
    t.decimal  "score_speed"
    t.integer  "order_id"
    t.integer  "customer_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "email"
  end

  create_table "spina_shop_stock_level_adjustments", force: :cascade do |t|
    t.integer  "product_item_id"
    t.integer  "order_item_id"
    t.integer  "adjustment",       default: 0, null: false
    t.text     "description"
    t.string   "actor"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "expiration_month"
    t.integer  "expiration_year"
    t.index ["order_item_id"], name: "idx_shop_stock_level_adjustments_on_order_item_id", using: :btree
    t.index ["product_item_id"], name: "idx_shop_stock_level_adjustments_on_product_item_id", using: :btree
  end

  create_table "spina_shop_tax_groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.jsonb    "tax_rates",  default: "{}", null: false
    t.jsonb    "metadata",   default: "{}", null: false
  end

  create_table "spina_shop_tax_rates", force: :cascade do |t|
    t.integer  "tax_group_id"
    t.decimal  "rate",              precision: 8, scale: 2, default: "0.0", null: false
    t.string   "code"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "tax_rateable_type"
    t.integer  "tax_rateable_id"
    t.index ["tax_group_id"], name: "index_spina_shop_tax_rates_on_tax_group_id", using: :btree
    t.index ["tax_rateable_type", "tax_rateable_id"], name: "spina_tax_rates_tax_rateable_index", using: :btree
  end

  create_table "spina_shop_zones", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "zone_type",  null: false
    t.integer  "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spina_structure_items", force: :cascade do |t|
    t.integer  "structure_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["structure_id"], name: "index_spina_structure_items_on_structure_id", using: :btree
  end

  create_table "spina_structure_parts", force: :cascade do |t|
    t.integer  "structure_item_id"
    t.integer  "structure_partable_id"
    t.string   "structure_partable_type"
    t.string   "name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["structure_item_id"], name: "index_spina_structure_parts_on_structure_item_id", using: :btree
    t.index ["structure_partable_id"], name: "index_spina_structure_parts_on_structure_partable_id", using: :btree
  end

  create_table "spina_structures", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spina_text_translations", force: :cascade do |t|
    t.integer  "spina_text_id", null: false
    t.string   "locale",        null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.text     "content"
    t.index ["locale"], name: "index_spina_text_translations_on_locale", using: :btree
    t.index ["spina_text_id"], name: "index_spina_text_translations_on_spina_text_id", using: :btree
  end

  create_table "spina_texts", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spina_users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.boolean  "admin",                  default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.datetime "last_logged_in"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  add_foreign_key "spina_shop_addresses", "spina_shop_countries", column: "country_id"
  add_foreign_key "spina_shop_addresses", "spina_shop_customers", column: "customer_id"
  add_foreign_key "spina_shop_bundled_product_items", "spina_shop_product_bundles", column: "product_bundle_id"
  add_foreign_key "spina_shop_bundled_product_items", "spina_shop_product_items", column: "product_item_id"
  add_foreign_key "spina_shop_customer_accounts", "spina_shop_customers", column: "customer_id"
  add_foreign_key "spina_shop_customers", "spina_shop_countries", column: "country_id"
  add_foreign_key "spina_shop_delivery_options", "spina_shop_sales_categories", column: "sales_category_id"
  add_foreign_key "spina_shop_delivery_options", "spina_shop_tax_groups", column: "tax_group_id"
  add_foreign_key "spina_shop_invoice_lines", "spina_shop_invoices", column: "invoice_id"
  add_foreign_key "spina_shop_invoices", "spina_shop_countries", column: "country_id"
  add_foreign_key "spina_shop_invoices", "spina_shop_customers", column: "customer_id"
  add_foreign_key "spina_shop_invoices", "spina_shop_orders", column: "order_id"
  add_foreign_key "spina_shop_order_items", "spina_shop_orders", column: "order_id"
  add_foreign_key "spina_shop_order_transitions", "spina_shop_orders", column: "order_id"
  add_foreign_key "spina_shop_orders", "spina_shop_countries", column: "billing_country_id"
  add_foreign_key "spina_shop_product_bundles", "spina_shop_sales_categories", column: "sales_category_id"
  add_foreign_key "spina_shop_product_bundles", "spina_shop_tax_groups", column: "tax_group_id"
  add_foreign_key "spina_shop_product_category_properties", "spina_shop_product_categories", column: "product_category_id"
  add_foreign_key "spina_shop_product_items", "spina_shop_products", column: "product_id"
  add_foreign_key "spina_shop_product_items", "spina_shop_sales_categories", column: "sales_category_id"
  add_foreign_key "spina_shop_product_items", "spina_shop_tax_groups", column: "tax_group_id"
  add_foreign_key "spina_shop_product_relations", "spina_shop_products", column: "product_id"
  add_foreign_key "spina_shop_product_relations", "spina_shop_products", column: "related_product_id"
  add_foreign_key "spina_shop_product_translations", "spina_shop_products"
  add_foreign_key "spina_shop_products", "spina_shop_product_categories", column: "product_category_id"
  add_foreign_key "spina_shop_stock_level_adjustments", "spina_shop_product_items", column: "product_item_id"
end
