class ReposController < ApplicationController
	before_action :get_repo, only: [:show, :edit_packages, :update_packages, :edit, :update, :destroy, :fetch, :fetch_status, :view_fetch]
	before_action :get_repo_types, only: [:new, :edit_packages, :edit, :fetch, :view_fetch]
	before_action :get_distro, only: [:new, :create]
	before_action :get_repo_distro, only: [:show, :edit_packages, :edit, :destroy, :fetch, :view_fetch]
	before_action :get_repo_type_name, only: [:show, :fetch, :view_fetch]

	def get_repo
		@repo = Repo.find(params[:id])
	end

	def get_repo_types
		@repo_types = Repo.types
	end

	def get_distro
		@distro = Distro.find(params[:distro_id])
	end

	def get_repo_distro
		@distro = @repo.distro
	end

	def get_repo_type_name
		@repo_type_name = @repo.type.constantize.type_name
	end

	def show
		@page_num = (params.has_key?(:page_num)) ? params[:page_num].to_i : 1
		@per_page = 50
		@num_pages = (@repo.packages.length / @per_page.to_f).ceil

		if @repo.packages.length > 0 && @page_num > @num_pages
			redirect_to @repo
		end

		if @num_pages % 10 != 0 && @page_num > (@num_pages / 10.0).floor * 10
			@page_range = ((@num_pages / 10.0).floor * 10 + 1)..@num_pages
		elsif @page_num % 10 == 0
			@page_range = (@page_num - 9)..@page_num
		else
			@page_range = ((@page_num / 10.0).floor * 10 + 1)..((@page_num / 10.0).ceil * 10)
		end

		@packages = @repo.packages[(@per_page * (@page_num - 1))..(@per_page * (@page_num - 1) + @per_page - 1)]
	end

	def edit_packages
		if @repo.packages.length == 0
			redirect_to @repo
		end

		@page_num = (params.has_key?(:page_num)) ? params[:page_num].to_i : 1
		@per_page = 50
		@num_pages = (@repo.packages.length / @per_page.to_f).ceil

		if @repo.packages.length > 0 && @page_num > @num_pages
			redirect_to @repo
		end

		if @num_pages % 10 != 0 && @page_num > (@num_pages / 10.0).floor * 10
			@page_range = ((@num_pages / 10.0).floor * 10 + 1)..@num_pages
		elsif @page_num % 10 == 0
			@page_range = (@page_num - 9)..@page_num
		else
			@page_range = ((@page_num / 10.0).floor * 10 + 1)..((@page_num / 10.0).ceil * 10)
		end

		@packages = @repo.packages[(@per_page * (@page_num - 1))..(@per_page * (@page_num - 1) + @per_page - 1)]
	end

	def update_packages
		@page_num = (params.has_key?(:page_num)) ? params[:page_num].to_i : 1

		params.require(:package).each do |id, software|
			Package.find(id).update({software: Software.find_by(name: software)})
		end

		redirect_to packages_repo_path(@repo, @page_num)
	end

	def new
		@repo = Repo.new
	end

	def create
		@repo = Repo.new(params.require(:repo).permit([:name, :type, :url]))
		@repo.distro = Distro.find(params[:distro_id])
		@repo.save
		redirect_to repo_path(@repo)
	end

	def edit
	end

	def update
		if @repo.update(params.require(@repo.type.underscore.to_sym).permit([:name, :type, :url]))
			redirect_to @repo
		else
			render action: "edit"
		end
	end

	def destroy
		@repo.destroy
		redirect_to @distro
	end

	def fetch
		if !@repo.is_fetching && !@repo.is_fetch_queued
			@repo.is_fetch_queued = true
			@repo.save
			FetchPackageListJob.perform_later(@repo.id)
		end
	end

	def fetch_status
		render json: {is_fetching: @repo.is_fetching, is_fetch_queued: @repo.is_fetch_queued, fetch_log: @repo.fetch_log}
	end

	def view_fetch
		if @repo.is_fetching || @repo.is_fetch_queued
			redirect_to fetch_repo_path(@repo)
		end

		if @repo.last_fetch == nil || @repo.fetch_info.empty?
			redirect_to @repo
		end

		@removed = Array.new
		@repo.fetch_info[:removed].each do |package_id|
			@removed << Package.find(package_id)
		end
	end
end
