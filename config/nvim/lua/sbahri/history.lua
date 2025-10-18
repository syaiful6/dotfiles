--- This module takes snapshots of buffer contents and generates diffs
--- The usage is to give the context to AI models.

local M = {}

local buffer_snapshots = {}
local augroup_ids = {}

--- Start tracking a buffer by taking a snapshot of its current content
-- @param bufnr number|nil Buffer number (defaults to current)
function M.start_listening(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Take initial snapshot
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  buffer_snapshots[bufnr] = {
    lines = vim.deepcopy(lines),
    timestamp = os.time(),
  }

  -- Set up cleanup on buffer delete
  if not augroup_ids[bufnr] then
    local group = vim.api.nvim_create_augroup("BufferHistory_" .. bufnr, { clear = true })
    augroup_ids[bufnr] = group

    vim.api.nvim_create_autocmd("BufDelete", {
      group = group,
      buffer = bufnr,
      callback = function()
        buffer_snapshots[bufnr] = nil
        augroup_ids[bufnr] = nil
      end,
      desc = "Cleanup buffer snapshot on delete",
    })
  end
end

--- Stop tracking a buffer
-- @param bufnr number|nil Buffer number (defaults to current)
function M.stop_listening(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local group = augroup_ids[bufnr]
  if group then
    vim.api.nvim_del_augroup_by_id(group)
    augroup_ids[bufnr] = nil
  end
  buffer_snapshots[bufnr] = nil
end

--- Clear snapshot for a buffer (takes a new snapshot of current state)
-- @param bufnr number|nil Buffer number (defaults to current)
function M.clear_history(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if buffer_snapshots[bufnr] then
    M.start_listening(bufnr)
  end
end

--- Check if a buffer is being tracked
-- @param bufnr number|nil Buffer number (defaults to current)
-- @return boolean True if buffer has a snapshot
function M.is_tracking(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return buffer_snapshots[bufnr] ~= nil
end

--- List all buffers with snapshots
-- @return table List of buffer numbers
function M.list_buffers()
  local bufs = {}
  for bufnr, _ in pairs(buffer_snapshots) do
    table.insert(bufs, bufnr)
  end
  return bufs
end

local function unified_diff(old, new, cursor_line)
  local diff_lines = {}
  local i = 1
  local old_len, new_len = #old, #new

  while i <= math.max(old_len, new_len) do
    -- Find start of difference
    while i <= math.min(old_len, new_len) and old[i] == new[i] do
      i = i + 1
    end

    if i > math.max(old_len, new_len) then
      break
    end

    -- Found a difference, collect the hunk
    local hunk_start = math.max(1, i - 3) -- 3 lines of context
    local j = i

    -- Find end of difference block
    while j <= math.max(old_len, new_len) do
      if j <= math.min(old_len, new_len) and old[j] == new[j] then
        -- Check if we have 3 matching lines (end of hunk)
        local match_count = 0
        for k = j, math.min(old_len, new_len) do
          if old[k] == new[k] then
            match_count = match_count + 1
            if match_count >= 3 then
              break
            end
          else
            break
          end
        end
        if match_count >= 3 then
          break
        end
      end
      j = j + 1
    end

    local hunk_end = math.min(math.max(old_len, new_len), j + 3)
    local old_count = math.min(old_len, hunk_end) - hunk_start + 1
    local new_count = math.min(new_len, hunk_end) - hunk_start + 1

    -- Add hunk header with cursor info
    local cursor_info = ""
    if cursor_line and cursor_line >= hunk_start and cursor_line <= hunk_end then
      cursor_info = string.format(" (cursor at line %d)", cursor_line)
    end
    table.insert(
      diff_lines,
      string.format("@@ -%d,%d +%d,%d @@%s", hunk_start, old_count, hunk_start, new_count, cursor_info)
    )

    -- Add context and changes
    for k = hunk_start, hunk_end do
      if k > old_len then
        if k <= new_len then
          table.insert(diff_lines, "+" .. new[k])
        end
      elseif k > new_len then
        table.insert(diff_lines, "-" .. old[k])
      elseif old[k] == new[k] then
        table.insert(diff_lines, " " .. old[k])
      else
        table.insert(diff_lines, "-" .. old[k])
        table.insert(diff_lines, "+" .. new[k])
      end
    end

    i = hunk_end + 1
  end

  return table.concat(diff_lines, "\n")
end

--- Get a unified patch from snapshot to current buffer state
-- @param bufnr number|nil Buffer number (defaults to current)
-- @return string|nil Unified diff patch, or nil if no snapshot exists or no changes
function M.get_patch(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local snapshot = buffer_snapshots[bufnr]

  if not snapshot then
    return nil
  end

  -- Get current buffer state
  local current_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local cursor_line = cursor_pos[1]
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  if bufname == "" then
    bufname = "[No Name]"
  end

  -- Check if there are any changes
  if vim.deep_equal(snapshot.lines, current_lines) then
    return nil
  end

  local diff_content = unified_diff(snapshot.lines, current_lines, cursor_line)
  if diff_content == "" then
    return nil
  end

  local patch = {
    string.format("--- a/%s", bufname),
    string.format("+++ b/%s", bufname),
    diff_content,
  }

  return table.concat(patch, "\n")
end

return M
