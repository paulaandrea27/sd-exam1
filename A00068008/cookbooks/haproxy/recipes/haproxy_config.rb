service 'haproxy' do
  action [ :start, :enable ]
end

template '/etc/haproxy/haproxy.cfg' do
	source 'haproxy.erb'
	mode 0644
	owner 'root'
	group 'wheel'
	variables(
		:web_servers => node[:web_servers]
	)
end

template '/etc/sysconfig/rsyslog' do
	source 'rsyslog.erb'
	mode 0644
	owner 'root'
	group 'wheel'
end

service 'haproxy' do
  action [ :restart ]
end
