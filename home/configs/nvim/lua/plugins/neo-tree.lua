return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    keys = {
        { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neo-tree" },
        { "<leader>o", "<cmd>Neotree focus<cr>", desc = "Focus Neo-tree" },
    },
    opts = {
        filesystem = {
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
        },
        window = {
            width = 30,
            mappings = {
                ["<space>"] = "none",  -- Don't conflict with leader
            },
        },
    },
}
