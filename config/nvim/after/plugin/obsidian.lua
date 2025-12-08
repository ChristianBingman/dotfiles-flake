require("obsidian").setup({
  workspaces = {
    {
      name = "Personal",
      path = "~/Documents/Obsidian/Personal"
    },
    {
      name = "Meraki",
      path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Meraki"
    },
    {
      name = "Personal",
      path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Personal"
    },
    {
      name = "Projects",
      path = "~/Documents/Obsidian/Projects"
    },
  },
  daily_notes = {
    folder = "Daily Notes",
    template = "Daily Note Template",
    date_format = "%Y-%m-%d",
  },
  templates = {
    folder = "Templates",
  },
  new_notes_location = "Notes",
  legacy_commands = false,
})
