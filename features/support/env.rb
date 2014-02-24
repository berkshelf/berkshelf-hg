require 'aruba/cucumber'
require 'berkshelf'

Before do
  @aruba_timeout_seconds = 30
  set_env('BERKSHELF_PATH', tmp_path)
end

def tmp_path
  File.expand_path('tmp/aruba')
end
