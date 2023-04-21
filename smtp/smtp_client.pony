use "net"
use "email"

actor SMTPClient
  var auth: TCPConnectAuth
  let config: SMTPConfiguration val

  new create(auth': TCPConnectAuth, config': SMTPConfiguration val, email: EMail val) =>
    auth = auth'
    config = config'

    TCPConnection(auth, recover SMTPClientNotify(config, email) end, config.destination, config.port)

