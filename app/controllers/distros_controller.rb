class DistrosController < ApplicationController
  before_action :get_distro, only: [:show, :edit, :update, :destroy]

  def get_distro
  	@distro = Distro.find(params[:id])
  end

  def new
    @distro = Distro.new
  end

  def create
  	@distro = Distro.create(params.require(:distro).permit(:name))
  	redirect_to @distro
  end

  def index
  	@distros = Distro.all
  end

  def show
  end

  def edit
  end

  def update
  	@distro.update(params.require(:distro).permit(:name))
    redirect_to action: "show"
  end

  def destroy
    @distro.destroy
    redirect_to action: "index"
  end
end
