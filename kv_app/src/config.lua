local config = {
    tarantool_port = 8888,
    http_port = 8080,
    memtx_max_tuple_size = 128 * 1024,
    memtx_memory = 100 * 1024 * 1024
}

print("<!Config!>")
print(config)

return config