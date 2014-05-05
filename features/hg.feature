Feature: Installing from a mercurial location
  Scenario: In the default scenario
    * a remote mercurial cookbook named "fake"
    * I write to "Berksfile" with:
      """
      source 'https://api.berkshelf.com'
      extension 'hg'

      cookbook 'fake', hg: "file://localhost#{Dir.pwd}/hg-cookbooks/fake"
      """
    * I successfully run `berks install`
    * the output should contain "Using fake (1.0.0)"

  Scenario: When a branch is given
    * a remote mercurial cookbook named "fake" with a branch named "development"
    * I write to "Berksfile" with:
      """
      source 'https://api.berkshelf.com'
      extension 'hg'

      cookbook 'fake', hg: "file://localhost#{Dir.pwd}/hg-cookbooks/fake", branch: 'development'
      """
    * I successfully run `berks install`
    * the output should contain "Using fake (2.3.4)"

  Scenario: When a relative path is given
   * a remote mercurial repo with two cookbooks named "fakeA" and "fakeB"
   * I write to "Berksfile" with:
      """
      source 'https://api.berkshelf.com'
      extension 'hg'

      cookbook 'fakeA', hg: "file://localhost#{Dir.pwd}/hg-cookbooks", rel: "site-cookbooks/fakeA"
      cookbook 'fakeB', hg: "file://localhost#{Dir.pwd}/hg-cookbooks", rel: "site-cookbooks/fakeB"
      """ 

   * I successfully run `berks install`
   * the output should contain "Using fakeA (1.0.1)"
   * the output should contain "Using fakeB (1.0.1)"
