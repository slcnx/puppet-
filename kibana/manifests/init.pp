class kibana($elasticserver_fqdn) {
  package{'kibana':
	ensure	=>	installed,
	source	=>	"https://artifacts.elastic.co/downloads/kibana/kibana-5.6.6-x86_64.rpm",
	provider	=>	rpm,
  } ->

  file{'kibana.yml':
	content	=>	template('kibana/kibana.yml.erb'),
	path	=>	'/etc/kibana/kibana.yml',
  } ~>
  service{'kibana':
	ensure	=>	running,
  }
}
