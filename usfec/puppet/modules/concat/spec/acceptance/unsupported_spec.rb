require 'spec_helper_acceptance'

describe 'unsupported distributions and OSes', :if => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  basedir = default.tmpdir('concat')
  it 'should fail' do
    pp = <<-EOS
      include concat::setup
      concat { '#{basedir}/file':
        backup => 'puppet',
      }
      concat::fragment { 'new file':
        target  => '#{basedir}/file',
        content => 'new contents',
      }
    EOS
    expect(apply_manifest(pp, :expect_failures => true).stderr).to match(/unsupported/i)
  end
end
