return {
    {
        "zbirenbaum/copilot.lua",
        enabled = true,
        event = "BufEnter",
        opts = {
            suggestion = { enabled = true, auto_trigger = true },
            panel = { enabled = false },
        },
    },
    {
        "zbirenbaum/copilot-cmp",
        enabled = true,
        opts = {}
    }
}
