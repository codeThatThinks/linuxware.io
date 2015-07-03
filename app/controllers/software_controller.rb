class SoftwareController < ApplicationController
	before_action :get_software_index, only: [:index]
	before_action :get_software, only: [:edit, :update, :show, :destroy]

	def get_software_index
		@software_index = Software.all
	end

	def get_software
		@software = Software.find(params[:id])
	end

	def software_params
		params.require(:software).permit(:name, :short_description, :description, :url, :license)
	end

	def index
		respond_to do |format|
			format.html
			format.json { render json: Software.all.collect {|s| {name: s.name, description: s.short_description, url: s.url, license: s.license, tags: s.tags}} }
		end
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
		@packages = Array.new

		Distro.all.each do |d|
			d_hash = Hash.new
			d_hash[:distro] = d.name
			d_hash[:packages] = Array.new
			d.repos.each do |r|
				r.packages.where(software: @software).each do |s|
					d_hash[:packages] << {name: s.name, version: s.version, description: s.description}
				end
			end
			@packages << d_hash
		end
	end

	def destroy
	end

	def search
		render json: Software.search(params[:query], fields: [{name: :text_start}], limit: 10).map(&:name)
	end
end
