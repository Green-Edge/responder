# Responder

![CI](https://github.com/Green-Edge/responder/workflows/CI/badge.svg)

A simple RESP server which accepts requests, pattern matches the
command using regexp, and returns a corresponding response from a YAML
file.

## Install

Responder requires a recent version of Crystal (0.35.1 as of this time).

To build, follow the standard Crystal build process:

```shell
# shards install
# crystal build --release --no-debug src/responder.cr
```

This will produce a single `responder` binary that can then be moved
to somewhere in your `PATH`, for example `/usr/local/bin`.

## Usage

```shell
# responder
Usage: responder [arguments]
    -c FILE, --config=FILE           Configuration YAML file
    -h, --help                       Show this help
```

## Configuration

The YAML file format is as follows:

```yaml
host: "{your IP or localhost}"
port: {your port, for example 3001}
rules:
  - match: "{a regex}"
    wait: {int}
    response: "{response value}"
```

Rules are made up of the following values:

- `match`: a regular expression which should match the RESP
  command and arguments, in the format you would issue via
  `redis-cli`
- `wait`: an optional delay, in milliseconds, before returning
  the result
- `response`: the response value

### Responses

Responses can be defined in YAML. For example:

```yaml
rules:
  - match: "PING"
    response:
      success: true
      result: "PONG"
```

The response will be converted to a JSON string, which can then
be parsed using a JSON or YAML parser by the client.

### Regular expressions

Captures can be used in the `match` regular expression, and those
captures can be returned in the response. For example:

```yaml
rules:
  - match: "HELLO ([^\\s]+)"  # regex
    response: >-
      {"success": true, "result": "HELLO $1"}
```

Calling this with `HELLO world` will capture `world` and
return it in the place of `$1` in the response.

## Contributing

1.  Fork it (https://github.com/Green-Edge/responder/fork)
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create a new pull request

## Liability

We take no responsibility for the use of our tool, or external
instances provided by third parties. We strongly recommend you abide
by the valid official regulations in your country. Furthermore, we
refuse liability for any inappropriate or malicious use of this
tool. This tool is provided to you in the spirit of free, open
software.

You may view the LICENSE in which this software is provided to you
[here](./LICENSE).

> 8. Limitation of Liability. In no event and under no legal theory,
>    whether in tort (including negligence), contract, or otherwise,
>    unless required by applicable law (such as deliberate and grossly
>    negligent acts) or agreed to in writing, shall any Contributor be
>    liable to You for damages, including any direct, indirect, special,
>    incidental, or consequential damages of any character arising as a
>    result of this License or out of the use or inability to use the
>    Work (including but not limited to damages for loss of goodwill,
>    work stoppage, computer failure or malfunction, or any and all
>    other commercial damages or losses), even if such Contributor
>    has been advised of the possibility of such damages.
