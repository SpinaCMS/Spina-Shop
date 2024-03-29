# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_11_22_131227) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "citext"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "spina_accounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "postal_code"
    t.string "city"
    t.string "phone"
    t.string "email"
    t.text "preferences"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "robots_allowed", default: false
    t.jsonb "json_attributes"
  end

  create_table "spina_attachment_collections", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_attachment_collections_attachments", id: :serial, force: :cascade do |t|
    t.integer "attachment_collection_id"
    t.integer "attachment_id"
  end

  create_table "spina_attachments", id: :serial, force: :cascade do |t|
    t.string "file"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_image_collections", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_image_collections_images", id: :serial, force: :cascade do |t|
    t.integer "image_collection_id"
    t.integer "image_id"
    t.integer "position"
    t.index ["image_collection_id"], name: "index_spina_image_collections_images_on_image_collection_id"
    t.index ["image_id"], name: "index_spina_image_collections_images_on_image_id"
  end

  create_table "spina_images", force: :cascade do |t|
    t.integer "media_folder_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["media_folder_id"], name: "index_spina_images_on_media_folder_id"
  end

  create_table "spina_layout_parts", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "name"
    t.integer "layout_partable_id"
    t.string "layout_partable_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "account_id"
  end

  create_table "spina_line_translations", id: :serial, force: :cascade do |t|
    t.integer "spina_line_id", null: false
    t.string "locale", null: false
    t.string "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["locale"], name: "index_spina_line_translations_on_locale"
    t.index ["spina_line_id"], name: "index_spina_line_translations_on_spina_line_id"
  end

  create_table "spina_lines", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "spina_media_folders", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_navigation_items", id: :serial, force: :cascade do |t|
    t.integer "page_id"
    t.integer "navigation_id", null: false
    t.integer "position", default: 0, null: false
    t.string "ancestry"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "url"
    t.string "url_title"
    t.string "kind", default: "page", null: false
    t.index ["page_id", "navigation_id"], name: "index_spina_navigation_items_on_page_id_and_navigation_id", unique: true
  end

  create_table "spina_navigations", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "label", null: false
    t.boolean "auto_add_pages", default: false, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name"], name: "index_spina_navigations_on_name", unique: true
  end

  create_table "spina_options", id: :serial, force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_page_parts", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "page_id"
    t.integer "page_partable_id"
    t.string "page_partable_type"
  end

  create_table "spina_page_translations", id: :serial, force: :cascade do |t|
    t.integer "spina_page_id", null: false
    t.string "locale", null: false
    t.string "title"
    t.string "menu_title"
    t.string "description"
    t.string "seo_title"
    t.string "materialized_path"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "url_title"
    t.index ["locale"], name: "index_spina_page_translations_on_locale"
    t.index ["spina_page_id"], name: "index_spina_page_translations_on_spina_page_id"
  end

  create_table "spina_pages", id: :serial, force: :cascade do |t|
    t.boolean "show_in_menu", default: true
    t.string "slug"
    t.boolean "deletable", default: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.boolean "skip_to_first_child", default: false
    t.string "view_template"
    t.string "layout_template"
    t.boolean "draft", default: false
    t.string "link_url"
    t.string "ancestry"
    t.integer "position"
    t.boolean "active", default: true
    t.integer "resource_id"
    t.jsonb "json_attributes"
    t.integer "ancestry_depth", default: 0
    t.integer "ancestry_children_count"
    t.index ["resource_id"], name: "index_spina_pages_on_resource_id"
  end

  create_table "spina_resources", force: :cascade do |t|
    t.string "name", null: false
    t.string "label"
    t.string "view_template"
    t.string "order_by"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "slug"
  end

  create_table "spina_rewrite_rules", id: :serial, force: :cascade do |t|
    t.string "old_path"
    t.string "new_path"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "spina_settings", id: :serial, force: :cascade do |t|
    t.string "plugin"
    t.jsonb "preferences", default: {}
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["plugin"], name: "index_spina_settings_on_plugin"
  end

  create_table "spina_shop_addresses", id: :serial, force: :cascade do |t|
    t.string "address_type"
    t.integer "customer_id"
    t.string "postal_code"
    t.string "city"
    t.integer "country_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "house_number"
    t.string "house_number_addition"
    t.string "first_name"
    t.string "last_name"
    t.string "street1"
    t.string "name"
    t.string "company"
    t.string "street2"
    t.index ["country_id"], name: "idx_shop_addresses_on_country_id"
    t.index ["customer_id"], name: "idx_shop_addresses_on_customer_id"
  end

  create_table "spina_shop_available_products", force: :cascade do |t|
    t.integer "product_id"
    t.integer "store_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["product_id"], name: "index_spina_shop_available_products_on_product_id"
    t.index ["store_id"], name: "index_spina_shop_available_products_on_store_id"
  end

  create_table "spina_shop_bundled_products", force: :cascade do |t|
    t.integer "product_id"
    t.integer "product_bundle_id"
    t.integer "quantity", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["product_bundle_id"], name: "index_spina_shop_bundled_products_on_product_bundle_id"
    t.index ["product_id"], name: "index_spina_shop_bundled_products_on_product_id"
  end

  create_table "spina_shop_collectables", force: :cascade do |t|
    t.integer "product_id"
    t.integer "product_collection_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["product_collection_id"], name: "index_spina_shop_collectables_on_product_collection_id"
    t.index ["product_id"], name: "index_spina_shop_collectables_on_product_id"
  end

  create_table "spina_shop_countries", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "code2"
    t.boolean "eu_member", default: false, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "spina_shop_custom_products", force: :cascade do |t|
    t.string "name"
    t.decimal "price", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "tax_group_id"
    t.integer "sales_category_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["sales_category_id"], name: "index_spina_shop_custom_products_on_sales_category_id"
    t.index ["tax_group_id"], name: "index_spina_shop_custom_products_on_tax_group_id"
  end

  create_table "spina_shop_customer_accounts", id: :serial, force: :cascade do |t|
    t.integer "customer_id", null: false
    t.citext "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at", precision: nil
    t.integer "store_id"
    t.string "magic_link_token"
    t.datetime "magic_link_sent_at", precision: nil
    t.index ["customer_id"], name: "idx_shop_customer_accounts_on_customer_id"
    t.index ["email", "store_id"], name: "index_spina_shop_customer_accounts_on_email_and_store_id", unique: true
    t.index ["password_reset_token"], name: "idx_shop_customer_accounts_on_password_reset_token", unique: true
    t.index ["store_id"], name: "index_spina_shop_customer_accounts_on_store_id"
  end

  create_table "spina_shop_customer_groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "parent_id"
    t.integer "store_id"
    t.index ["parent_id"], name: "index_spina_shop_customer_groups_on_parent_id"
    t.index ["store_id"], name: "index_spina_shop_customer_groups_on_store_id"
  end

  create_table "spina_shop_customers", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "company"
    t.citext "email"
    t.string "phone"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "full_name"
    t.integer "number"
    t.date "date_of_birth"
    t.integer "country_id"
    t.integer "customer_group_id"
    t.string "vat_id"
    t.integer "store_id"
    t.boolean "postpay_allowed", default: false, null: false
    t.citext "billing_email"
    t.index ["country_id"], name: "idx_shop_customers_on_country_id"
    t.index ["customer_group_id"], name: "index_spina_shop_customers_on_customer_group_id"
    t.index ["store_id"], name: "index_spina_shop_customers_on_store_id"
  end

  create_table "spina_shop_delivery_options", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "carrier"
    t.decimal "price", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "tax_group_id"
    t.integer "sales_category_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "requires_shipping", default: false, null: false
    t.string "description"
    t.boolean "price_includes_tax", default: true, null: false
    t.index ["sales_category_id"], name: "idx_shop_delivery_options_on_sales_category_id"
    t.index ["tax_group_id"], name: "idx_shop_delivery_options_on_tax_group_id"
  end

  create_table "spina_shop_discount_actions", id: :serial, force: :cascade do |t|
    t.integer "discount_id"
    t.string "type"
    t.text "preferences"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["discount_id"], name: "idx_shop_discount_actions_on_discount_id"
  end

  create_table "spina_shop_discount_requirements", force: :cascade do |t|
    t.integer "discount_id"
    t.string "type"
    t.text "preferences"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["discount_id"], name: "index_spina_shop_discount_requirements_on_discount_id"
  end

  create_table "spina_shop_discount_rules", id: :serial, force: :cascade do |t|
    t.integer "discount_id"
    t.string "type"
    t.text "preferences"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["discount_id"], name: "idx_shop_discount_rules_on_discount_id"
  end

  create_table "spina_shop_discounts", id: :serial, force: :cascade do |t|
    t.citext "code", null: false
    t.date "starts_at", null: false
    t.date "expires_at"
    t.integer "usage_limit", default: 0, null: false
    t.integer "discount_value"
    t.string "discount_type", default: "percentage"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "type"
    t.text "preferences"
    t.text "description"
    t.boolean "auto", default: false, null: false
    t.index ["code"], name: "idx_shop_discounts_on_code", unique: true
  end

  create_table "spina_shop_discounts_orders", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "discount_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["discount_id"], name: "idx_shop_discounts_orders_on_discount_id"
    t.index ["order_id"], name: "idx_shop_discounts_orders_on_order_id"
  end

  create_table "spina_shop_favorites", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.integer "customer_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_shop_gift_cards", id: :serial, force: :cascade do |t|
    t.citext "code", null: false
    t.date "expires_at", null: false
    t.decimal "value", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "remaining_balance", precision: 8, scale: 2, default: "0.0", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["code"], name: "idx_shop_gift_cards_on_code", unique: true
  end

  create_table "spina_shop_gift_cards_orders", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "gift_card_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["gift_card_id"], name: "idx_shop_gift_cards_orders_on_gift_card_id"
    t.index ["order_id", "gift_card_id"], name: "idx_shop_gift_cards_orders_on_order_id_and_gift_card_id", unique: true
    t.index ["order_id"], name: "idx_shop_gift_cards_orders_on_order_id"
  end

  create_table "spina_shop_in_stock_reminders", id: :serial, force: :cascade do |t|
    t.citext "email"
    t.integer "orderable_id"
    t.string "orderable_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["orderable_id"], name: "idx_shop_in_stock_reminders_on_orderable_id"
  end

  create_table "spina_shop_invoice_lines", id: :serial, force: :cascade do |t|
    t.integer "invoice_id"
    t.text "description", null: false
    t.integer "quantity", default: 1, null: false
    t.decimal "unit_price", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "tax_rate", precision: 8, scale: 2, default: "0.0", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "metadata", default: "{}", null: false
    t.decimal "discount_amount", precision: 8, scale: 2, default: "0.0", null: false
    t.decimal "discount", precision: 8, scale: 2, default: "0.0", null: false
    t.index ["invoice_id"], name: "idx_shop_invoice_lines_on_invoice_id"
  end

  create_table "spina_shop_invoices", id: :serial, force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "customer_id", null: false
    t.integer "number", null: false
    t.boolean "prices_include_tax", default: false, null: false
    t.date "date", null: false
    t.integer "country_id", null: false
    t.integer "order_number", null: false
    t.integer "customer_number", null: false
    t.string "company_name"
    t.string "customer_name", null: false
    t.string "address_1", null: false
    t.string "address_2"
    t.string "address_3"
    t.string "address_4"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "postal_code"
    t.string "city"
    t.text "identity_details"
    t.string "identity_name"
    t.string "invoice_number"
    t.jsonb "export_data", default: "{}", null: false
    t.boolean "exported", default: false, null: false
    t.string "country_name"
    t.string "vat_id"
    t.boolean "vat_reverse_charge", default: false, null: false
    t.string "reference"
    t.boolean "paid", default: true, null: false
    t.index ["country_id"], name: "idx_shop_invoices_on_country_id"
    t.index ["customer_id"], name: "idx_shop_invoices_on_customer_id"
    t.index ["invoice_number"], name: "idx_shop_invoices_on_invoice_number", unique: true
    t.index ["number"], name: "idx_shop_invoices_on_number", unique: true
    t.index ["order_id"], name: "idx_shop_invoices_on_order_id"
  end

  create_table "spina_shop_location_codes", force: :cascade do |t|
    t.string "code", null: false
    t.integer "location_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["location_id"], name: "index_spina_shop_location_codes_on_location_id"
  end

  create_table "spina_shop_locations", force: :cascade do |t|
    t.string "name"
    t.boolean "primary", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_shop_number_sequences", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "next_number", default: 1, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_shop_order_attachments", force: :cascade do |t|
    t.string "name"
    t.integer "order_id"
    t.string "attachment_id"
    t.string "attachment_filename"
    t.string "attachment_size"
    t.string "attachment_content_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["order_id"], name: "index_spina_shop_order_attachments_on_order_id"
  end

  create_table "spina_shop_order_items", id: :serial, force: :cascade do |t|
    t.integer "order_id"
    t.integer "quantity", default: 0, null: false
    t.decimal "tax_rate", precision: 8, scale: 2
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.decimal "unit_price", precision: 8, scale: 2
    t.decimal "unit_cost_price", precision: 8, scale: 2
    t.decimal "weight", precision: 8, scale: 3
    t.string "orderable_type"
    t.integer "orderable_id"
    t.jsonb "metadata", default: "{}", null: false
    t.decimal "discount_amount", precision: 8, scale: 2
    t.integer "parent_id"
    t.index ["order_id", "orderable_id", "orderable_type"], name: "spina_shop_unique_order_items_orderable", unique: true
    t.index ["order_id"], name: "idx_shop_order_items_on_order_id"
    t.index ["orderable_id"], name: "idx_shop_order_items_on_orderable_id"
    t.index ["parent_id"], name: "index_spina_shop_order_items_on_parent_id"
  end

  create_table "spina_shop_order_pick_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "order_item_id", null: false
    t.integer "quantity", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["order_id"], name: "index_spina_shop_order_pick_items_on_order_id"
    t.index ["order_item_id"], name: "index_spina_shop_order_pick_items_on_order_item_id"
    t.index ["product_id"], name: "index_spina_shop_order_pick_items_on_product_id"
  end

  create_table "spina_shop_order_transitions", id: :serial, force: :cascade do |t|
    t.string "to_state", null: false
    t.json "metadata", default: {}
    t.integer "sort_key", null: false
    t.integer "order_id", null: false
    t.boolean "most_recent", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["order_id", "most_recent"], name: "index_order_transitions_parent_most_recent", unique: true, where: "most_recent"
    t.index ["order_id", "sort_key"], name: "index_order_transitions_parent_sort", unique: true
  end

  create_table "spina_shop_ordered_stock", force: :cascade do |t|
    t.integer "stock_order_id"
    t.integer "product_id"
    t.integer "quantity", null: false
    t.integer "received", default: 0, null: false
    t.index ["product_id"], name: "index_spina_shop_ordered_stock_on_product_id"
    t.index ["stock_order_id"], name: "index_spina_shop_ordered_stock_on_stock_order_id"
  end

  create_table "spina_shop_orders", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "company"
    t.citext "email"
    t.string "phone"
    t.string "status"
    t.datetime "received_at", precision: nil
    t.datetime "shipped_at", precision: nil
    t.integer "customer_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "billing_country_id"
    t.boolean "prices_include_tax", default: false, null: false
    t.integer "order_number"
    t.datetime "paid_at", precision: nil
    t.datetime "delivered_at", precision: nil
    t.datetime "order_prepared_at", precision: nil
    t.string "delivery_postal_code"
    t.string "delivery_city"
    t.integer "delivery_country_id"
    t.boolean "separate_delivery_address", default: false
    t.string "billing_postal_code"
    t.string "billing_city"
    t.string "payment_id"
    t.datetime "failed_at", precision: nil
    t.string "payment_url"
    t.string "payment_method"
    t.integer "billing_house_number"
    t.string "billing_house_number_addition"
    t.string "ip_address"
    t.integer "user_id"
    t.boolean "pos", default: false, null: false
    t.string "payment_issuer"
    t.integer "delivery_house_number"
    t.string "delivery_house_number_addition"
    t.date "date_of_birth"
    t.integer "delivery_option_id"
    t.string "delivery_tracking_ids", array: true
    t.datetime "picked_up_at", precision: nil
    t.decimal "delivery_price", precision: 8, scale: 2
    t.decimal "delivery_tax_rate", precision: 8, scale: 2
    t.datetime "cancelled_at", precision: nil
    t.datetime "confirming_at", precision: nil
    t.integer "duplicate_id"
    t.string "billing_street1"
    t.string "delivery_street1"
    t.string "delivery_name"
    t.string "billing_street2"
    t.string "delivery_street2"
    t.jsonb "delivery_metadata", default: "{}", null: false
    t.text "note"
    t.string "token"
    t.boolean "business", default: false, null: false
    t.string "reference"
    t.decimal "gift_card_amount", precision: 8, scale: 2
    t.integer "store_id"
    t.string "delivery_first_name"
    t.string "delivery_last_name"
    t.string "delivery_company"
    t.datetime "payment_reminder_sent_at", precision: nil
    t.boolean "manual_entry", default: false, null: false
    t.datetime "refunded_at", precision: nil
    t.string "refund_method"
    t.string "refund_reason"
    t.datetime "ready_for_pickup_at", precision: nil
    t.datetime "ready_for_shipment_at", precision: nil
    t.index ["billing_country_id"], name: "idx_shop_orders_on_billing_country_id"
    t.index ["order_number"], name: "idx_shop_orders_on_order_number", unique: true
    t.index ["store_id"], name: "index_spina_shop_orders_on_store_id"
  end

  create_table "spina_shop_product_bundle_parts", id: :serial, force: :cascade do |t|
    t.integer "product_bundle_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_shop_product_bundle_translations", force: :cascade do |t|
    t.integer "spina_shop_product_bundle_id", null: false
    t.string "locale", null: false
    t.string "name"
    t.text "description"
    t.string "seo_title"
    t.string "seo_description"
    t.string "materialized_path"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["locale"], name: "index_spina_shop_product_bundle_translations_on_locale"
    t.index ["spina_shop_product_bundle_id"], name: "product_bundle_tranlations_index"
  end

  create_table "spina_shop_product_bundles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.decimal "price", precision: 8, scale: 2
    t.boolean "tax_included_in_price", default: true, null: false
    t.integer "tax_group_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "description"
    t.integer "sales_category_id"
    t.boolean "must_be_of_age_to_buy", default: false
    t.integer "limit_per_order"
    t.boolean "active", default: false, null: false
    t.decimal "original_price", precision: 8, scale: 2
    t.boolean "archived", default: false, null: false
    t.index ["sales_category_id"], name: "idx_shop_product_bundles_on_sales_category_id"
    t.index ["tax_group_id"], name: "idx_shop_product_bundles_on_tax_group_id"
  end

  create_table "spina_shop_product_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "review_categories"
  end

  create_table "spina_shop_product_category_parts", force: :cascade do |t|
    t.integer "product_category_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["product_category_id"], name: "index_spina_shop_product_category_parts_on_product_category_id"
  end

  create_table "spina_shop_product_category_properties", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "property_type"
    t.boolean "required", default: false, null: false
    t.integer "product_category_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "field_type"
    t.decimal "minimum"
    t.decimal "maximum"
    t.integer "max_characters"
    t.boolean "multiple", default: false, null: false
    t.string "prepend"
    t.string "append"
    t.text "options"
    t.string "label"
    t.boolean "editable", default: false, null: false
    t.boolean "editable_options", default: false, null: false
    t.integer "shared_property_id"
    t.index ["product_category_id"], name: "idx_shop_product_category_properties_on_product_category_id"
    t.index ["shared_property_id"], name: "sp_pro_cat_pr_index_shared_pr"
  end

  create_table "spina_shop_product_collections", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_shop_product_images", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.string "file_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "alt_description"
    t.integer "position"
    t.integer "product_item_id"
    t.integer "product_bundle_id"
    t.string "file_filename"
    t.integer "file_size"
    t.string "file_content_type"
    t.index ["product_bundle_id"], name: "idx_shop_product_images_on_product_bundle_id"
    t.index ["product_id"], name: "idx_shop_product_images_on_product_id"
    t.index ["product_item_id"], name: "idx_shop_product_images_on_product_item_id"
  end

  create_table "spina_shop_product_items", id: :serial, force: :cascade do |t|
    t.string "sku"
    t.string "location"
    t.integer "product_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "tax_group_id"
    t.boolean "tax_included_in_price", default: true, null: false
    t.jsonb "properties", default: "{}", null: false
    t.decimal "weight", precision: 8, scale: 3
    t.decimal "price", precision: 8, scale: 2
    t.decimal "cost_price", precision: 8, scale: 2
    t.string "ean"
    t.integer "sales_category_id"
    t.boolean "must_be_of_age_to_buy", default: false
    t.string "name"
    t.boolean "can_expire", default: false, null: false
    t.date "expiration_date"
    t.integer "stock_level", default: 0, null: false
    t.string "supplier_reference"
    t.boolean "active", default: false, null: false
    t.index ["product_id"], name: "idx_shop_product_items_on_product_id"
    t.index ["sales_category_id"], name: "idx_shop_product_items_on_sales_category_id"
    t.index ["tax_group_id"], name: "idx_shop_product_items_on_tax_group_id"
  end

  create_table "spina_shop_product_locations", force: :cascade do |t|
    t.integer "product_id"
    t.integer "location_id"
    t.string "location_code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "location_code_id"
    t.integer "stock_level", default: 0, null: false
    t.index ["location_code_id"], name: "index_spina_shop_product_locations_on_location_code_id"
    t.index ["location_id"], name: "index_spina_shop_product_locations_on_location_id"
    t.index ["product_id"], name: "index_spina_shop_product_locations_on_product_id"
  end

  create_table "spina_shop_product_parts", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_shop_product_relations", id: :serial, force: :cascade do |t|
    t.integer "product_id"
    t.integer "related_product_id"
    t.index ["product_id"], name: "idx_shop_product_relations_on_product_id"
    t.index ["related_product_id"], name: "idx_shop_product_relations_on_related_product_id"
  end

  create_table "spina_shop_product_reviews", id: :serial, force: :cascade do |t|
    t.integer "customer_id"
    t.text "review"
    t.string "author"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "review_summary"
    t.citext "email"
    t.decimal "score", precision: 3, scale: 1
    t.integer "product_id"
    t.integer "shop_review_id"
    t.index ["customer_id"], name: "idx_shop_product_reviews_on_customer_id"
    t.index ["product_id"], name: "idx_shop_product_reviews_on_product_id"
  end

  create_table "spina_shop_product_translations", id: :serial, force: :cascade do |t|
    t.integer "spina_shop_product_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.text "description"
    t.string "seo_title"
    t.string "seo_description"
    t.string "materialized_path"
    t.string "variant_name"
    t.text "extended_description"
    t.index ["locale"], name: "idx_shop_product_translations_on_locale"
    t.index ["spina_shop_product_id"], name: "idx_shop_product_translations_on_spina_product_id"
  end

  create_table "spina_shop_products", id: :serial, force: :cascade do |t|
    t.integer "product_category_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.jsonb "properties", default: "{}", null: false
    t.string "name"
    t.float "average_review_score"
    t.integer "sales_count"
    t.decimal "lowest_price", precision: 8, scale: 2
    t.string "supplier"
    t.boolean "active", default: false, null: false
    t.string "sku"
    t.string "location", default: "", null: false
    t.integer "tax_group_id"
    t.decimal "weight", precision: 8, scale: 3
    t.decimal "base_price", precision: 8, scale: 2
    t.decimal "cost_price", precision: 8, scale: 2
    t.string "ean"
    t.integer "sales_category_id"
    t.boolean "must_be_of_age_to_buy", default: false
    t.boolean "can_expire", default: false
    t.date "expiration_date"
    t.integer "stock_level", default: 0, null: false
    t.string "supplier_reference"
    t.boolean "stock_enabled", default: false, null: false
    t.boolean "editable_sku", default: true, null: false
    t.boolean "deletable", default: true, null: false
    t.jsonb "price_exceptions", default: "{}", null: false
    t.boolean "price_includes_tax", default: true, null: false
    t.boolean "archived", default: false, null: false
    t.decimal "trend", precision: 8, scale: 3, default: "0.0", null: false
    t.decimal "promotional_price", precision: 8, scale: 2
    t.integer "limit_per_order"
    t.integer "parent_id"
    t.jsonb "variant_overrides"
    t.integer "children_count", default: 0, null: false
    t.boolean "available_at_supplier", default: true, null: false
    t.boolean "waiting_for_stock", default: false, null: false
    t.integer "supplier_id"
    t.integer "supplier_packing_unit", default: 1, null: false
    t.integer "statistics_reorder_point", default: 0, null: false
    t.integer "statistics_eoq", default: 0, null: false
    t.integer "statistics_safety_stock", default: 0, null: false
    t.integer "abc_analysis"
    t.integer "xyz_analysis"
    t.integer "statistics_weekly_sales", default: 0, null: false
    t.decimal "length", precision: 8, scale: 1, default: "0.0", null: false
    t.decimal "width", precision: 8, scale: 1, default: "0.0", null: false
    t.decimal "height", precision: 8, scale: 1, default: "0.0", null: false
    t.jsonb "volume_discounts", default: [], null: false
    t.index ["name"], name: "idx_shop_products_on_name", using: :gin
    t.index ["parent_id"], name: "index_spina_shop_products_on_parent_id"
    t.index ["product_category_id"], name: "idx_shop_products_on_product_category_id"
    t.index ["sales_category_id"], name: "index_spina_shop_products_on_sales_category_id"
    t.index ["tax_group_id"], name: "index_spina_shop_products_on_tax_group_id"
  end

  create_table "spina_shop_property_option_translations", force: :cascade do |t|
    t.integer "spina_shop_property_option_id"
    t.string "locale"
    t.string "label"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["locale"], name: "index_spina_shop_property_option_translations_on_locale"
    t.index ["spina_shop_property_option_id"], name: "idx_sp_shp_pr_op_translations_123"
  end

  create_table "spina_shop_property_options", force: :cascade do |t|
    t.string "name"
    t.integer "product_category_property_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "property_id"
    t.string "property_type"
    t.index ["product_category_property_id"], name: "index_spina_shop_pr_options_on_pr_cat_property_id"
    t.index ["property_id", "property_type"], name: "sp_sh_pr_op_pr_id_pr_type_index"
  end

  create_table "spina_shop_property_parts", force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_shop_recounts", force: :cascade do |t|
    t.integer "product_id"
    t.integer "difference"
    t.string "actor"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["product_id"], name: "index_spina_shop_recounts_on_product_id"
  end

  create_table "spina_shop_sales_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.jsonb "codes", default: "{}", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "metadata", default: "{}", null: false
  end

  create_table "spina_shop_sales_category_codes", force: :cascade do |t|
    t.string "code"
    t.string "sales_categorizable_type"
    t.integer "sales_categorizable_id"
    t.integer "sales_category_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "business", default: false, null: false
    t.index ["sales_categorizable_id"], name: "index_spina_shop_sales_category_codes_on_sales_categorizable_id"
    t.index ["sales_category_id"], name: "index_spina_shop_sales_category_codes_on_sales_category_id"
  end

  create_table "spina_shop_shared_properties", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_shop_shop_reviews", id: :serial, force: :cascade do |t|
    t.string "author"
    t.text "review_pros"
    t.text "review_cons"
    t.decimal "score"
    t.decimal "score_communication"
    t.decimal "score_speed"
    t.integer "order_id"
    t.integer "customer_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.citext "email"
    t.boolean "approved", default: true, null: false
  end

  create_table "spina_shop_stock_level_adjustments", id: :serial, force: :cascade do |t|
    t.integer "product_item_id"
    t.integer "order_item_id"
    t.integer "adjustment", default: 0, null: false
    t.text "description"
    t.string "actor"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "expiration_month"
    t.integer "expiration_year"
    t.integer "product_id"
    t.string "category"
    t.index ["order_item_id"], name: "idx_shop_stock_level_adjustments_on_order_item_id"
    t.index ["product_id"], name: "index_spina_shop_stock_level_adjustments_on_product_id"
    t.index ["product_item_id"], name: "idx_shop_stock_level_adjustments_on_product_item_id"
  end

  create_table "spina_shop_stock_orders", force: :cascade do |t|
    t.integer "supplier_id"
    t.datetime "closed_at", precision: nil
    t.text "note"
    t.string "delivery_tracking_url"
    t.date "expected_delivery"
    t.datetime "ordered_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "feedback"
    t.string "reference"
    t.index ["supplier_id"], name: "index_spina_shop_stock_orders_on_supplier_id"
  end

  create_table "spina_shop_stores", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "color"
  end

  create_table "spina_shop_suppliers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "lead_time", default: 0, null: false
    t.string "contact_name"
    t.citext "email"
    t.string "phone"
    t.text "note"
    t.integer "lead_time_standard_deviation", default: 0, null: false
    t.decimal "average_stock_order_cost", precision: 8, scale: 2
  end

  create_table "spina_shop_taggable_tags", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["tag_id"], name: "index_spina_shop_taggable_tags_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_spina_shop_taggable_tags_on_taggable_type_and_taggable_id"
  end

  create_table "spina_shop_tags", force: :cascade do |t|
    t.jsonb "name", default: {}
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_shop_tax_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.jsonb "tax_rates", default: "{}", null: false
    t.jsonb "metadata", default: "{}", null: false
  end

  create_table "spina_shop_tax_rates", id: :serial, force: :cascade do |t|
    t.integer "tax_group_id"
    t.decimal "rate", precision: 8, scale: 2, default: "0.0", null: false
    t.string "code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "tax_rateable_type"
    t.integer "tax_rateable_id"
    t.boolean "business", default: false, null: false
    t.index ["tax_group_id"], name: "index_spina_shop_tax_rates_on_tax_group_id"
    t.index ["tax_rateable_type", "tax_rateable_id"], name: "spina_tax_rates_tax_rateable_index"
  end

  create_table "spina_shop_zones", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "parent_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "type"
    t.string "code"
  end

  create_table "spina_structure_items", id: :serial, force: :cascade do |t|
    t.integer "structure_id"
    t.integer "position"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["structure_id"], name: "index_spina_structure_items_on_structure_id"
  end

  create_table "spina_structure_parts", id: :serial, force: :cascade do |t|
    t.integer "structure_item_id"
    t.integer "structure_partable_id"
    t.string "structure_partable_type"
    t.string "name"
    t.string "title"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["structure_item_id"], name: "index_spina_structure_parts_on_structure_item_id"
    t.index ["structure_partable_id"], name: "index_spina_structure_parts_on_structure_partable_id"
  end

  create_table "spina_structures", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "spina_text_translations", id: :serial, force: :cascade do |t|
    t.integer "spina_text_id", null: false
    t.string "locale", null: false
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["locale"], name: "index_spina_text_translations_on_locale"
    t.index ["spina_text_id"], name: "index_spina_text_translations_on_spina_text_id"
  end

  create_table "spina_texts", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "spina_users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.boolean "admin", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "last_logged_in", precision: nil
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at", precision: nil
  end

  add_foreign_key "spina_shop_addresses", "spina_shop_countries", column: "country_id"
  add_foreign_key "spina_shop_addresses", "spina_shop_customers", column: "customer_id"
  add_foreign_key "spina_shop_custom_products", "spina_shop_sales_categories", column: "sales_category_id"
  add_foreign_key "spina_shop_custom_products", "spina_shop_tax_groups", column: "tax_group_id"
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
