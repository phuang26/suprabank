class InteractionAdditivesController < ApplicationController

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interaction_additives
      @interaction_additives = InteractionAdditive.find(params[:id])
    end


  def additive_params
    params.fetch(:interaction_additive, {})
    params.require(:interaction_additive).permit(:interaction_id, :id, :concentration, :additive_id, :first_additive_name, :second_additive_name, :third_additive_name, :fourth_additive_name)
  end
end
