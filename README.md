## Tarantool HTTP-KV
The application presents a key-value store running over http and is deployed on port: `8080`. Tests are also run during startup. They work in a separate service.
### Launch
```sh
$ docker-compose up
```

### API
Path | Method | Body | Description
--- | --- | --- | --- 
/kv/:key | GET |  | Get value by key
/kv | POST | ```{"key": "[string]", "value": {[any_object]}} ``` | Adds a value by key to the database
/kv/:key | PUT | ```{ "value": {[any_object]}} ``` | Updates a value by key in the database
/kv/:key | DELETE | | Deletes a value by key in the database

