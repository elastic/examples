require 'spec_helper_acceptance'

describe 'concat order', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  basedir = default.tmpdir('concat')
  before(:all) do
    shell("rm -rf #{basedir} #{default.puppet['vardir']}/concat")
    shell("mkdir -p #{basedir}")
  end

  context '=> alpha' do
    pp = <<-EOS
      include concat::setup
      concat { '#{basedir}/foo':
        order => 'alpha'
      }
      concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'string1',
      }
      concat::fragment { '2':
        target  => '#{basedir}/foo',
        content => 'string2',
      }
      concat::fragment { '10':
        target  => '#{basedir}/foo',
        content => 'string10',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/foo") do
      it { should be_file }
      #XXX Solaris 10 doesn't support multi-line grep
      it("should contain string10\nstring1\nsring2", :unless => (fact('osfamily') == 'Solaris' or UNSUPPORTED_PLATFORMS.include?(fact('osfamily')))) {
        should contain "string10\nstring1\nsring2"
      }
    end
  end

  context '=> numeric' do
    pp = <<-EOS
      include concat::setup
      concat { '#{basedir}/foo':
        order => 'numeric'
      }
      concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'string1',
      }
      concat::fragment { '2':
        target  => '#{basedir}/foo',
        content => 'string2',
      }
      concat::fragment { '10':
        target  => '#{basedir}/foo',
        content => 'string10',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/foo") do
      it { should be_file }
      #XXX Solaris 10 doesn't support multi-line grep
      it("should contain string1\nstring2\nsring10", :unless => (fact('osfamily') == 'Solaris' or UNSUPPORTED_PLATFORMS.include?(fact('osfamily')))) {
        should contain "string1\nstring2\nsring10"
      }
    end
  end
end # concat order

describe 'concat::fragment order', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  basedir = default.tmpdir('concat')
  before(:all) do
    shell("rm -rf #{basedir} #{default.puppet['vardir']}/concat")
    shell("mkdir -p #{basedir}")
  end

  context '=> reverse order' do
    pp = <<-EOS
      include concat::setup
      concat { '#{basedir}/foo': }
      concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'string1',
        order   => '15',
      }
      concat::fragment { '2':
        target  => '#{basedir}/foo',
        content => 'string2',
        # default order 10
      }
      concat::fragment { '3':
        target  => '#{basedir}/foo',
        content => 'string3',
        order   => '1',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/foo") do
      it { should be_file }
      #XXX Solaris 10 doesn't support multi-line grep
      it("should contain string3\nstring2\nsring1", :unless => (fact('osfamily') == 'Solaris' or UNSUPPORTED_PLATFORMS.include?(fact('osfamily')))) {
        should contain "string3\nstring2\nsring1"
      }
    end
  end

  context '=> normal order' do
    pp = <<-EOS
      include concat::setup
      concat { '#{basedir}/foo': }
      concat::fragment { '1':
        target  => '#{basedir}/foo',
        content => 'string1',
        order   => '01',
      }
      concat::fragment { '2':
        target  => '#{basedir}/foo',
        content => 'string2',
        order   => '02'
      }
      concat::fragment { '3':
        target  => '#{basedir}/foo',
        content => 'string3',
        order   => '03',
      }
    EOS

    it 'applies the manifest twice with no stderr' do
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file("#{basedir}/foo") do
      it { should be_file }
      #XXX Solaris 10 doesn't support multi-line grep
      it("should contain string1\nstring2\nsring3", :unless => (fact('osfamily') == 'Solaris' or UNSUPPORTED_PLATFORMS.include?(fact('osfamily')))) {
        should contain "string1\nstring2\nsring3"
      }
    end
  end
end # concat::fragment order
