class ContributorsController < ApplicationController
  before_action :authenticate_user!
  include Orcid

  def orcid_modal
    @orcid_results = query_name_array_from_name(params[:familyName],params[:givenName])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def query
    regexp = /#{params[:term]}/i; # case-insensitive regexp based on your string
    regexresult = Contributor.order(:familyName).where('"creatorName" ILIKE ?', "%#{params[:term]}%")
    result= regexresult.sort{|x, y| (x =~ regexp) <=> (y =~ regexp) }
    array = result.map{|n| [n.creatorName , n.nameIdentifier]}
    render json: array.sort_by{|word| word[1].length }[0..5]
  end

end
