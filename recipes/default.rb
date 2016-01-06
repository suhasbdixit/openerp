#
# Cookbook Name:: openerp
# Recipe:: default
#
# Copyright 2011, Clubit BVBA
#
# MIT License
#

script :fix_locale_in_session do
  interpreter "bash"
  user "root"
  code <<-EOH
    export 'LANGUAGE="en_US.UTF-8"'
    export 'LANG="en_US.UTF-8"'
    export 'LC_ALL="en_US.UTF-8"'
  EOH
end

script :add_locale do
  interpreter "bash"
  user "root"
  code <<-EOH
    echo 'LANGUAGE="en_US.UTF-8"' >> /etc/default/locale
    echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale
  EOH
end

# Create the OpenERP user that will own and run the application
# sudo adduser --system --home=/opt/openerp --group openerp

user "openerp" do
  comment "openerp"
  system true
  home "/opt/openerp"
  shell "/bin/false"
end

# Home directory is not automatically created, so we should do it ourselves

directory "/opt/openerp" do
  owner "openerp"
  group "openerp"
  mode "0755"
  action :create
end

# Create postgres user 'openerp'

pg_user "#{node["openerp"]["db_user"]}" do
  privileges :superuser => false, :createdb => true, :login => true
  password "#{node["openerp"]["db_password"]}"
end

# Install the necessary Python libraries for the server

# packages = [
#   # "python",
#   "python-pip",
#   "python-dateutil",
#   "python-docutils",
#   "python-feedparser",
#   "python-gdata",
#   "gunicorn",
#   "python-ldap",
#   "python-libxslt1",
#   "python-lxml",
#   "python-mako",
#   "python-openid",
#   "python-psutil",
#   "python-psycopg2",
#   "python-pybabel",
#   "python-pychart",
#   "python-pydot",
#   "python-pyparsing",
#   "python-reportlab",
#   "python-simplejson",
#   "python-tz",
#   "python-vatnumber",
#   "python-vobject",
#   "python-webdav",
#   "python-werkzeug",
#   "python-xlwt",
#   "python-yaml",
#   "python-zsi"]

# packages.each do |pkg|
#   package pkg
# end

# bash "install werkzeug via pip" do
#   cwd "/opt/openerp"
#   code <<-EOH
#     sudo pip install werkzeug
#   EOH
# end

apt_repository "anybox" do
  uri "http://apt.anybox.fr/openerp"
  components ["common","main"]
  keyserver "subkeys.pgp.net"
  key "0xE38CEB07"
end

execute "apt-get update" do
  command "apt-get update"
  ignore_failure true
  action :nothing
end

package "openerp-server-system-build-deps"
package "ttf-dejavu-core" # issue when dejavu font isn't installed
package "poppler-utils" # issue with email attachment

# Use pip to get the latest and greatest

packages = [
  "http://download.gna.org/pychart/PyChart-1.39.tar.gz",
  "babel",
  "docutils",
  "feedparser",
  "gdata",
  "gunicorn",
  "Jinja2",
  "lxml",
  "mako",
  "mock",
  "PIL",
  "psutil",
  "psycopg2",
  "pydot",
  "python-dateutil==1.5",
  "python-ldap",
  "python-openid",
  "pyopenssl",
  "pytz",
  "pywebdav",
  "pyyaml",
  "reportlab",
  "simplejson",
  "unittest2",
  "vatnumber",
  "vobject",
  "werkzeug",
  "xlwt"
]

packages.each do |pkg|
  python_pip pkg do
    action :install
  end
end


# Install the OpenERP server

remote_file "/opt/openerp/#{node["openerp"]["version"]}.tar.gz" do
  source "http://nightly.openerp.com/7.0/nightly/src/#{node["openerp"]["version"]}.tar.gz"
  action :create_if_missing
end

bash "untar openerp server" do
  cwd "/opt/openerp"
  code <<-EOH
    tar zxf #{node["openerp"]["version"]}.tar.gz
    sudo chown -R openerp: *
    sudo cp -a #{node["openerp"]["version"]} server
  EOH
end

# Create directory for logging

directory "/var/log/openerp" do
  owner "openerp"
  group "root"
  action :create
end
