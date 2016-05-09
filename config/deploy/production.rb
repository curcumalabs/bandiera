NODES = %w(cayenne@app5.caynod.es cayenne@app6.caynod.es).freeze
role :app, NODES
role :web, NODES
role :db,  NODES.first
role :cronjobs, NODES.last

set :rails_env, 'production'
set :bundle_without, %w( development test staging ).join(' ')

def tag_branch_target
  tags = `git tag`.split("\n")
  sorted_tags = tags.sort do |n, m|
    Gem::Version.new(n) <=> Gem::Version.new(m)
  end
  tag_prompt = "\nlast tags available are #{sorted_tags.last(5).reverse}"
  ask :branch_or_tag, tag_prompt
  tag = fetch(:branch_or_tag)
  tag.match(/^\d/).nil? ? sorted_tags.last : tag
end

set :branch, -> { tag_branch_target }
