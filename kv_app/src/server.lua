local http_server = require('http.server')
local kv = require('kv.kv')

local server = {}

server.start = function(config)
    box.cfg {
        listen = config.tarantool_port,
    }

    local http_kv_server = http_server.new('0.0.0.0', config.http_port)

    kv:init(http_kv_server)

    http_kv_server:start()
end

return server;