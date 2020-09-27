local kv_router = require('kv.kv_router')
local log = require('log')

local kv = {}

function kv:init(server)
    log.info("KV-module is initialize")
    box.once('init', function()
        box.schema.create_space('kv_storage', { if_not_exists = true, format })
        box.space.kv_storage:create_index('primary', { type = 'hash'; parts = { 1, 'string' }; if_not_exists = true; })
    end)
    kv_router:init(server)
end

return kv;