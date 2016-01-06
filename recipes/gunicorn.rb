template "/etc/openerp-server.conf.py" do
  source "gunicorn.conf.py.erb"
  owner "openerp"
  group "root"
  mode 0640
end