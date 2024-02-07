local M = {}

local curl = require('plenary.curl')

M.run = function ()
  local API_URL = vim.g.RemoteText.api_url or error('API URL is not set')

  local files_response = curl.get(API_URL .. '/listFiles')
  if files_response.status ~= 200 then
    error('HTTP error' .. files_response.status)
    return
  end
  local files = vim.json.decode(files_response.body)

  vim.ui.select(files, {
    prompt = 'Choose a file to edit:',
    format_item = function (item)
      return item.name
    end
  }, function (choice)
      local id = choice.id

      local historyResp = curl.post(API_URL .. '/getHistory', {
        body = vim.json.encode({ id = id }),
        headers = {
          content_type = 'application/json'
        }
      })

      local refs = vim.json.decode(historyResp.body).refs
      local hash = ''
      for _, ref in ipairs(refs) do
        if ref.name == 'main' then
          hash = ref.hash
          break
        end
      end
      if hash == '' then
        for _, ref in ipairs(refs) do
          if ref.name == 'master' then
            hash = ref.hash
          end
        end
      end

      local contentResp = curl.post(API_URL .. '/getFile', {
        body = vim.json.encode({ id = id, hash = hash }),
        headers = {
          content_type = 'application/json'
        }
      })

      local file = vim.json.decode(contentResp.body)

      -- Credit to https://stackoverflow.com/a/19908161/8387516 for the string splitting
      local lines = { "" }
      for s in (file.content .. "\n"):gmatch("([^\r\n]*)\n") do
        table.insert(lines,s)
      end

      local buf_id = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_buf_set_name(buf_id, file.name)
      vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
      -- Options are vim.bo.X, and in VimL you use `:set X`
      -- Variables are vim.b.X, and in VimL you use :let b:X`
      vim.api.nvim_buf_set_var(buf_id, 'RemoteText', { id = id, hash = hash, branch = 'main' })
      vim.api.nvim_create_autocmd('BufWriteCmd', {
        buffer = buf_id,
        desc = 'Save changed file to RemoteText',
        callback = function (ev)
          -- Swapped to `0` (the current buffer) in case `:sav` is used
          -- local new_lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
          local new_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local details = vim.b.RemoteText
          local new_json = {
            name = vim.fn.expand('%:t'),
            id = details.id,
            content = table.concat(new_lines, '\n'),
            parent = details.hash,
            branch = details.branch
          }

          local saveResp = curl.post(API_URL .. '/saveFile', {
            body = vim.json.encode(new_json),
            headers = {
              content_type = 'application/json'
            }
          })

          if saveResp.status == 200 then
            vim.api.nvim_buf_set_option(0, 'modified', false)

            local commit = vim.json.decode(saveResp.body)
            for k, v in pairs(commit) do
              print(k,v)
            end

            print(vim.b.RemoteText)
            vim.b.RemoteText.hash = commit.hash
            print(vim.b.RemoteText)
            vim.b.RemoteText = { hash = commit.hash }
            print(vim.b.RemoteText)
          end
        end
      })
      vim.api.nvim_set_current_buf(buf_id)

      -- -- In order to make :undo a no-op immediately after the buffer is read, we
      -- -- need to do this dance with 'undolevels'.  Actually discarding the undo
      -- -- history requires performing a change after setting 'undolevels' to -1 and,
      -- -- luckily, we have one we need to do (delete the extra line from the :r
      -- -- command)
      -- -- (Comment straight from goerz/jupytext.vim)
      -- (Comment from and credit to https://github.com/GCBallesteros/jupytext.nvim/blob/92547b14cfb101498e5f4200812c32eab3b84e43/lua/jupytext/init.lua#L148-L157)
      local levels = vim.o.undolevels
      vim.o.undolevels = -1
      vim.api.nvim_command "silent 1delete"
      vim.o.undolevels = levels

      vim.api.nvim_buf_set_option(buf_id, 'modified', false)

      -- TODO: I *think* this does not properly load ftplugins
      vim.cmd.filetype("detect")
    end)
end

return M
--[[
local rt = require('remote-text')
local opts = { noremap = true, silent = true, buffer = bufnr, }
vim.keymap.set('n', '<leader>rt', rt.run, opts)
vim.api.nvim_create_user_command('RemoteText', rt.run, {})
--]]
