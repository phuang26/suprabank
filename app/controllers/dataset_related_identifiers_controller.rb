class DatasetRelatedIdentifiersController < ApplicationController

  def primary_reference_doi_query
    
    render json:  DatasetRelatedIdentifier.primary_reference_doi?(params[:q]).to_json
  end

end
