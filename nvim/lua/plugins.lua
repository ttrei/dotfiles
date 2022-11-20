-- https://github.com/wbthomason/packer.nvim/tree/6afb67460283f0e990d35d229fd38fdc04063e0a#bootstrapping

require('packer').startup(function(use)
  use 'https://github.com/matcatc/vim-asciidoc-folding'

  -- I will use the built-in visual star search for now.
  -- Revisit this decision if I find that the built-in feature lacks something.
  -- Not sure if this plugin does anything extra.
  -- It does use a different mapping, so it might handle a wider range of strings.
  -- use 'https://github.com/bronson/vim-visual-star-search.git'
end)
