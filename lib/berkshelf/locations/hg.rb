require 'digest/sha1'
require 'pathname'
require 'berkshelf'
require 'berkshelf/shell_out'

module Berkshelf
  class HgLocation < BaseLocation
    include Berkshelf::ShellOut

    class HgError < BerkshelfError; set_status_code(500); end

    class HgNotInstalled < HgError
      def initialize
        super 'You need to install Mercurial before you can download ' \
          'cookbooks from hg repositories. For more information, please ' \
          'see the Mercurial docs: http://mercurial.selenic.com/wiki/Download.'
      end
    end

    class HgCommandError < HgError
      def initialize(command, response, path = nil)
        super "Hg error: command `hg #{command}` failed. If this error " \
          "persists, try removing the cache directory at `#{path}'." \
          "\nstdout:#{response.stdout}\nstderr:#{response.stderr}"
      end
    end

    attr_reader :uri
    attr_reader :branch
    attr_reader :tag
    attr_reader :ref

    attr_reader :rel
    attr_reader :revision

    def initialize(dependency, options = {})
      super

      @uri      = options[:hg]
      @branch   = options[:branch]
      @tag      = options[:tag]
      @ref      = options[:ref] || options[:branch] || options[:tag] || 'default'
      @revision = options[:revision]
      @rel      = options[:rel]
    end

    def cached_cookbook
      if installed?
        @cached_cookbook ||= CachedCookbook.from_path(install_path)
      else
        nil
      end
    end
    
    # Download the cookbook from the remote hg repository
    #
    # @return void
    def install
      if cached?
        # Update and checkout the correct ref
        Dir.chdir(cache_path) do
          hg %|pull|
        end
      else
        # Ensure the cache directory is present before doing anything
        FileUtils.mkdir_p(cache_path)

        Dir.chdir(cache_path) do
          hg %|clone #{uri} .|
        end
      end

      Dir.chdir(cache_path) do
        hg %|update --clean --rev #{revision || ref}|
        @revision ||= hg %|id -i|
      end

      # Gab the path where we should copy from (since it might be relative to
      # the root).
      copy_path = rel ? cache_path.join(rel) : cache_path

      begin 
        # Validate the thing we are copying is a Chef cookbook
        validate_cached!(copy_path)

        # Remove the current cookbook at this location (this is required or else
        # FileUtils will copy into a subdirectory in the next step)
        FileUtils.rm_rf(install_path)

        # Create the containing parent directory
        FileUtils.mkdir_p(install_path.parent)

        # Copy whatever is in the current cache over to the store
        FileUtils.cp_r(copy_path, install_path)

      ensure

        # Remove the .hg directory to save storage space
        # TODO this can have huge performance implications, 
        # make it a config option?
        if (hg_path = install_path.join('.hg')).exist?
          FileUtils.rm_r(hg_path)
        end

       FileUtils.rm_rf (copy_path)
      end
    end

    def scm_location?
      true
    end

    def ==(other)
      other.is_a?(HgLocation) &&
      other.uri == uri &&
      other.branch == branch &&
      other.tag == tag &&
      other.ref == ref &&
      other.rel == rel
    end

    def to_s
      info = tag || branch || ref[0...7]

      if rel
        "#{uri} (at #{info}/#{rel})"
      else
        "#{uri} (at #{info})"
      end
    end

    def to_lock
      out =  "    hg: #{uri}\n"
      out << "    revision: #{revision}\n"
      out << "    branch: #{branch}\n" if branch
      out << "    tag: #{tag}\n"       if tag
      out << "    rel: #{rel}\n"       if rel
      out
    end

    # Determine if this revision is installed.
    #
    # @return [Boolean]
    def installed?
      revision && install_path.exist?
    end

    private

    # Perform a mercurial command.
    #
    # @param [String] command
    #   the command to run
    # @param [Boolean] error
    #   whether to raise error if the command fails
    #
    # @raise [String]
    #   the +$stdout+ from the command
    def hg(command, error = true)
      unless Berkshelf.which('hg') || Berkshelf.which('hg.exe')
        raise HgNotInstalled.new
      end

      Berkshelf.log.debug("Running:hg #{command}")
      response = shell_out(%|hg #{command}|)
      Berkshelf.log.debug("response:hg #{response.stdout}")

      if response.error?
        raise HgCommandError.new(command, response, cache_path)
      end

      response.stdout.strip
    end

    # Determine if this hg repo has already been downloaded.
    #
    # @return [Boolean]
    def cached?
      cache_path.exist?
    end

    # The path where this cookbook would live in the store, if it were
    # installed.
    #
    # @return [Pathname, nil]
    def install_path
      Berkshelf.cookbook_store.storage_path
        .join("#{dependency.name}-#{revision}")
    end

    # The path where this hg repository is cached.
    #
    # @return [Pathname]
    def cache_path
      Pathname.new(Berkshelf.berkshelf_path)
        .join('.cache', 'hg', Digest::SHA1.hexdigest(uri))
    end
  end
end
