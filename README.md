# web_function

A [Web Function](https://webfunction.org) client for Ruby.

Web Function is a way to design APIs. There are no verbs and no nested URLs. You
call an endpoint with a POST request, the path names the action, and the JSON
body carries the data. This gem lets you call those endpoints from Ruby.

```ruby
client = WebFunction::Client.from_package_endpoint("https://api.example.com/package")

client.find_user(id: "123")
# => { "id" => "123", "name" => "Ada" }
```

## Table of contents

- [Why Web Function](#why-web-function)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Clients](#clients)
- [Calling endpoints](#calling-endpoints)
- [Authentication](#authentication)
- [Versioning](#versioning)
- [Inspecting a package](#inspecting-a-package)
- [Error handling](#error-handling)
- [Pipelining](#pipelining)
- [Custom HTTP client](#custom-http-client)
- [Low-level requests](#low-level-requests)
- [Command line tool](#command-line-tool)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Why Web Function

A Web Function API has a few simple rules:

- Every call is an HTTP POST.
- The request body is a JSON object.
- The response body is any JSON value.
- A `200` status means success and the body is the return value.
- A `400` status means the request was bad and the body explains why.
- Any other status is an error you handle yourself.

On top of that, an API can publish a **package**. A package is a JSON document
that lists the endpoints, their arguments, their return types, and their docs.
This gem reads a package and gives you a client that calls those endpoints as if
they were Ruby methods.

You can read the full specification at [webfunction.org](https://webfunction.org).

## Installation

Add the gem to your project:

```bash
bundle add web_function
```

Or install it on its own:

```bash
gem install web_function
```

The gem needs Ruby 3.1 or newer.

## Quick start

Point a client at a package URL and start calling endpoints:

```ruby
require "web_function"

client = WebFunction::Client.from_package_endpoint("https://api.example.com/package")

# An endpoint named "list-items" becomes the method "list_items".
items = client.list_items(limit: 10)
# => [{ "id" => 1 }, { "id" => 2 }]

# Pass a bearer token for endpoints that need authentication.
secure = WebFunction::Client.from_package_endpoint(
  "https://api.example.com/package",
  bearer_auth: "my-token",
)

secure.create_item(name: "Notebook")
# => { "id" => 3, "name" => "Notebook" }
```

## Clients

A `WebFunction::Client` wraps a package and turns each endpoint into a method.

You usually build a client from a package URL. The gem fetches the package,
reads its endpoints, and returns a ready client:

```ruby
client = WebFunction::Client.from_package_endpoint("https://api.example.com/package")
```

If you already have a package in memory, build the client from that instead.
This avoids the extra request:

```ruby
package = WebFunction::Package.from_hash(
  "base_url" => "https://api.example.com/",
  "endpoints" => [
    { "name" => "list-items" },
    { "name" => "create-item" },
  ],
)

client = WebFunction::Client.from_package(package)
```

Both builders accept the same options:

| Option | Description |
| --- | --- |
| `bearer_auth` | A bearer token sent with every call. |
| `version` | A version string sent in the `Api-Version` header. |
| `pipelined` | When `true`, calls are batched into one request. See [Pipelining](#pipelining). |

You can also overwrite these using the `Client#bearer_auth=`, `Client#version=`
and `Client#pipeline=` attribute writers after having instantiated a client.

## Calling endpoints

Endpoint names use dashes, like `list-items`. The client exposes them as Ruby
methods with underscores, like `list_items`. You pass arguments as keywords:

```ruby
client.list_items(limit: 10, offset: 20)
```

The return value is the parsed JSON response. It can be a hash, an array, a
string, a number, a boolean, or `nil`.

```ruby
client.get_count          # => 42
client.list_items         # => [{ "id" => 1 }]
client.find_user(id: "1") # => { "id" => "1", "name" => "Ada" }
```

If you prefer to call an endpoint by its name, use `call`:

```ruby
client.call("list-items", limit: 10)
```

Calling an endpoint that the package does not define raises `NoMethodError`:

```ruby
client.does_not_exist
# => NoMethodError
```

## Authentication

Some endpoints need a bearer token. Pass it when you build the client and the
gem adds an `Authorization: Bearer <token>` header to every call:

```ruby
client = WebFunction::Client.from_package_endpoint(
  "https://api.example.com/package",
  bearer_auth: "my-token",
)

client.list_orders
```

The gem does not handle login. How you obtain the token is up to you. To find
out whether an endpoint needs a token, check its `bearer_auth?` flag:

```ruby
endpoint = client.package.endpoint("list-orders")
endpoint.bearer_auth?    # => true
endpoint.capture_bearer? # => false
```

## Versioning

A versioned package selects its version through the `Api-Version` header. Pass a
version string when you build the client:

```ruby
client = WebFunction::Client.from_package_endpoint(
  "https://api.example.com/package",
  version: "2024-01-01",
)
```

You can ask a package whether it is versioned and which versions it offers:

```ruby
package = client.package
package.versioned? # => true
package.version    # => "2024-01-01"
package.versions   # => ["2023-06-01", "2024-01-01"]
```

## Inspecting a package

A package describes itself. You can read its metadata, walk its endpoints, and
look at the arguments and outputs of each one. This is useful for building docs
or for checking a call before you make it.

```ruby
package = client.package

package.name      # => "Example API"
package.base_url  # => "https://api.example.com/"
package.docs      # => "Markdown documentation for the package."
package.endpoints # => [#<WebFunction::Endpoint ...>, ...]
```

Look up a single endpoint by name. Underscores and dashes both work:

```ruby
endpoint = package.endpoint("find-user")
# Same as:
endpoint = package.endpoint(:find_user)

endpoint.name    # => "find-user"
endpoint.docs    # => "Retrieves user data."
endpoint.returns # => ["object"]
endpoint.group   # => "Users"
```

Each endpoint lists the arguments it takes:

```ruby
endpoint.arguments
# => [#<WebFunction::Argument ...>]

id = endpoint.argument("id")
id.name      # => "id"
id.type      # => "string"
id.required? # => true
id.optional? # => false
id.choices   # => []
id.docs      # => "Identifier of the user."
```

It also lists the attributes it returns when the return type is an object:

```ruby
name = endpoint.attribute("name")
name.name      # => "name"
name.type      # => "string"
name.nullable? # => false
name.values    # => []
```

You can call an endpoint object directly once it belongs to a client:

```ruby
endpoint = client.package.endpoint("find-user")
endpoint.call(id: "123")
# => { "id" => "123", "name" => "Ada" }
```

## Error handling

Every error this gem raises inherits from `WebFunction::Error`. Each error
carries a `code` and optional `details`.

```ruby
begin
  client.find_user(id: "missing")
rescue WebFunction::Error => e
  e.code    # => "USER_NOT_FOUND"
  e.message # => "No user with that id."
  e.details # => { "id" => "missing" }
end
```

These are the error classes:

| Class | Raised when |
| --- | --- |
| `WebFunction::BadRequestError` | The server replied with status `400`. |
| `WebFunction::UnexpectedStatusCodeError` | The server replied with a status other than `200` or `400`. |
| `WebFunction::JsonParseError` | The response body was not valid JSON. |
| `WebFunction::UnresolvedPromiseError` | A pipeline promise was read before it resolved. |

When the server returns a `400`, the body is an error triple. A triple is a
JSON array with three parts: a code, a message, and details. The gem reads the
triple and fills in the error:

```json
["USER_NOT_FOUND", "No user with that id.", { "id": "missing" }]
```

```ruby
rescue WebFunction::BadRequestError => e
  e.code    # => "USER_NOT_FOUND"
  e.message # => "No user with that id."
  e.details # => { "id" => "missing" }
```

If the body is not a triple, the gem still raises `BadRequestError` with the
code `WFN_BAD_REQUEST_ERROR` and puts the raw body in `details`.

An endpoint can document the errors it may return. Read them when the endpoint
uses the `error_triple` flag:

```ruby
endpoint.errors
# => [#<WebFunction::DocumentedError code="USER_NOT_FOUND" ...>]

error = endpoint.error("USER_NOT_FOUND")
error.code # => "USER_NOT_FOUND"
error.docs # => "Returned when no user matches the id."
```

The package can document shared errors too:

```ruby
package.errors
package.error("RATE_LIMITED")
```

## Pipelining

Pipelining sends several calls in one HTTP request. The server runs them in
order and you can feed the output of one call into the next. This cuts the
number of round trips.

Build a pipelined client and each call returns a `WebFunction::Promise` instead
of a value. A promise stands in for a result that does not exist yet:

```ruby
client = WebFunction::Client.from_package_endpoint(
  "https://api.example.com/package",
  pipelined: true,
)

user  = client.find_user(id: "123")  # => a Promise
order = client.create_order(user_id: user["id"]) # uses the first result

order.resolve
# => { "id" => "order-1", "user_id" => "123" }
```

Reading `user["id"]` before the call runs does not return a value. It returns a
path into the future result. The gem sends that path to the server, and the
server fills it in when it runs the second call. Calling `resolve` runs the
whole pipeline and returns the value.

Once a pipeline runs, every promise from that batch holds its value:

```ruby
user.resolve  # runs the pipeline
order.value   # already available, no extra request
```

You can also drive a pipeline by hand with `WebFunction::Pipeline`. Each step is
a hash with a `url`, `headers`, and `body`:

```ruby
pipeline = WebFunction::Pipeline.new("https://api.example.com/run-pipeline")

pipeline.add_step(url: "https://api.example.com/a", headers: {}, body: {})
pipeline.add_step(url: "https://api.example.com/b", headers: {}, body: {})

pipeline.execute(returns: :all)
# => [{ "a" => 1 }, { "b" => 2 }]
```

The `returns` option controls what comes back:

- `:all` returns every step result as an array. This is the default.
- `:last` returns only the last step result.
- A JSONPath string returns the value at that path, for example `"$[0].id"`.

## Custom HTTP client

By default the gem makes requests with [Excon](https://github.com/excon/excon).
You can swap in any HTTP client by setting `WebFunction::Request.http_client` to
an object that responds to `call`.

The object receives the URL, the headers, and the JSON body. It must return a
two-element array of the status code and the raw response body:

```ruby
WebFunction::Request.http_client = ->(url, headers, body) do
  response = MyHttp.post(url, headers: headers, body: body)
  [response.status, response.body]
end
```

This is also handy in tests, where you can return a canned response without
making a real request:

```ruby
WebFunction::Request.http_client = ->(_url, _headers, _body) do
  [200, JSON.generate({ "id" => "123" })]
end
```

## Low-level requests

If you do not need a package, you can call a single endpoint URL directly with
`WebFunction::Request`:

```ruby
WebFunction::Request.execute(
  "https://api.example.com/find-user",
  bearer_auth: "my-token",
  version: "2024-01-01",
  args: { id: "123" },
)
# => { "id" => "123", "name" => "Ada" }
```

The request adds the standard headers, posts the JSON body, and parses the
response. It raises the same errors described in [Error handling](#error-handling).

## Command line tool

The gem ships with a `wfn` command. Use it to call an endpoint from the shell.
Arguments go in a JSON string:

```bash
wfn call https://api.example.com/find-user '{"id":"123"}'
```

Pass a bearer token with `--auth` and a version with `--version`:

```bash
wfn call --auth my-token --version 2024-01-01 \
  https://api.example.com/list-orders '{}'
```

The command prints the response as formatted JSON. On an error it prints the
code, the message, and the details, then exits with a non-zero status.

## Development

After you check out the repo, run `bin/setup` to install dependencies. Then run
`rake test` to run the tests. Run `bin/console` for a prompt where you can
experiment with the code.

To install the gem on your machine, run `bundle exec rake install`. To release a
new version, update the version in `lib/web_function/version.rb`, then run
`bundle exec rake release`. This creates a git tag, pushes the commits and the
tag, and pushes the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
[github.com/robinclart/web_function](https://github.com/robinclart/web_function).

## License

This gem is open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
