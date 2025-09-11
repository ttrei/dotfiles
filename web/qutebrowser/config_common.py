def set_common_options(config):
    config.load_autoconfig(False)
    config.bind('xs', 'config-cycle statusbar.show always never')
    config.bind('xt', 'config-cycle tabs.show always never')

    c.content.pdfjs = True
    c.tabs.position = "left"
