# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20211028142735) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "absorbances", force: :cascade do |t|
    t.float    "lambda_obs"
    t.float    "free_to_bound"
    t.text     "instrument"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

# Could not dump table "additives" because of following FrozenError
#   can't modify frozen String: "false"

  create_table "additives_interactions", force: :cascade do |t|
    t.integer "interaction_id"
    t.integer "additive_id"
  end

  add_index "additives_interactions", ["additive_id"], name: "index_additives_interactions_on_additive_id", using: :btree
  add_index "additives_interactions", ["interaction_id"], name: "index_additives_interactions_on_interaction_id", using: :btree

  create_table "assay_types", force: :cascade do |t|
    t.string   "names",      default: [],              array: true
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "assignments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "role"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.boolean  "confirmed"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.integer  "desired_group_id"
    t.string   "desired_role"
  end

  add_index "assignments", ["group_id"], name: "index_assignments_on_group_id", using: :btree
  add_index "assignments", ["user_id"], name: "index_assignments_on_user_id", using: :btree

  create_table "buffer_additives", force: :cascade do |t|
    t.integer  "additive_id"
    t.integer  "buffer_id"
    t.float    "concentration"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "buffer_additives", ["additive_id"], name: "index_buffer_additives_on_additive_id", using: :btree
  add_index "buffer_additives", ["buffer_id"], name: "index_buffer_additives_on_buffer_id", using: :btree

  create_table "buffer_solvents", force: :cascade do |t|
    t.integer  "solvent_id"
    t.integer  "buffer_id"
    t.float    "volume_percent"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "buffer_solvents", ["buffer_id"], name: "index_buffer_solvents_on_buffer_id", using: :btree
  add_index "buffer_solvents", ["solvent_id"], name: "index_buffer_solvents_on_solvent_id", using: :btree

  create_table "buffers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.float    "pH"
    t.float    "conc"
    t.string   "abbreviation"
    t.integer  "user_id"
    t.string   "sourceofconcentration"
    t.integer  "interactions_count"
  end

  add_index "buffers", ["user_id"], name: "index_buffers_on_user_id", using: :btree

  create_table "circular_dichroisms", force: :cascade do |t|
    t.float    "lambda_obs"
    t.float    "free_to_bound"
    t.text     "instrument"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "contributors", force: :cascade do |t|
    t.text     "contributorName"
    t.text     "nameType"
    t.text     "givenName"
    t.text     "familyName"
    t.text     "nameIdentifier"
    t.text     "nameIdentifierScheme",        default: "ORCID"
    t.text     "schemeURI",                   default: "https://orcid.org"
    t.text     "affiliation"
    t.text     "affiliationIdentifier"
    t.text     "affiliationIdentifierScheme", default: "ROR"
    t.text     "SchemeURI",                   default: "https://ror.org/"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "name"
  end

  add_index "contributors", ["affiliation"], name: "index_contributors_on_affiliation", using: :btree
  add_index "contributors", ["affiliationIdentifier"], name: "index_contributors_on_affiliationIdentifier", using: :btree
  add_index "contributors", ["contributorName"], name: "index_contributors_on_contributorName", using: :btree
  add_index "contributors", ["familyName"], name: "index_contributors_on_familyName", using: :btree
  add_index "contributors", ["givenName"], name: "index_contributors_on_givenName", using: :btree

  create_table "creators", force: :cascade do |t|
    t.text     "creatorName"
    t.text     "nameType"
    t.text     "givenName"
    t.text     "familyName"
    t.text     "nameIdentifier"
    t.text     "nameIdentifierScheme",        default: "ORCID"
    t.text     "schemeURI",                   default: "https://orcid.org"
    t.text     "affiliation"
    t.text     "affiliationIdentifier"
    t.text     "affiliationIdentifierScheme", default: "ROR"
    t.text     "SchemeURI",                   default: "https://ror.org/"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "name"
  end

  create_table "dataset_contributors", force: :cascade do |t|
    t.integer  "dataset_id"
    t.integer  "contributor_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "contributorType"
  end

  create_table "dataset_creators", force: :cascade do |t|
    t.integer  "dataset_id"
    t.integer  "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dataset_interactions", force: :cascade do |t|
    t.integer  "dataset_id"
    t.integer  "interaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dataset_related_identifiers", force: :cascade do |t|
    t.integer  "dataset_id"
    t.integer  "related_identifier_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "relationType"
    t.integer  "rank",                  default: 1
  end

  create_table "dataset_users", force: :cascade do |t|
    t.integer  "dataset_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "datasets", force: :cascade do |t|
    t.string   "identifier"
    t.string   "identifierType",                    default: "DOI"
    t.text     "title"
    t.string   "publisher",                         default: "SupraBank"
    t.text     "resourceType",                      default: "Interaction Data"
    t.text     "resourceTypeGeneral",               default: "Dataset"
    t.text     "language",                          default: "english"
    t.text     "description"
    t.text     "descriptionType",                   default: "Abstract"
    t.text     "size"
    t.text     "format",                            default: "text/html"
    t.text     "alternateIdentifier"
    t.text     "alternateIdentifierType",           default: "SupraBank URI"
    t.text     "rights",                            default: "Creative Commons Attribution 4.0 International"
    t.text     "rightsURI",                         default: "https://creativecommons.org/licenses/by/4.0/legalcode"
    t.text     "rightsIdentifier",                  default: "cc-by-4.0"
    t.text     "rightsIdentifierScheme",            default: "SPDX"
    t.text     "schemeURI",                         default: "https://spdx.org/licenses/"
    t.date     "available_at"
    t.datetime "created_at",                                                                                          null: false
    t.datetime "updated_at",                                                                                          null: false
    t.text     "subjects",                                                                                                         array: true
    t.string   "state",                             default: "draft"
    t.integer  "publicationYear"
    t.date     "registered"
    t.integer  "published"
    t.text     "label"
    t.boolean  "varified"
    t.text     "primary_reference"
    t.json     "datacite"
    t.string   "bibtex_file_name"
    t.string   "bibtex_content_type"
    t.integer  "bibtex_file_size",        limit: 8
    t.datetime "bibtex_updated_at"
    t.string   "preview_token"
    t.text     "citation"
    t.integer  "size_count"
    t.integer  "show_count",                        default: 0
    t.integer  "view_count",                        default: 0
    t.integer  "download_count",                    default: 0
    t.integer  "citation_count",                    default: 0
    t.integer  "citation_export_count",             default: 0
    t.integer  "scholarArticleState"
    t.string   "img_file_name"
    t.string   "img_content_type"
    t.integer  "img_file_size",           limit: 8
    t.datetime "img_updated_at"
    t.text     "img_url"
  end

  create_table "electron_paramagnetic_resonances", force: :cascade do |t|
    t.float    "magnetic_flux_obs"
    t.float    "free_to_bound"
    t.text     "instrument"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "extractions", force: :cascade do |t|
    t.text     "instrument"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fluorescences", force: :cascade do |t|
    t.float    "lambda_ex"
    t.float    "lambda_em"
    t.float    "free_to_bound"
    t.text     "instrument"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "framework_molecule_additives", force: :cascade do |t|
    t.integer  "additive_id"
    t.integer  "framework_molecule_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "framework_molecules", force: :cascade do |t|
    t.integer  "molecule_id"
    t.integer  "framework_id"
    t.float    "si_al_ratio"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "frameworks", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "png_file_name"
    t.string   "png_content_type"
    t.integer  "png_file_size",          limit: 8
    t.datetime "png_updated_at"
    t.text     "png_url"
    t.text     "name"
    t.text     "code"
    t.text     "iza_url"
    t.text     "crystal_system"
    t.text     "space_group"
    t.float    "unit_cell_a"
    t.float    "unit_cell_b"
    t.float    "unit_cell_c"
    t.float    "unit_cell_alpha"
    t.float    "unit_cell_beta"
    t.float    "unit_cell_gamma"
    t.float    "volume"
    t.float    "rdls"
    t.float    "framework_density"
    t.float    "topological_density"
    t.float    "topological_density_10"
    t.integer  "ring_sizes",                       default: [],              array: true
    t.text     "channel_dimensionality"
    t.float    "max_d_sphere_included"
    t.float    "max_d_sphere_diffuse_a"
    t.float    "max_d_sphere_diffuse_b"
    t.float    "max_d_sphere_diffuse_c"
    t.float    "accessible_volume"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "affiliation"
    t.string   "department"
    t.string   "city"
    t.string   "website"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "country"
    t.string   "affiliationIdentifier"
  end

  create_table "interaction_additives", force: :cascade do |t|
    t.integer  "interaction_id"
    t.integer  "additive_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.float    "concentration"
  end

  add_index "interaction_additives", ["additive_id"], name: "index_interaction_additives_on_additive_id", using: :btree
  add_index "interaction_additives", ["interaction_id"], name: "index_interaction_additives_on_interaction_id", using: :btree

  create_table "interaction_related_identifiers", force: :cascade do |t|
    t.integer  "interaction_id"
    t.integer  "related_identifier_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "interaction_solvents", force: :cascade do |t|
    t.integer  "interaction_id"
    t.integer  "solvent_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.float    "volume_percent"
  end

  add_index "interaction_solvents", ["interaction_id"], name: "index_interaction_solvents_on_interaction_id", using: :btree
  add_index "interaction_solvents", ["solvent_id"], name: "index_interaction_solvents_on_solvent_id", using: :btree

# Could not dump table "interactions" because of following FrozenError
#   can't modify frozen String: "false"

  create_table "isothermal_titration_calorimetries", force: :cascade do |t|
    t.float    "cell_volume"
    t.float    "concentration_molecule"
    t.float    "injection_volume"
    t.float    "initial_injection_volume"
    t.float    "injection_number"
    t.float    "concentration_host"
    t.float    "syringe_volume"
    t.text     "instrument"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.boolean  "host_cell"
    t.boolean  "molecule_cell"
    t.boolean  "indicator_cell"
    t.boolean  "conjugate_cell"
    t.float    "concentration_indicator"
    t.float    "concentration_conjugate"
  end

  create_table "itc_instruments", force: :cascade do |t|
    t.text     "name"
    t.text     "alternative_name"
    t.text     "brand"
    t.float    "cell_volume"
    t.float    "syringe_volume"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

# Could not dump table "molecules" because of following FrozenError
#   can't modify frozen String: "false"

  create_table "nuclear_magnetic_resonances", force: :cascade do |t|
    t.float    "shift_bound"
    t.float    "shift_unbound"
    t.float    "delta_shift"
    t.text     "nucleus"
    t.text     "instrument"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.float    "free_to_bound"
  end

  create_table "potentiometries", force: :cascade do |t|
    t.text     "instrument"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "related_identifiers", force: :cascade do |t|
    t.text     "relatedIdentifier"
    t.text     "relatedIdentifierType",           default: "DOI"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "url"
    t.json     "crossref"
    t.boolean  "doi_validity"
    t.string   "bibtex_file_name"
    t.string   "bibtex_content_type"
    t.integer  "bibtex_file_size",      limit: 8
    t.datetime "bibtex_updated_at"
    t.text     "citation"
    t.text     "toc_url"
  end

# Could not dump table "solvents" because of following FrozenError
#   can't modify frozen String: "false"

  create_table "surface_enhanced_raman_scatterings", force: :cascade do |t|
    t.float    "nu_obs"
    t.float    "free_to_bound"
    t.text     "instrument"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["context"], name: "index_taggings_on_context", using: :btree
  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
  add_index "taggings", ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
  add_index "taggings", ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
  add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "techniques", force: :cascade do |t|
    t.string   "names",      default: [],              array: true
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  null: false, default: ""
    t.string   "encrypted_password",     null: false, default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "givenName"
    t.string   "familyName"
    t.string   "url"
    t.boolean  "moderator",              default: false
    t.integer  "user_role"
    t.string   "nameIdentifier"
    t.string   "affiliation"
    t.string   "affiliationIdentifier"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "users", ["email"],                name: "index_users_on_email",                  unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token",   unique: true, using: :btree
  add_index "users", ["givenName"],            name: "index_users_on_givenName",              using: :btree
  add_index "users", ["familyName"],           name: "index_users_on_familyName",             using: :btree
  add_index "users", ["nameIdentifier"],       name: "index_users_on_nameIdentifier",         using: :btree
  add_index "users", ["affiliation"],          name: "index_users_on_affiliation",            using: :btree
  add_index "users", ["affiliationIdentifier"],name: "index_users_on_affiliationIdentifier",  using: :btree

  add_foreign_key "assignments", "groups"
  add_foreign_key "assignments", "users"
  add_foreign_key "buffer_additives", "additives"
  add_foreign_key "buffer_additives", "buffers"
  add_foreign_key "buffer_solvents", "buffers"
  add_foreign_key "buffer_solvents", "solvents"
  add_foreign_key "buffers", "users"
  add_foreign_key "interactions", "buffers"
  add_foreign_key "interactions", "users"
  add_foreign_key "molecules", "users"
end
