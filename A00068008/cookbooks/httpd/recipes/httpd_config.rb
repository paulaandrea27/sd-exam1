service 'httpd' do
  action [ :enable, :start ]
end

template '/var/www/html/index.html' do
  source 'index.erb'
  owner 'vagrant'
  group 'vagrant'
  mode 0644
  action :create
        variables(
                service_name: node[:service_name],
		ip: node[:ip]
        )
end

template '/var/www/html/template.html' do
	source 'template.erb'
	mode 0644
	owner 'vagrant'
	group 'vagrant'
	variables(
		service_name: node[:service_name],
		ip: node[:ip]
	)
end

