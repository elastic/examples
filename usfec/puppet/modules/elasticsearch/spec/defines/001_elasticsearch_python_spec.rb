require 'spec_helper'

describe 'elasticsearch::python', :type => 'define' do

  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat'
  } end

  [ 'pyes', 'rawes', 'pyelasticsearch', 'ESClient', 'elasticutils', 'elasticsearch' ].each do |pythonlib|

    context "installation of library #{pythonlib}" do

      let(:title) { pythonlib }

      it { should contain_elasticsearch__python(pythonlib) }
      it { should contain_package("python_#{pythonlib}").with(:provider => 'pip', :name => pythonlib) }

    end

  end

end
