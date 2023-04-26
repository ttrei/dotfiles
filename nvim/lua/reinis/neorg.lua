-- https://github.com/nvim-neorg/neorg#-setup
-- https://github.com/nvim-neorg/neorg/wiki

require('neorg').setup {
    load = {
        ["core.defaults"] = {},
        ["core.completion"] = {
            config = {
                engine = "nvim-cmp",
            }
        },
        ["core.concealer"] = {},
        ["core.dirman"] = {
            config = {
                workspaces = {
                    notes = "~/dev/notes/norg",
                }
            }
        }
    }
}
