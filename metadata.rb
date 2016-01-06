maintainer        "Clubit BVBA"
maintainer_email  "cookbooks@clubit.be"
license           "Apache 2.0"
description       "Configures openerp"
version           "1.0.0"
recipe            "openerp", "Basic requirement for running OpenERP"
recipe            "openerp::openerp_server", "Runs OpenERP with build-in server"
recipe            "openerp::gunicorn", "Runs OpenERP with gunicorn"

%w{ ubuntu debian }.each do |os|
  supports os
end
