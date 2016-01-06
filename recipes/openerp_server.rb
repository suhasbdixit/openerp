# Configuring the OpenERP server

template "/etc/openerp-server.conf" do
  source "openerp-server.conf.erb"
  owner "openerp"
  group "root"
  mode 0640
end

template "/etc/init.d/openerp-server" do
  source "openerp-server.erb"
  owner "root"
  mode 0755
end

service "openerp-server" do
  service_name "openerp-server"
  supports :restart => true, :status => true, :reload => true
  action [ :enable, :start ]
end

# Install openerp vhost
template "/etc/nginx/sites-available/openerp" do
  mode "0644"
  source "openerp.erb"
end

# Enable openerp vhost
link "/etc/nginx/sites-enabled/openerp" do
  to "/etc/nginx/sites-available/openerp"
  notifies :reload, resources(:service => "nginx")
end

# Disable default vhost (allows lightingclub vhost to serve http://localhost)
link "/etc/nginx/sites-enabled/default" do
  action :delete
  notifies :reload, resources(:service => "nginx")
end