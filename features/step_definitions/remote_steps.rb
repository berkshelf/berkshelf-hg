Given /^a remote mercurial cookbook named "(\w+)"$/ do |name|
  path = File.join(tmp_path, 'hg-cookbooks', name)
  FileUtils.mkdir_p(path)

  Dir.chdir(path) do
    hg('init')
    write_metadata(name, '1.0.0')
    hg('add')
    hg_commit('Initial commit')
  end
end



Given /^a remote mercurial cookbook named "(\w+)" with a branch named "(\w+)"$/ do |name, branch|
  path = File.join(tmp_path, 'hg-cookbooks', name)
  steps %Q|Given a remote mercurial cookbook named "#{name}"|

  Dir.chdir(path) do
    hg("branch #{branch}")
    write_metadata(name, '2.3.4')
    hg('add')
    hg_commit('More changes')
  end
end


Given(/^a remote mercurial repo with two cookbooks named "(.*?)" and "(.*?)"$/) do |name1, name2|
  project_path = File.join(tmp_path, 'hg-cookbooks')
  [name1,name2].each do |name|
    cookbook_path = File.join(project_path,'site-cookbooks',name)
    FileUtils.mkdir_p(cookbook_path)
    write_metadata(name, '1.0.1',cookbook_path)
  end
  Dir.chdir(project_path) do 
    hg("init")
    hg('add')
    hg_commit('adding_cookbooks')
  end

end

def write_metadata(name,version,path="./") 
  File.open(File.join(path,"metadata.rb"), "w") do |f|
      f.write <<-EOH
        name '#{name}'
        version '#{version}'
      EOH
  end
end

def hg(command)
  %x|hg #{command}|
end

def hg_commit(message)
  hg %|--config ui.username=Berkshelf commit --message "#{message}"|
end
