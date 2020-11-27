# Responder

![CI](https://github.com/Green-Edge/responder/workflows/CI/badge.svg)

A simple RESP server which accepts requests, pattern matches the
command using regexp, and returns a corresponding response from a YAML
file.

## Usage

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

### Regular expressions

Captures can be used in the regular expression, and those
captures can be returned in the response. For example:

```yaml
rules:
  - match: "HELLO ([^\\s]+)"  # regex
    response: >-
      {"success": true, "result": "HELLO $1"}
```

Calling this with `HELLO world` will capture `world` and
return it in the place of `$1` in the response.
