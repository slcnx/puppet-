class elasticsearch {
	$packages=['java-1.8.0-openjdk-devel']
	package{$packages:
	 	ensure	=>	installed,
	} ->
	package{'ela':
		name	=>	'elasticsearch-5.6.6.rpm',
	 	ensure	=>	installed,
		source	=>	"http://172.16.0.1/elasticsearch-5.6.6.rpm",
		provider => 	rpm,
	} ->
	file{'elasticsearch.yml':
		ensure	=>	file,
		content	=>	template('elasticsearch/elasticsearch.erb'),
		path	=> 	'/etc/elasticsearch/elasticsearch.yml',
		mode	=>	'660',
		group	=>	'elasticsearch',
		owner	=>	'root',
	} ->
	file{'jvm.options':
		ensure	=>	file,
		content	=>	template('elasticsearch/jvm.options.erb'),
		path	=> 	'/etc/elasticsearch/jvm.options',
		mode	=>	'660',
		group	=>	'elasticsearch',
		owner	=>	'root',
	} ->
        file {'script':
                ensure  =>      file,
                source  =>      'puppet:///modules/elasticsearch/create_dir',
                path    =>      '/root/create_dir',
                mode    =>      '755',
                group   =>      'root',
                owner   =>      'root',
        } ->
	exec{'create_dir':
		command	=>	'/root/create_dir',
		path	=>	'/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
	} 
	service{'elasticsearch':
		ensure	=>	'true',
		enable	=>	'true',
		subscribe => [File['elasticsearch.yml'],File['jvm.options']]
	}
}
