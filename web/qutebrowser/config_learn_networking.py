# See all available options in config-default.py

from config_common import set_common_options

set_common_options(config, c)

c.session.default_name = "learn-networking"
c.auto_save.session = True
