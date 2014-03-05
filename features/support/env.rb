require 'aruba/cucumber'
require 'aruba/in_process'
require 'berkshelf'

Before do
  Aruba::InProcess.main_class = Berkshelf::Cli::Runner
  Aruba.process = Aruba::InProcess

  @aruba_timeout_seconds = 30

  ENV['BERKSHELF_PATH'] = tmp_path
end

def tmp_path
  File.expand_path('tmp/aruba')
end
