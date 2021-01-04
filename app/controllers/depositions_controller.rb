class DepositionsController < ApplicationController
  def new
    @deposition = Deposition.new
  end

  def create
    @deposition = Deposition.new(deposition_params)
    @deposition.save
    redirect_to deposition_path(@deposition)
  end

  def show
    @deposition = Deposition.find(params[:id])
  end

  def deposition_params
    params.require(:deposition).permit(:dep_city, :arr_city, :reason, :excuse, :departure, :arrival, :forward, :forward_dep, :forward_arr, :alert_date, :delay)
  end
end
