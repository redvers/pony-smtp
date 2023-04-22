# smtp

Library to send packaged EMails via smtp

## Status

smtp is an alpha-level package.

You shouldn't be using this as it is in active development and not ready to be used, at all. Don't. Just don't use it yet.

## Quick Example

```pony
use "net"
use "smtp"
use "email"
use "buffered"
use "debug"

actor Main
  new create(env: Env) =>
    let email: EMail val = recover val EMail
      EMail
      .>from("sender@example.com")
      .>to("persona@example.com")
      .>to("personb@example.com")
      .>cc("personc@example.com")
      .>bcc("sssh@example.com")
      .>subject("This is an example EMail")
      .>html_body("<h1>Alpha Software, remember?</h1>")
    end

  let smtpconfig: SMTPConfiguration
    = SMTPConfiguration("ehlodomain.example.com",
                        "smtprelay.example.com",
                        "25",
                        {(s: Bool, e: EMail val, r: Reader iso): None =>
                          try
                            while true do
                              Debug.out("Session: " + r.line()?)
                            end
                          end
                          Debug.out("Final Status: " + s.string())
                        })
  let smtpclient: SMTPClient = SMTPClient(TCPConnectAuth(h.env.root), smtpconfig, email)
```

## Installation

* Install [corral](https://github.com/ponylang/corral)
* `corral add github.com/redvers/pony-smtp.git --version 0.0.1`
* `corral fetch` to fetch your dependencies
* `use "smtp"` to include this package
* `corral run -- ponyc` to compile your application

## API Documentation

[https://redvers.github.io/pony-smtp](https://redvers.github.io/pony-smtp)
