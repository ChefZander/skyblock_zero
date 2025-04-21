return {
	type = "table",
	entries = {
		skindb = {
			type = "table",
			entries = {
				autosync = {
					type = "boolean",
					description = "Automatically sync with SkinDB at startup, continue syncing during game",
					default = true
				}
			}
		}
	}
}