# puppet-lib-file_concat

Library for concatenating multiple files into 1.

## Usage

### file_fragment

Creates a file fragment to be collected by file_concat based on the tag.

Example with exported resource:

    @@file_fragment { "uniqe_name_${::fqdn}":
      tag     => 'unique_tag',            # Mandatory
      order   => 10,                      # Optional. Default to 10
      content => 'some content'           # OR
      content => template('template.erb') # OR
      source  => 'puppet:///path/to/file'
    }

### file_concat

Gets all the file fragments and puts these into the target file.
This will mostly be used with exported resources.

example:
    
    File_fragment <<| tag == 'unique_tag' |>>

    file_concat { '/tmp/file':
      tag   => 'unique_tag', # Mandatory
      path  => '/tmp/file',  # Optional. If given it overrides the resource name
      owner => 'root',       # Optional. Default to root
      group => 'root',       # Optional. Default to root
      mode  => '0644'        # Optional. Default to 0644
    }
