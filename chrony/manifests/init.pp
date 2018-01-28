class chrony { 	    
	package{'chrony':
	    ensure  =>  latest, 
	} ->

	# 查看配置文件的owner, group, permission.
	file{'chrony.conf':
	    ensure  =>  file,   
	    source  =>  'puppet:///modules/chrony/chrony.conf',
	    path    =>  '/etc/chrony.conf',
	    owner   =>  'root', 
	    group   =>  'root', 
	    mode    =>  '0644', 
	} 

	# 监控着file是否产生事件
	service{'chronyd':
	    ensure  =>  running,
	    enable  =>  true,   
	    subscribe   =>  File['chrony.conf'],
	}
}
