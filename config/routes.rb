Rails.application.routes.draw do


  
  root to: 'welcome#welcome'
  get 'about_us', to: 'welcome#about_us'
  get 'terms_of_service', to: 'welcome#terms_of_service'
  get 'privacy', to: 'welcome#privacy'
  get 'legal', to: 'welcome#legal'
  get 'glossary', to: 'glossary#index'
  get 'query_affiliation', to: 'groups#query_affiliation'
  get 'media', to: 'buffers#media'

  resources :charts

  devise_for :users, controllers: {
        registrations: "registrations",
      }, :path_prefix => 'my'

  resources :users, only: [:show] do
    member do
      get :datasets
      get :revisions
      get :interactions
    end
    collection do
      get :query_orcid
      post :orcid_modal
    end
  end

  resources :groups do
    member do
      get :interactions
      get :datasets
    end
    collection do
      get :query
    end
  end

  resources :assignments do
    member do
      get :confirm_group
      get :decline_group
    end
  end

  get 'additives/new', to: redirect('additives')
  get 'solvents/new', to: redirect('solvents')
  resources :additives, :solvents, only: [:index, :show, :edit, :update] do
    member do
      get :interactions
      get :pubchem_update_query
    end
    collection do
      get :pubchem_request
      get :pubchem_full_record
      get :pubchem_update #no controller action yet
      get :cid_request
      get :pubchem_help
      get :search
      get :dbsearch
      get :query
    end
  end

  resources :frameworks do
    member do
      get :preview
    end
    collection do
      get :query
    end
  end
  resources :molecules do
    member do
      get :interactions
      get :pubchem_auto_update
      get :pubchem_update_query
      patch :update_framework_molecule
    end
    collection do
      get :new_framework
      get :new_molecule
      post :create_framework_molecule
      put :pubchem_update
      get :pubchem_request
      get :pubchem_full_record
      get :cid_request
      get :pubchem_help
      get :pdb_help
      get :framework_help
      get :framework_dbsearch
      get :pdb_id_request
      get :pdb_full_record
      get :search
      get :editorsearch
      get :dbsearch
      get :pogresearch
      get :query
      get :smilesquery
      get :query_tags
      get :external_services
      get :tag_cloud
      get :listing
      get :chemeditor
      get :edit_comment
    end
  end

  resources :buffers do
    member do
      get :interactions
    end
    collection do
      get :query
      get :buffer_check
      get :dbsearch
      get :listing
    end
  end
  

  resources :interactions do
    member do
      post :reviewer_comments
      post :duplicate
      put :accident
      get :citation_export
      get :hg_sim_data
      put :self_acceptance
    end
    collection do
      put :publish_accepted
      put :update_reviewers
      get :advsearch
      get :intsearch
      get :dbsearch
      get :advanced_search
      get :query_technique
      get :query_assay_type
      get :query_itc_instruments
    end
  end

  resources :creators, :contributors, only: [] do
    collection do
      post :orcid_modal
      get :query
    end
  end

  resources :datasets do
    collection do
      post :preview_modal
      put :add_interactions
      put :update_state
      put :update_dataset_interactions_dois
      put :remove_interactions
      get :list_all_possible_interactions
      get :citation_query
      get :query_user_datasets_editable
      get :query_datasets
      get :query_cooperators
      get :advsearch
      get :query_subjects
    end

    member do
      put :self_revision_temp
      get :preview
      get :dataset_csv_export
      get :interaction_addition
      get :citation_export
    end
  end

  resources :related_identifiers, only: [] do
    member do
      get :citation_export
    end
  end

  resources :dataset_related_identifiers, only: [] do
    collection do
      get :primary_reference_doi_query
    end
  end



end
