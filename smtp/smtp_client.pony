use "net"
use "email"

actor SMTPClient
  var auth: TCPConnectAuth
  let config: SMTPConfiguration val

  new create(auth': TCPConnectAuth, config': SMTPConfiguration val, email: EMail iso) =>
    auth = auth'
    config = config'

    TCPConnection(auth, recover SMTPClientNotify(config, consume email) end, config.destination, config.port)

