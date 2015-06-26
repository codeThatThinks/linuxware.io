class FetchPackageListJob < ActiveJob::Base
  queue_as do
  	repo_id = self.arguments.first
  	:default
  end

  def perform(repo_id)
  	repo = Repo.find(repo_id)
  	repo.is_fetch_queued = false
  	repo.is_fetching = true
  	repo.save
  	repo.fetch
  	repo.is_fetching = false
  	repo.save
  end
end
