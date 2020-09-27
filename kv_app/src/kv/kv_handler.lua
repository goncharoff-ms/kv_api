local log = require('log')
local json = require('json')

local kv_handler = {}

local json_header = { ['content-type'] = 'application/json; charset=utf8' }

local function error_response(req, status, msg)
    log.info("Invalid request: %s", req.body)
    log.info("Error: %s", msg)
    return {
        status = status,
        headers = json_header,
        body = json.encode({ message = msg })
    }
end

local function success_response(status, msg)
    log.info('Successfully: %s', msg)
    return {
        status = status,
        headers = json_header,
        body = json.encode({ message = msg })
    }
end

function kv_handler.save(req)
    local status, body = pcall(req.json, req)
    local key, value = body['key'], body['value']

    if (status == false)
            or (type(key) ~= 'string')
            or (type(value) ~= 'table') then
        return error_response(req, 400, 'Invalid json')
    end

    local insert_status, data = pcall(
            box.space.kv_storage.insert, box.space.kv_storage, { key, value })

    if (insert_status) then
        return success_response(201, string.format('Saved record with key [%s]', key))
    else
        return error_response(req, 409, 'This key already exists')
    end
end

function kv_handler.delete(req)
    local key = req:stash('key')

    local status, data = pcall(
            box.space.kv_storage.delete, box.space.kv_storage, key)

    if (status) and (data) then
        return success_response(200, string.format('The value with the key [%s] was deleted', key))
    elseif (data) == nil then
        return error_response(req, 404, string.format('Value with key [%s] was not found', key))
    else
        return error_response(req, 500, data.message)
    end
end

function kv_handler.update(req)
    local key = req:stash('key')
    local status, body = pcall(req.json, req)
    local val = body['value']

    if (status == false) or (type(val) ~= 'table') then
        return error_response(req, 400, 'Invalid json')
    end

    local status, data = pcall(
            box.space.kv_storage.update, box.space.kv_storage, key, { { '=', 2, val } })

    if (data == nil) then
        return error_response(req, 404, string.format('Value with key [%s] was not found', key))
    elseif (status) then
        return success_response(200, string.format('Record with key [%s] has been successfully updated', key))
    else
        return error_response(req, 500, data.message)
    end
end

function kv_handler.get(req)
    local key = req:stash('key')
    local status, data = pcall(
            box.space.kv_storage.get, box.space.kv_storage, key)

    if (status) and (data) then
        log.info('Data with key [%s] has been successfully sent', key)
        return {
            status = 200,
            headers = json_header,
            body = json.encode(data[2])
        }
    elseif (data == nil) then
        return error_response(req, 404, string.format('Value with key [%s] was not found', key))
    else
        return error_response(req, 500, data.message)
    end
end

return kv_handler