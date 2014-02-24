Given /^a remote mercurial cookbook named "(\w+)"$/ do |name|
  path = File.join(tmp_path, 'hg-cookbooks', name)
  FileUtils.mkdir_p(path)

  Dir.chdir(path) do
    hg('init')

    File.open('metadata.rb', 'w') do |f|
      f.write <<-EOH
        name '#{name}'
        version '1.0.0'
      EOH
    end

    hg('add')
    hg_commit('Initial commit')
  end
end

Given /^a remote mercurial cookbook named "(\w+)" with a branch named "(\w+)"$/ do |name, branch|
  path = File.join(tmp_path, 'hg-cookbooks', name)
  steps %Q|Given a remote mercurial cookbook named "#{name}"|

  Dir.chdir(path) do
    hg("branch #{branch}")

    File.open('metadata.rb', 'w') do |f|
      f.write <<-EOH
        name '#{name}'
        version '2.3.4'
      EOH
    end

    hg('add')
    hg_commit('More changes')
  end
end

def hg(command)
  %x|hg #{command}|
end

def hg_commit(message)
  hg %|--config ui.username=Berkshelf commit --message "#{message}"|
end
