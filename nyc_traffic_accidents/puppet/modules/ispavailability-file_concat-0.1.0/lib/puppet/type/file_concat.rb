require 'puppet/type/file'
require 'puppet/type/file/owner'
require 'puppet/type/file/group'
require 'puppet/type/file/mode'
require 'puppet/util/checksums'
require 'puppet/type/file/source'

Puppet::Type.newtype(:file_concat) do
  @doc = "Gets all the file fragments and puts these into the target file.
    This will mostly be used with exported resources.

    example:
      File_fragment <<| tag == 'unique_tag' |>>

      file_concat { '/tmp/file:
        tag   => 'unique_tag', # Mandatory
        path  => '/tmp/file', # Optional. If given it overrides the resource name
        owner => 'root', # Optional. Default to root
        group => 'root', # Optional. Default to root
        mode  => '0644'  # Optional. Default to 0644
      }
  "

  ensurable

  # the file/posix provider will check for the :links property
  # which does not exist
  def [](value)
    if value == :links
      return false
    end

    super
  end

  newparam(:name, :namevar => true) do
    desc "Resource name"
  end

  newparam(:tag) do
    desc "Tag reference to collect all file_fragment's with the same tag"
  end

  newparam(:path) do
    desc "The output file"
    defaultto do
      resource.value(:name)
    end
  end

  newproperty(:owner, :parent => Puppet::Type::File::Owner) do
    desc "Desired file owner."
    defaultto 'root'
  end

  newproperty(:group, :parent => Puppet::Type::File::Group) do
    desc "Desired file group."
    defaultto 'root'
  end

  newproperty(:mode, :parent => Puppet::Type::File::Mode) do
    desc "Desired file mode."
    defaultto '0644'
  end

  newproperty(:content) do
    desc "Read only attribute. Represents the content."

    include Puppet::Util::Diff
    include Puppet::Util::Checksums

    defaultto do
      # only be executed if no :content is set
      @content_default = true
      @resource.no_content
    end

    validate do |val|
      fail "read-only attribute" if !@content_default
    end

    def insync?(is)
      result = super

      if ! result
        string_file_diff(@resource[:path], @resource.should_content)
      end

      result
    end

    def is_to_s(value)
      md5(value)
    end

    def should_to_s(value)
      md5(value)
    end
  end

  def no_content
    "\0PLEASE_MANAGE_THIS_WITH_FILE_CONCAT\0"
  end

  def should_content
    return @generated_content if @generated_content
    @generated_content = ""
    content_fragments = []

    catalog.resources.select do |r|
      r.is_a?(Puppet::Type.type(:file_fragment)) && r[:tag] == self[:tag]
    end.each do |r|

     if r[:content].nil? == false
       fragment_content = r[:content]
     elsif r[:source].nil? ==false
       tmp = Puppet::FileServing::Content.indirection.find(r[:source], :environment => catalog.environment)
       fragment_content = tmp.content
     end

      content_fragments << [
        "#{r[:order]}___#{r[:name]}", fragment_content
      ]
    end

    sorted = content_fragments.sort do |a, b|
      def decompound(d)
        d.split('___').map { |d| d =~ /^\d+$/ ? d.to_i : d }
      end

      decompound(a[0]) <=> decompound(b[0])
    end

    @generated_content = sorted.map { |cf| cf[1] }.join

    @generated_content
  end

  def stat(dummy_arg = nil)
    return @stat if @stat and not @stat == :needs_stat
    @stat = begin
      ::File.stat(self[:path])
    rescue Errno::ENOENT => error
      nil
    rescue Errno::EACCES => error
      warning "Could not stat; permission denied"
      nil
    end
  end

  ### took from original type/file
  # There are some cases where all of the work does not get done on
  # file creation/modification, so we have to do some extra checking.
  def property_fix
    properties.each do |thing|
      next unless [:mode, :owner, :group].include?(thing.name)

      # Make sure we get a new stat object
      @stat = :needs_stat
      currentvalue = thing.retrieve
      thing.sync unless thing.safe_insync?(currentvalue)
    end
  end
end
