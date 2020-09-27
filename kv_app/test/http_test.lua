local api_test_tap = require('tap').test('api_test')
local server = require('server')
local json = require('json')
local httpc = require("http.client")

local test_http_port = 9999
local test_tarantool_port = 9998

server.start({
    tarantool_port = test_tarantool_port,
    http_port = test_http_port,
})

local url = 'http://0.0.0.0:' .. test_http_port .. '/kv'


-- Create KV

local test_methods = {}

function test_methods.success_create_kv_record()
    local data = { key = 'create_key', value = { a = 'b' } }
    api_test_tap:is(httpc.post(url, json.encode(data)).status, 201, 'Successful creation of KV recording')
end

function test_methods.error_create_kv_key_is_missing()
    local data = { key = nil, value = { a = 'b' } }
    api_test_tap:is(httpc.post(url, json.encode(data)).status, 400, 'Error, key is missing (create)')
end

function test_methods.error_create_kv_value_is_missing()
    local data = { key = 'key_v_mis' }
    api_test_tap:is(httpc.post(url, json.encode(data)).status, 400, 'Error, value is missing (create)')
end

function test_methods.error_create_kv_value_is_duplicate()
    local data = { key = 'duplicate_key', value = { a = 'b' } }

    httpc.post(url, json.encode(data))

    api_test_tap:is(httpc.post(url, json.encode(data)).status, 409, 'Error, key is exists (create)')
end

-- Get KV

function test_methods.success_get_kv()
    httpc.post(url, json.encode({ key = 'get_key', value = { a = 'b' } }))

    local data = { key = 'get_key', value = { a = 'b' } }
    httpc.post(url, json.encode(data))
    local response = httpc.get(url .. '/' .. data.key)
    api_test_tap:is(response.status, 200, "Successful get of KV recording (status)")
    api_test_tap:is(response.body, json.encode(data.value), "Successful get of KV recording (body)")
end

function test_methods.error_get_kv_key_is_missing()
    local response = httpc.get(url .. '/' .. 'no_key')
    api_test_tap:is(response.status, 404, "Error, key is missing (get)")
end

-- Update KV

function test_methods.success_update_kv()
    local key = 'key_update'
    local data = { key = key, value = { a = 'b' } }
    httpc.post(url, json.encode(data))

    local response = httpc.put(url .. '/' .. key, json.encode({ value = { a = 'c' } }))
    api_test_tap:is(response.status, 200, "Successful update of KV recording (update)")

    local response = httpc.get(url .. '/' .. key)
    api_test_tap:is(response.body, json.encode({ a = 'c' }), "Successful update of KV recording (get)")
end

function test_methods.error_update_key_is_missing()
    api_test_tap:is(httpc.put(url .. '/' .. 'no_key', json.encode({ value = { a = 'c' } }))
                         .status, 404,
            'Error, key is missing (update)')
end

-- Delete KV
function test_methods.success_delete_kv()
    local key = 'key_delete'
    httpc.post(url, json.encode({ key = key, value = { a = 'b' } }))

    api_test_tap:is(httpc.delete(url .. '/' .. key).status, 200, "Successful delete of KV recording")
end

function test_methods.error_delete_kv_key_is_missing()
    api_test_tap:is(httpc.delete(url .. '/' .. 'no_key').status, 404, "Error, key is missing (delete)")
end

for k, v in pairs(test_methods) do
    print('Execute: ' .. k)
    v()
end

api_test_tap:plan(12)
api_test_tap:check()

os.exit()










