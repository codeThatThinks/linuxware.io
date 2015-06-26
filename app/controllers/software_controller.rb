class SoftwareController < ApplicationController
	before_action :get_software_index, only: [:index]
	before_action :get_software, only: [:edit, :show, :destroy]

	def get_software_index
		@software_index = Software.all
	end

	def get_software
		@software = Software.find(params[:id])
	end

	def software_params
		params.require(:software).permit(:name, :description, :url, :license)
	end

	def index
	end

	def new
		@software = Software.new
	end

	def create
		@software = Software.new(software_params)
		if @software.save
			redirect_to @software
		else
			render action: 'new'
		end
	end

	def edit
	end

	def update
		if @software.update(software_params)
			redirect_to @software
		else
			render action: 'edit'
		end
	end

	def show
	end

	def destroy
	end
end
