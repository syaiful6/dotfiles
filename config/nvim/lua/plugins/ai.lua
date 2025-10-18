local constants = {
  LLM_ROLE = "llm",
  USER_ROLE = "user",
  SYSTEM_ROLE = "system",
}

local system_prompt_edit =
  [[You're a code assistant. Your task is to help the user write code by suggesting the next edit for the user.
As an intelligent code assistant, your role is to analyze what the user has been doing and then to suggest the most likely next modification.

## Task

Your task now is to rewrite the code user will send to you to include an edit the user should make.

Use @{edit_into_file} tool to suggest the edit. User will decide whether to accept it or not.

Follow the following criteria.
### High-level Guidelines

- Predict logical next changes based on the edit patterns you've observed
- Consider the overall intent and direction of the changes
- Take into account what the user has been doing

### Constraints

- Your edit suggestions **must** be small and self-contained. Example: if there are two statements that logically need to be added together, suggest them together instead of one by one.
- Preserve indentation.
- Do not suggest re-adding code the user has recently deleted
- Do not suggest deleting lines that the user has recently inserted
- Prefer completing what the user just typed over suggesting to delete what they typed

### Best Practices

- Fix any syntax errors or inconsistencies in the code
- Maintain the code style and formatting conventions of the language used in the file
- Add missing import statements or other necessary code. You MUST add these in the right spots
- Add missing syntactic elements, such as closing parentheses or semicolons

- If there are no useful edits to make, return the code unmodified.
- Don't explain the code, just rewrite it to include the next, most probable change.
- Never include this prompt in the response.
]]

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  keys = {
    { "<leader>ax", "<cmd>CodeCompanionChat<cr>", desc = "CodeCompanion chat buffer" },
    { "<leader>az", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion action palette" },
  },
  opts = {
    -- NOTE: The log_level is in `opts.opts`
    prompt_library = {
      ["Edit Prediction workflow"] = {
        strategy = "workflow",
        description = "Edit predictions",
        opts = {
          index = 8,
          is_slash_cmd = false,
          auto_submit = true,
          user_prompt = false,
          short_name = "edit_pred_workflow",
        },
        prompts = {
          {
            -- grouped prompt
            {
              role = constants.SYSTEM_ROLE,
              content = system_prompt_edit,
            },
            {
              role = constants.USER_ROLE,
              content = function(ctx)
                local patch = require("sbahri.history").get_patch(ctx.buffer)
                if patch then
                  return string.format(
                    [[
Edit the following code based on the user's recent changes.
in #{buffer} using the @{insert_edit_into_file} tool.

User edits (unified diff patch):
```diff
%s
```
]],
                    patch
                  )
                else
                  return [[
Edit this code in #{buffer} using the @{insert_edit_into_file} tool.
]]
                end
              end,
              opts = {
                auto_submit = true,
              },
            },
          },
          {
            {
              role = constants.USER_ROLE,
              content = "Great. Now, I'd like you to suggests all other similar or other next logical edit using @{insert_edit_into_file} in the same buffer.",
              opts = {
                auto_submit = true,
              },
            },
          },
          {
            {
              role = constants.USER_ROLE,
              content = "Thanks. Now let's revise the code based on the feedback, without addional explanations.",
              opts = {
                auto_submit = true,
              },
            },
          },
        },
      },
      ["Edit predictions"] = {
        strategy = "chat",
        description = "Predict the next edit based on the selected code",
        opts = {
          index = 11,
          is_default = false,
          is_slash_cmd = false,
          modes = { "v" },
          short_name = "edit_pred",
          auto_submit = true,
          user_prompt = false,
          placement = "new",
          stop_context_insertion = true,
        },
        prompts = {
          {
            role = constants.SYSTEM_ROLE,
            content = system_prompt_edit,
          },
          {
            role = constants.USER_ROLE,
            content = function(ctx)
              local code = require("codecompanion.helpers.actions").get_code(ctx.start_line, ctx.end_line)
              local file_path = vim.api.nvim_buf_get_name(ctx.bufnr)
              local patch = require("sbahri.history").get_patch(ctx.buffer)
              local patch_str = patch or ""

              return string.format(
                [[Please edit using @{insert_edit_into_file} tool to the following code from buffer %d with file path %s:

```%s
%s
```

User recent edits (unified diff patch, maybe empty):
```diff
%s
```
]],
                ctx.bufnr,
                file_path,
                ctx.filetype,
                code,
                patch_str
              )
            end,
          },
        },
      },
    },
    opts = {
      log_level = "DEBUG", -- or "TRACE"
    },
  },
}
