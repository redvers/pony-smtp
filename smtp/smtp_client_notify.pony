use "net"
use "email"
use "debug"
use "buffered"

class SMTPClientNotify is TCPConnectionNotify
  """
  This class is the center of the SMTP client.  It contains all the logic
  that is used to manage the connection.  Currently we only allow one
  email per connection, but that is trivial to extend once we formalize
  what we want the wider API to look like.

  The current API is intended to provide maximum instrumentation until we
  have fully explored all the odd corners in the implementation.

  Fundamentally, this Notifier takes an SMTPConfiguration val (which
  contains all the relay server configuration) and an EMail iso (which,
  predictably, is an iso.

  As the SMTP transaction is performed, a log of the session and the
  session's state is logged in the EMail iso.  Once complete the EMail
  object is returned to the client so that it can be introspected for
  success or failure.
  """

  var client_state: SMTPClientState = SMTPClientStateNoConnection
  let config: SMTPConfiguration val
  let reader: Reader = Reader
  let outgoingreader: Reader = Reader
  var email: EMail iso
  var rcpttos: Array[String] = []
  var currentto: String val = ""
  var sessionlog: Reader iso = recover iso Reader end

  new create(config': SMTPConfiguration val, email': EMail iso) =>
    config = config'
    email = consume email'

    for to in email.to.keys() do
      rcpttos.push(to)
    end
    for cc in email.cc.keys() do
      rcpttos.push(cc)
    end
    for bcc in email.bcc.keys() do
      rcpttos.push(bcc)
    end

  fun ref connect_failed(conn: TCPConnection ref) =>
    var temail: EMail iso = email = recover iso EMail end
    var tsessionlog: Reader iso = sessionlog = recover iso Reader end
    config.callback(consume temail, consume tsessionlog)

  fun ref connected(conn: TCPConnection ref) =>

    debug("←→ Connection Established with " + config.destination)
  fun ref sent(conn: TCPConnection ref, data: ByteSeq): ByteSeq =>
    outgoingreader.append(data)
    try
      while true do
        debug("→ " + outgoingreader.line()?)
      end
    end
    data

  fun ref sentv(conn: TCPConnection ref, data: ByteSeqIter): ByteSeqIter => data
  fun ref received(conn: TCPConnection ref, data: Array[U8] iso, times: USize): Bool =>
    reader.append(consume data)
    match client_state
    | let x: SMTPClientStateNoConnection => recv_noconnection(conn)
    | let x: SMTPClientStateConnected => recv_connected(conn)
    | let x: SMTPClientStateAcceptedEHLO => recv_accepted_ehlo(conn)
    | let x: SMTPClientStateSendingRcptTo => recv_sending_rcpt_to(conn)
    | let x: SMTPClientStateReadyForMessage => recv_ready_for_message(conn)
    | let x: SMTPClientStatePendingOK => recv_pending_ok(conn)
    else
      try
        while true do
          let line: String val = reader.line()?
          debug("→ " + line)
        end
      else
        debug("→ reader is empty ←")
      end
    end
    true
  fun ref closed(conn: TCPConnection ref) =>
    var temail: EMail iso = email = recover iso EMail end
    var tsessionlog: Reader iso = sessionlog = recover iso Reader end
    config.callback(consume temail, consume tsessionlog)

  fun ref recv_pending_ok(conn: TCPConnection ref) =>
    try
      let line: String val = reader.line()?
      debug("← " + line)
      debug("→ None ←")
      client_state = None
      conn.write("QUIT\r\n")
    end

  fun ref recv_ready_for_message(conn: TCPConnection ref) =>
    try
      let response: String val = reader.line()?
      debug("← " + response)
      conn.write(email.render())
      conn.write(".\r\n")
      client_state = SMTPClientStatePendingOK
      debug("→ SMTPClientStatePendingOK ←")
    end



  fun ref recv_sending_rcpt_to(conn: TCPConnection ref) =>
    try
      let response: String val = reader.line()?
      debug("← " + response + " <<<<" + currentto + ">>>>")
      if (rcpttos.size() == 0) then
        client_state = SMTPClientStateReadyForMessage
        debug("→ SMTPClientStateReadyForMessage ←")

        conn.write("DATA\r\n")
        return
      end
      currentto = rcpttos.pop()?
      conn.write("RCPT TO: " + currentto + "\r\n")
    end

  fun ref recv_accepted_ehlo(conn: TCPConnection ref) =>
    try
      let response: String val = reader.line()?
      debug("← " + response + " <<<<(for Mail from)>>>>")
      debug("→ SMTPClientStateSendingRcptTo ←")

      if (rcpttos.size() > 0) then
        currentto = rcpttos.pop()?
        conn.write("RCPT TO: " + currentto + "\r\n")
        client_state = SMTPClientStateSendingRcptTo
      else
        conn.write("QUIT\r\n")
        client_state = None
      end

    end

  fun ref recv_connected(conn: TCPConnection ref) =>
    try
      while true do
        let line: String val = reader.line()?
        debug("← " + line)
        if (line.at(" ", 3)) then
          debug("→ SMTPClientStateAcceptedEHLO ←")
          conn.write("MAIL FROM: " + email.from + "\r\n")
          client_state = SMTPClientStateAcceptedEHLO
          break
        end
      end
    end



  fun ref recv_noconnection(conn: TCPConnection ref) =>
    try
      let line: String val = reader.line()?
      debug("← " + line)
    end
    conn.write("EHLO " + config.mydomain + "\r\n")
    debug("→ SMTPClientStateConnected ←")
    client_state = SMTPClientStateConnected

  fun ref debug(data: String val) =>
    sessionlog.append(data + "\n")
//    Debug.out(data)
