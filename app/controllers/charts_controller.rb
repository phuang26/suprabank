class ChartsController < ApplicationController
  def index

  end

  def completed_tasks
    base = (1..100).to_a
    c1 = 1./Interaction.last.binding_constant
    c2 = 2*c1
    ka = Interaction.last.binding_constant
    q = c1*c2
    p = -(c1+c2+1/ka)
    sol = -(p/2)-Math.sqrt((p*p)/4-q)
    x = base.map{|element| element*0.1}
    y = x.map{|element| (c1+element+1/ka)/2-Math.sqrt(((c1+element+1/ka)*(c1+element+1/ka))/4-c1*element)}
    sol = x.zip(y).to_h
    result = [[1,sol]].to_h
    render json: sol
    #render json: Molecule.group_by_day_of_week(:created_at).count
  end

end
