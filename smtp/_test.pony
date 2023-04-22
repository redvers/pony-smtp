use "net"
use "email"
use "debug"
use "buffered"
use "pony_test"

actor \nodoc\ Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_EMailGeneration)

class \nodoc\ iso _EMailGeneration is UnitTest
  fun name(): String => "HTML Email"

  fun apply(h: TestHelper) =>
    let email: EMail val = recover val EMail
      EMail
      .>to("red@evil.red")
      .>from("red@evil.red")
      .>subject("This is a text HTML Email")
      .>html_body("<h1>Hello World</h1>")
    end

    let smtpconfig: SMTPConfiguration = SMTPConfiguration("evil.red", "evil.red", "25",
        {(s: Bool, e: EMail val, r: Reader iso): None =>
          try
            while true do
              Debug.out("READER: " + r.line()?)
            end
          end
          Debug.out("Final Status: " + s.string())
        })

    let smtp: SMTPClient = SMTPClient(TCPConnectAuth(h.env.root), smtpconfig, email)

    h.env.out.print(email.render())


