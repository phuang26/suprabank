class WelcomeController < ApplicationController

  def index

  end

  def legal

  end

  def terms_of_service

  end

  def privacy

  end

  def about_us
    #@interactions = Interaction.all.order(updated_at: :desc)
    @dcidentifier = "https://suprabank.org"
  end

  def welcome
    #@interactions = Interaction.all.order(updated_at: :desc)
    @title = "SupraBank"
    @meta_title = @title
  end

end
