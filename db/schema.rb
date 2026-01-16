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

  create_table "additives", force: :cascade do |t|
    t.string   "inchikey"
    t.string   "inchistring"
    t.float    "molecular_weight"
    t.float    "volume_3d"
    t.float    "tpsa"
    t.float    "complexity"
    t.string   "sum_formular"
    t.string   "names",                            default: [],                 array: true
    t.string   "iupac_name"
    t.string   "display_name"
    t.string   "cas"
    t.float    "conformer_count_3d"
    t.float    "bond_stereo_count"
    t.float    "atom_stereo_count"
    t.float    "h_bond_donor_count"
    t.float    "h_bond_acceptor_count"
    t.float    "x_log_p"
    t.float    "charge"
    t.string   "cano_smiles"
    t.string   "iso_smiles"
    t.string   "fingerprint_2d"
    t.boolean  "is_partial",                       default: false, null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.datetime "deleted_at"
    t.string   "pubchem_link"
    t.integer  "cid"
    t.string   "svg_file_name"
    t.string   "svg_content_type"
    t.integer  "svg_file_size",          limit: 8
    t.datetime "svg_updated_at"
    t.string   "png_file_name"
    t.string   "png_content_type"
    t.integer  "png_file_size",          limit: 8
    t.datetime "png_updated_at"
    t.string   "mdl_string"
    t.string   "preferred_abbreviation"
    t.float    "ertl_tpsa"
    t.float    "cheng_xlogp3"
    t.integer  "interactions_count"
    t.text     "png_url"
  end

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

  create_table "interactions", force: :cascade do |t|
    t.string   "method"
    t.string   "assay_type"
    t.string   "technique"
    t.float    "binding_constant"
    t.float    "binding_constant_error"
    t.string   "binding_constant_unit"
    t.integer  "molecule_id"
    t.float    "lower_molecule_concentration"
    t.integer  "host_id"
    t.float    "lower_host_concentration"
    t.integer  "indicator_id"
    t.float    "lower_indicator_concentration"
    t.integer  "conjugate_id"
    t.float    "lower_conjugate_concentration"
    t.float    "temperature",                             default: 25.0,                 null: false
    t.float    "pH"
    t.string   "doi"
    t.float    "itc_deltaH"
    t.float    "itc_deltaH_error"
    t.float    "itc_deltaST"
    t.float    "itc_deltaST_error"
    t.float    "kin_hg"
    t.float    "kin_hg_error"
    t.string   "kin_hg_unit"
    t.string   "kout_hg_unit"
    t.float    "icd"
    t.float    "ct_band"
    t.float    "lambda_em"
    t.float    "lambda_ex"
    t.float    "free_to_bound_FL"
    t.string   "data"
    t.boolean  "is_listed"
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.boolean  "is_clone",                                default: false,                null: false
    t.integer  "linked_interaction"
    t.integer  "user_id"
    t.float    "logKa"
    t.float    "vol_perc",                                                                            array: true
    t.float    "additive_conc",                                                                       array: true
    t.float    "logka_error"
    t.float    "kout_hg"
    t.float    "kout_hg_error"
    t.string   "citation"
    t.integer  "buffer_id"
    t.float    "deltaG"
    t.float    "deltaG_error"
    t.float    "nmrshift"
    t.float    "upper_host_concentration"
    t.float    "upper_molecule_concentration"
    t.float    "upper_indicator_concentration"
    t.float    "upper_conjugate_concentration"
    t.string   "binding_range"
    t.string   "solvent_system"
    t.float    "solubility"
    t.float    "ionic_strength"
    t.string   "nucleus"
    t.float    "delta_S"
    t.boolean  "published",                               default: false
    t.string   "revision",                                default: "pending inspection"
    t.text     "revision_comment"
    t.string   "variation",                               default: "molecule"
    t.text     "comment"
    t.json     "crossref"
    t.string   "bibtex_file_name"
    t.string   "bibtex_content_type"
    t.integer  "bibtex_file_size",              limit: 8
    t.datetime "bibtex_updated_at"
    t.integer  "reviewer_id"
    t.boolean  "embargo",                                 default: true
    t.integer  "in_technique_id"
    t.string   "in_technique_type"
    t.text     "revisions_reply"
    t.boolean  "doi_validity"
    t.datetime "deleted_at"
    t.float    "stoichometry_molecule",                   default: 1.0
    t.float    "stoichometry_host",                       default: 1.0
    t.float    "stoichometry_indicator",                  default: 1.0
    t.float    "stoichometry_conjugate",                  default: 1.0
    t.text     "label"
    t.boolean  "varified"
    t.integer  "show_count",                              default: 0
    t.boolean  "host_suspension",                         default: false
    t.float    "host_cofactor_wt"
    t.float    "host_wt_low"
    t.float    "host_wt_high"
    t.float    "host_indicator_wt"
  end

  add_index "interactions", ["assay_type"], name: "index_interactions_on_assay_type", using: :btree
  add_index "interactions", ["binding_constant"], name: "index_interactions_on_binding_constant", using: :btree
  add_index "interactions", ["buffer_id"], name: "index_interactions_on_buffer_id", using: :btree
  add_index "interactions", ["citation"], name: "index_interactions_on_citation", using: :btree
  add_index "interactions", ["conjugate_id"], name: "index_interactions_on_conjugate_id", using: :btree
  add_index "interactions", ["deltaG"], name: "index_interactions_on_deltaG", using: :btree
  add_index "interactions", ["doi"], name: "index_interactions_on_doi", using: :btree
  add_index "interactions", ["host_id"], name: "index_interactions_on_host_id", using: :btree
  add_index "interactions", ["indicator_id"], name: "index_interactions_on_indicator_id", using: :btree
  add_index "interactions", ["itc_deltaH"], name: "index_interactions_on_itc_deltaH", using: :btree
  add_index "interactions", ["itc_deltaST"], name: "index_interactions_on_itc_deltaST", using: :btree
  add_index "interactions", ["logKa"], name: "index_interactions_on_logKa", using: :btree
  add_index "interactions", ["method"], name: "index_interactions_on_method", using: :btree
  add_index "interactions", ["molecule_id"], name: "index_interactions_on_molecule_id", using: :btree
  add_index "interactions", ["pH"], name: "index_interactions_on_pH", using: :btree
  add_index "interactions", ["solvent_system"], name: "index_interactions_on_solvent_system", using: :btree
  add_index "interactions", ["technique"], name: "index_interactions_on_technique", using: :btree
  add_index "interactions", ["temperature"], name: "index_interactions_on_temperature", using: :btree
  add_index "interactions", ["user_id"], name: "index_interactions_on_user_id", using: :btree

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

  create_table "molecules", force: :cascade do |t|
    t.string   "inchikey"
    t.string   "inchistring"
    t.float    "molecular_weight"
    t.float    "volume_3d"
    t.float    "tpsa"
    t.float    "complexity"
    t.string   "sum_formular"
    t.string   "names",                            default: [],                 array: true
    t.string   "iupac_name"
    t.string   "display_name"
    t.string   "cas"
    t.float    "conformer_count_3d"
    t.float    "bond_stereo_count"
    t.float    "atom_stereo_count"
    t.float    "h_bond_donor_count"
    t.float    "h_bond_acceptor_count"
    t.float    "x_log_p"
    t.float    "charge"
    t.string   "cano_smiles"
    t.string   "iso_smiles"
    t.string   "fingerprint_2d"
    t.boolean  "is_partial",                       default: false, null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.datetime "deleted_at"
    t.string   "pubchem_link"
    t.integer  "cid"
    t.string   "svg_file_name"
    t.string   "svg_content_type"
    t.integer  "svg_file_size",          limit: 8
    t.datetime "svg_updated_at"
    t.string   "png_file_name"
    t.string   "png_content_type"
    t.integer  "png_file_size",          limit: 8
    t.datetime "png_updated_at"
    t.string   "mdl_string"
    t.string   "preferred_abbreviation"
    t.integer  "user_id"
    t.string   "cdx_file_name"
    t.string   "cdx_content_type"
    t.integer  "cdx_file_size",          limit: 8
    t.datetime "cdx_updated_at"
    t.string   "pdb_id"
    t.float    "total_structure_weight"
    t.integer  "atom_count"
    t.integer  "residue_count"
    t.text     "pdb_descriptor"
    t.text     "pdb_title"
    t.text     "pdb_keywords"
    t.integer  "molecule_type",                    default: 0
    t.float    "cheng_xlogp3"
    t.float    "ertl_tpsa"
    t.integer  "interactions_count"
    t.text     "png_url"
  end

  add_index "molecules", ["cano_smiles"], name: "index_molecules_on_cano_smiles", using: :btree
  add_index "molecules", ["cas"], name: "index_molecules_on_cas", using: :btree
  add_index "molecules", ["cid"], name: "index_molecules_on_cid", using: :btree
  add_index "molecules", ["display_name"], name: "index_molecules_on_display_name", using: :btree
  add_index "molecules", ["inchikey"], name: "index_molecules_on_inchikey", using: :btree
  add_index "molecules", ["iso_smiles"], name: "index_molecules_on_iso_smiles", using: :btree
  add_index "molecules", ["iupac_name"], name: "index_molecules_on_iupac_name", using: :btree
  add_index "molecules", ["molecular_weight"], name: "index_molecules_on_molecular_weight", using: :btree
  add_index "molecules", ["preferred_abbreviation"], name: "index_molecules_on_preferred_abbreviation", using: :btree
  add_index "molecules", ["sum_formular"], name: "index_molecules_on_sum_formular", using: :btree
  add_index "molecules", ["user_id"], name: "index_molecules_on_user_id", using: :btree

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

  create_table "solvents", force: :cascade do |t|
    t.string   "inchikey"
    t.string   "inchistring"
    t.float    "molecular_weight"
    t.float    "volume_3d"
    t.float    "tpsa"
    t.float    "complexity"
    t.string   "sum_formular"
    t.string   "names",                            default: [],                 array: true
    t.string   "iupac_name"
    t.string   "display_name"
    t.string   "cas"
    t.float    "conformer_count_3d"
    t.float    "bond_stereo_count"
    t.float    "atom_stereo_count"
    t.float    "h_bond_donor_count"
    t.float    "h_bond_acceptor_count"
    t.float    "x_log_p"
    t.float    "charge"
    t.string   "cano_smiles"
    t.string   "iso_smiles"
    t.string   "fingerprint_2d"
    t.boolean  "is_partial",                       default: false, null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.datetime "deleted_at"
    t.string   "pubchem_link"
    t.integer  "cid"
    t.string   "svg_file_name"
    t.string   "svg_content_type"
    t.integer  "svg_file_size",          limit: 8
    t.datetime "svg_updated_at"
    t.string   "png_file_name"
    t.string   "png_content_type"
    t.integer  "png_file_size",          limit: 8
    t.datetime "png_updated_at"
    t.string   "mdl_string"
    t.string   "preferred_abbreviation"
    t.float    "ertl_tpsa"
    t.float    "cheng_xlogp3"
    t.integer  "interactions_count"
    t.text     "png_url"
  end

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
    t.string   "email",                            default: "",    null: false
    t.string   "encrypted_password",               default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "givenName"
    t.string   "familyName"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "url"
    t.boolean  "moderator",                        default: false
    t.string   "nameIdentifier"
    t.integer  "user_role"
    t.string   "affiliation"
    t.string   "affiliationIdentifier"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size",       limit: 8
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["affiliation"], name: "index_users_on_affiliation", using: :btree
  add_index "users", ["affiliationIdentifier"], name: "index_users_on_affiliationIdentifier", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["familyName"], name: "index_users_on_familyName", using: :btree
  add_index "users", ["givenName"], name: "index_users_on_givenName", using: :btree
  add_index "users", ["nameIdentifier"], name: "index_users_on_nameIdentifier", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

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
