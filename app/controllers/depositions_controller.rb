class DepositionsController < ApplicationController
  def new
    session[:deposition_params] ||= {}
    @deposition = Deposition.new
  end

  def create
    session[:deposition_params].deep_merge!(deposition_params)
    @deposition = Deposition.new(session[:deposition_params])
    @deposition.current_step = session[:deposition_step]
    if params[:back_button]
      @deposition.previous_step
    elsif params[:next_button]
      @deposition.next_step
    elsif @deposition.last_step?
      @deposition.save
    end
    session[:deposition_step] = @deposition.current_step
    if @deposition.new_record?
      render :new
    else
      session[:deposition_step] = session[:deposition_params] = nil
      redirect_to deposition_path(@deposition)
    end
  end

  def show
    @deposition = Deposition.find(params[:id])
  end

  def deposition_params
    params.require(:deposition).permit(:dep_city, :arr_city, :reason, :excuse, :departure, :arrival, :forward, :forward_dep, :forward_arr, :alert_date, :delay)
  end
end
