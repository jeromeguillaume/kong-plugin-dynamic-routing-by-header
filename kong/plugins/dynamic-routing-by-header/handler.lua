-- handler.lua
local plugin = {
    PRIORITY = 1000,
    VERSION = "0.1",
  }

-- Executed for every request upon its reception from a client as a rewrite phase handler.
-- In this phase, neither the Service nor the Consumer have been identified, hence this handler will only be executed if the plugin was configured as a global plugin.
function plugin:rewrite(plugin_conf)
  local auhtN_Header = kong.request.get_header("Authorization")
  if (not auhtN_Header) then
    kong.log.debug("Unable to get 'Authorization' header")
    return
  end

  -- We have 2 types of Authorization
  -- Example1: Authorization: Basic WXYZ
  -- Example1: Authorization: Bearer ABCD.EFGH.IJKL
  local utils = require "kong.tools.utils"
  local entries = utils.split(auhtN_Header, " ")
  if #entries ~= 2 then
    kong.log.debug("Unable to get a consistent 'Authorization' header")
    return
  end

  local xDynamicHeader = "X-Dynamic-Route"
  -- If it's a Basic AuthN
  if entries[1] == 'Basic' then
   kong.service.request.set_header(xDynamicHeader, "Basic")
  -- If it's an OAuth AuthN with a Bearer
  elseif entries[1] == 'Bearer' then
    kong.service.request.set_header(xDynamicHeader, "Bearer")
  end
end

return plugin