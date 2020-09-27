local kv_handler = require('kv.kv_handler')
local log = require('log')

local path = '/kv'

local kv_router = {}

function kv_router:init(server)
    log.info("Http router is initialize")
    server:route({ path = path .. '/:key', method = 'GET' }, kv_handler.get)
    server:route({ path = path, method = 'POST' }, kv_handler.save)
    server:route({ path = path .. '/:key', method = 'PUT' }, kv_handler.update)
    server:route({ path = path .. '/:key', method = 'DELETE' }, kv_handler.delete)
end

return kv_router;
