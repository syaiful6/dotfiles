return {
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      local devicons = require("nvim-web-devicons")

      -- Get the default OCaml icon, or use a fallback
      local ocaml_config = devicons.get_icon("file.ml", "ml")
      local ocaml_icon = ocaml_config or ""
      local default_ocaml_color = "#ee6a1a"

      devicons.set_icon({
        mlx = {
          icon = ocaml_icon,
          color = default_ocaml_color,
          name = "mlx",
        },
        mly = {
          icon = ocaml_icon,
          color = default_ocaml_color,
          name = "mly",
        },
        re = {
          icon = ocaml_icon,
          color = "#dd4B39",
          name = "reason",
        },
        rei = {
          icon = ocaml_icon,
          color = "#dd4B39",
          name = "reasoninterface",
        },
        dune = {
          icon = ocaml_icon,
          color = "#b0b1b0",
          name = "dune",
        },
        ["dune-project"] = {
          icon = ocaml_icon,
          color = "#b0b1b0",
          name = "dune-project",
        }
      })
    end,
  }
}
