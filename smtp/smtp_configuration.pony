use "net"
use "email"
use "buffered"

class val SMTPConfiguration
  var mydomain: String val
  var destination: String val
  var port: String val
  var callback: {(EMail val, Reader iso): None} val

  new val create(mydomain': String val = "",
             destination': String val = "",
             port': String val = "",
             callback': {(EMail val, Reader iso): None} val = {(email: EMail val, sessionlog: Reader iso): None => None}) => None
    mydomain = mydomain'
    destination = destination'
    port = port'
    callback = callback'


