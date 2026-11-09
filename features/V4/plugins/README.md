# Plugin features

Scenarios for V4 interactions whose contents (and, in `plugin_transport.feature`, whose transport) are handled by a
Pact plugin.

## Tags

| Tag | Meaning |
|---|---|
| `@plugin` | Needs plugin support. Runners without it skip every feature here. |
| `@plugin:<name>` | Needs that plugin installed (`matt`, `csv`, `avro`, `protobuf`). Runners can opt in one plugin at a time. |
| `@transport:<name>` | Needs a client and server for that transport in the runner's language (`matt` raw TCP, `grpc`). |

matt runs in every column and needs no fixtures, so it is the baseline: a runner that supports plugins at all should
pass the `@plugin:matt` scenarios first.

## Plugin versions

The `Given the "<name>" plugin version "<version>" is installed` step pins the version the scenario was written
against. The runner checks the plugin is in `PACT_PLUGIN_DIR` (default `~/.pact/plugins/<name>-<version>`) and fails
the scenario with a clear message if not. CI installs them with the pact CLI:

```
pact plugin install matt --version 0.1.1
pact plugin install csv --version 0.0.6
pact plugin install avro --version 0.1.3
pact plugin install protobuf --version 0.8.0
```

## Plugin configuration

Plugin configuration is given as a doc string, passed as-is to the plugin (with pact_ffi,
`pactffi_interaction_contents`). A string value of the form `fixture:<path>` is replaced by the absolute path of that
file under `fixtures/` before the configuration is passed on (avro's `pact:avro` and protobuf's `pact:proto` need a
real path).

## Provider bodies

Plugins encode their own bodies, so the provider side of each scenario returns pre-encoded bytes from
`fixtures/plugins/` with an exact content type. The suite does not need avro or protobuf codegen.

| Fixture | Contents |
|---|---|
| `user.avro` | avro `User{id: 1, username: "matt"}` |
| `user-empty-username.avro` | avro `User{id: 1, username: ""}` |
| `user-request.pb` | protobuf `compat.UserRequest{name: "bob"}` |
| `user.pb` | protobuf `compat.User{id: 1, name: "bob"}` |
| `user-empty-name.pb` | protobuf `compat.User{id: 1, name: ""}` |
| `row.csv` | `Name,100` |
| `row-bad-number.csv` | `Name,abc` |

## Known plugin behaviour the scenarios account for

- csv and avro can't be used in a synchronous message: they return no `partName`, so the request and response stay
  empty. They only appear in the HTTP and async message columns.
- csv, avro and protobuf write a parameterised content type into the pact (`text/csv;charset=utf-8`,
  `avro/binary;record=User`, `application/protobuf;message=.compat.User`). The provider must return that exact content
  type for the body to match.
- matt's TCP mock server reports "matched" when no request arrives, so the "no request" transport scenario is gRPC
  only.
- matt frames TCP messages as `MATT<body>MATT\n`. A client that leaves out the newline waits forever.
