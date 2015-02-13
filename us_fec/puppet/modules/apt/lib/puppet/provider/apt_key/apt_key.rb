require 'date'
require 'open-uri'
require 'net/ftp'
require 'tempfile'

if RUBY_VERSION == '1.8.7'
  # Mothers cry, puppies die and Ruby 1.8.7's open-uri needs to be
  # monkeypatched to support passing in :ftp_passive_mode.
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..',
                                    'puppet_x', 'apt_key', 'patch_openuri.rb'))
  OpenURI::Options.merge!({:ftp_active_mode => false,})
end

Puppet::Type.type(:apt_key).provide(:apt_key) do

  KEY_LINE = {
    :date     => '[0-9]{4}-[0-9]{2}-[0-9]{2}',
    :key_type => '(R|D)',
    :key_size => '\d{4}',
    :key_id   => '[0-9a-fA-F]+',
    :expires  => 'expire(d|s)',
  }

  confine    :osfamily => :debian
  defaultfor :osfamily => :debian
  commands   :apt_key  => 'apt-key'

  def self.instances
    if RUBY_VERSION > '1.8.7'
      key_output = apt_key('list').encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '')
    else
      key_output = apt_key('list')
    end
    key_array = key_output.split("\n").collect do |line|
      line_hash = key_line_hash(line)
      next unless line_hash
      expired = false

      if line_hash[:key_expiry]
        expired = Date.today > Date.parse(line_hash[:key_expiry])
      end

      new(
        :name    => line_hash[:key_id],
        :id      => line_hash[:key_id],
        :ensure  => :present,
        :expired => expired,
        :expiry  => line_hash[:key_expiry],
        :size    => line_hash[:key_size],
        :type    => line_hash[:key_type] == 'R' ? :rsa : :dsa,
        :created => line_hash[:key_created]
      )
    end
    key_array.compact!
  end

  def self.prefetch(resources)
    apt_keys = instances
    resources.keys.each do |name|
      if name.length == 16
        shortname=name[8..-1]
      else
        shortname=name
      end
      if provider = apt_keys.find{ |key| key.name == shortname }
        resources[name].provider = provider
      end
    end
  end

  def self.key_line_hash(line)
    line_array = line.match(key_line_regexp).to_a
    return nil if line_array.length < 5

    return_hash = {
      :key_id      => line_array[3],
      :key_size    => line_array[1],
      :key_type    => line_array[2],
      :key_created => line_array[4],
      :key_expiry  => nil,
    }

    return_hash[:key_expiry] = line_array[7] if line_array.length == 8
    return return_hash
  end

  def self.key_line_regexp
    # This regexp is trying to match the following output
    # pub   4096R/4BD6EC30 2010-07-10 [expires: 2016-07-08]
    # pub   1024D/CD2EFD2A 2009-12-15
    regexp = /\A
      pub  # match only the public key, not signatures
      \s+  # bunch of spaces after that
      (#{KEY_LINE[:key_size]})  # size of the key, usually a multiple of 1024
      #{KEY_LINE[:key_type]}  # type of the key, usually R or D
      \/  # separator between key_type and key_id
      (#{KEY_LINE[:key_id]})  # hex id of the key
      \s+  # bunch of spaces after that
      (#{KEY_LINE[:date]})  # date the key was added to the keyring
      # following an optional block which indicates if the key has an expiration
      # date and if it has expired yet
      (
        \s+  # again with thes paces
        \[  # we open with a square bracket
        #{KEY_LINE[:expires]}  # expires or expired
        \:  # a colon
        \s+  # more spaces
        (#{KEY_LINE[:date]})  # date indicating key expiry
        \]  # we close with a square bracket
      )?  # end of the optional block
      \Z/x
      regexp
  end

  def source_to_file(value)
    if URI::parse(value).scheme.nil?
      fail("The file #{value} does not exist") unless File.exists?(value)
      value
    else
      begin
        key = open(value, :ftp_active_mode => false).read
      rescue OpenURI::HTTPError, Net::FTPPermError => e
        fail("#{e.message} for #{resource[:source]}")
      rescue SocketError
        fail("could not resolve #{resource[:source]}")
      else
        tempfile(key)
      end
    end
  end

  def tempfile(content)
    file = Tempfile.new('apt_key')
    file.write content
    file.close
    file.path
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    command = []
    if resource[:source].nil? and resource[:content].nil?
      # Breaking up the command like this is needed because it blows up
      # if --recv-keys isn't the last argument.
      command.push('adv', '--keyserver', resource[:server])
      unless resource[:keyserver_options].nil?
        command.push('--keyserver-options', resource[:keyserver_options])
      end
      command.push('--recv-keys', resource[:id])
    elsif resource[:content]
      command.push('add', tempfile(resource[:content]))
    elsif resource[:source]
      command.push('add', source_to_file(resource[:source]))
    # In case we really screwed up, better safe than sorry.
    else
      fail("an unexpected condition occurred while trying to add the key: #{resource[:id]}")
    end
    apt_key(command)
    @property_hash[:ensure] = :present
  end

  def destroy
    apt_key('del', resource[:id])
    @property_hash.clear
  end

  def read_only(value)
    fail('This is a read-only property.')
  end

  mk_resource_methods

  # Needed until PUP-1470 is fixed and we can drop support for Puppet versions
  # before that.
  def expired
    @property_hash[:expired]
  end

  # Alias the setters of read-only properties
  # to the read_only function.
  alias :created= :read_only
  alias :expired= :read_only
  alias :expiry=  :read_only
  alias :size=    :read_only
  alias :type=    :read_only
end
