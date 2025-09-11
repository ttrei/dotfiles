def set_common_options(config, c):
    config.load_autoconfig(False)
    config.bind('xs', 'config-cycle statusbar.show always in-mode')
    config.bind('xt', 'config-cycle tabs.show always switching')

    c.statusbar.show = 'always'
    c.tabs.show = 'always'

    c.content.pdfjs = True
    c.tabs.position = "left"
