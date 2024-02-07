local M = {}

-- Credit to https://github.com/mrcjkb/rustaceanvim/blob/8940ef5c7e3ffd37712ac0556832b5b10a136874/lua/rustaceanvim/health.lua
local h = vim.health or require('health')
---@diagnostic disable-next-line: deprecated
local start = h.start or h.report_start
---@diagnostic disable-next-line: deprecated
local ok = h.ok or h.report_ok
---@diagnostic disable-next-line: deprecated
local error = h.error or h.report_error
---@diagnostic disable-next-line: deprecated
local warn = h.warn or h.report_warn

local function check_import(dep)
  if pcall(require, dep.module) then
    ok(dep.name .. ' installed')
    return
  end
  error(dep.name .. ' not installed')
end

M.check = function ()
  start("Checking for required dependencies")

  check_import({ module = 'plenary.curl', name = 'plenary.nvim' })

  start("Checking for required configuration")

  if vim.g.RemoteText == nil then
    error("vim.g.RemoteText is not set!")
  else
    ok("vim.g.RemoteText exists")
  end
  if vim.g.RemoteText.api_url == nil then
    error("API URL is not set")
  else
    ok("API URL is set to " .. vim.g.RemoteText.api_url)
  end
end

return M
