node /agent.*/ {
  include chrony
  include elasticsearch
}

node 'agent1.magedu.com' {
  class{'kibana':
    elasticserver_fqdn => 'agent1.magedu.com',
  }    
}
