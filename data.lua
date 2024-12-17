require("prototypes.sprites")
require("prototypes.styles")

data:extend{
    {
        type = "custom-input",
        name = "FAS-left-click",
        key_sequence = "mouse-button-1"
    },
    {
        type = "custom-input",
        name = "FAS-right-click",
        key_sequence = "mouse-button-2"
    },
    {
        type = "custom-input",
        name = "FAS-selection-toggle-shortcut",
        key_sequence = "SHIFT + ALT + S"
    },
    {
        type = "custom-input",
        name = "FAS-delete-area-shortcut",
        key_sequence = "SHIFT + ALT + D"
    },
    {
        type = "custom-input",
        name = "FAS-toggle-GUI",
        key_sequence = ""
    },
    {
		type = "selection-tool",
		name = "FAS-selection-tool",
        icon = "__FacAutoScreenshot_Updated__/graphics/FAS-24px.png",
        icon_size = 24,
		select = {
		  border_color = { r = 1, g = 0.5, b = 0 },
		  cursor_box_type = "entity",
		  mode = "nothing"
		},
		alt_select = {
		  border_color = { r = 0, g = 0, b = 0 },
		  cursor_box_type = "entity",
		  mode = "nothing"
		},
		stack_size = 1,
		flags = {"hide-from-bonus-gui", "only-in-cursor", "not-stackable"},
    }
}