require_relative 'option_loader.rb'
require_relative 'bitbucket.rb'
require 'octokit'

options = OptionLoader.new(
  %i[
    github_access_token
    github_organization
    bitbucket_username
    bitbucket_password
    bitbucket_organization
  ]
).load

github = Octokit::Client.new(access_token: options[:github_access_token])
bitbucket = Bitbucket.new(
  username: options[:bitbucket_username],
  password: options[:bitbucket_password],
  organization: options[:bitbucket_organization]
)

repo_urls = bitbucket.repositories.collect{ |r| r[:links][:clone].find{ |l| l[:name] == 'ssh' }[:href] }

repo_urls.each do |bitbucket_url|
  repo_name = bitbucket_url.split('/').last.gsub('.git', '')
  github_url = github.create_repository(repo_name, private: 'true')[:ssh_url]
  system("git clone #{bitbucket_url} #{repo_name} && cd #{repo_name} && git remote remove origin && git remote add origin #{github_url} && git push -u origin master")
end
