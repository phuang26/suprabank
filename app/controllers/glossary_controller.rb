class GlossaryController < ApplicationController
  before_action :set_meta_data

  def index
  end


  private


  def set_meta_data
      @title = "SupraBank - Glossary"
      @meta_title = @title
      @meta_description = "Find your knowledge base at SupraBank"
      @meta_image = "logo-production.png"
      @meta_og_url = "https://suprabank.org/molecules"
  end

end
