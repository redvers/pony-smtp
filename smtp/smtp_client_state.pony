use "net"
use "email"

type SMTPClientState is (SMTPClientStateNoConnection |
                         SMTPClientStateConnected |
                         SMTPClientStateAcceptedEHLO |
                         SMTPClientStateSendingRcptTo |
                         SMTPClientStateReadyForMessage |
                         SMTPClientStatePendingOK |
                         None)

primitive SMTPClientStateNoConnection
primitive SMTPClientStateConnected
primitive SMTPClientStateAcceptedEHLO
primitive SMTPClientStateSendingRcptTo
primitive SMTPClientStateReadyForMessage
primitive SMTPClientStatePendingOK
