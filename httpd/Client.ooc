import net/StreamSocket
import structs/ArrayList

import httpd/BufferedStreamReader
import httpd/Server

HttpClient: class {
  server: HttpServer
  socket: StreamSocket
  reader: BufferedStreamReader
  writer: StreamSocketWriter
  
  nick: String

  init: func (=server, =socket) {
    reader = BufferedStreamReader new(socket)
    writer = socket writer()
    
    send(":home.danopia.net NOTICE AUTH :*** Looking up your hostname...")
    //send(":home.danopia.net NOTICE AUTH :*** Found your hostname (pool-70-18-181-226.pskn.east.verizon.net)")
  }

  handle: func {
    while (reader hasLine?)
      handleLine(reader readUntil~Char2('\n')) // i have to slap ndd for this
  }

  handleLine: func (line: String) {
    line println()
    line = line trimRight('\n') trimRight('\r')
    parts: ArrayList<String>
    if (line contains(" :")) {
      first := line substring(0, line indexOf(" :"))
      last := line substring(first length() + 2)
      
      parts = _split(first)
      parts add(last)
    } else {
      parts = _split(line)
    }
    
    command := parts removeAt(0) toUpper()
    
    /*
    match command {
      case "NICK" =>
        nick = parts[0]
        
        send(":home.danopia.net NOTICE AUTH :Welcome to NinthBit!")
        send(":home.danopia.net 001 " + nick + " :Welcome to the NinthBit IRC Network " + nick + "!a@pool-70-18-181-226.pskn.east.verizon.net")
        send(":home.danopia.net 002 " + nick + " :Your host is home.danopia.net, running version InspIRCd-1.2")
        send(":home.danopia.net 003 " + nick + " :This server was created 17:58:07 Apr 16 2010")
        send(":home.danopia.net 004 " + nick + " home.danopia.net InspIRCd-1.2 BGHRSdhiorswx ABCDGILMNORSabcefhijklmnopqrstuvz ILabefhjkloqv")
        send(":home.danopia.net 005 " + nick + " WALLCHOPS WALLVOICES MODES=19 CHANTYPES=# PREFIX=(qaohv)~&@%+ MAP MAXCHANNELS=20 MAXBANS=60 VBANLIST NICKLEN=31 CASEMAPPING=rfc1459 STATUSMSG=@%+ CHARSET=ascii :are supported by this server")
        send(":home.danopia.net 005 " + nick + " TOPICLEN=307 KICKLEN=255 MAXTARGETS=19 AWAYLEN=200 CHANMODES=Ibe,k,Lfjl,ABCDGMNORScimnprstuz FNC NETWORK=NinthBit MAXPARA=32 ELIST=MU EXTBAN=,SMRNCjcBA EXCEPTS=e INVEX=I NAMESX :are supported by this server")
        send(":home.danopia.net 005 " + nick + " REMOVE SSL=74.207.250.111:6697 STARTTLS UHNAMES :are supported by this server")
        send(":home.danopia.net 042 " + nick + " 148AAAAHJ :your unique ID")
        send(":home.danopia.net 375 " + nick + " :home.danopia.net message of the day")
        send(":home.danopia.net 372 " + nick + " :- Motd!")
        send(":home.danopia.net 372 " + nick + " :-  ")
        send(":home.danopia.net 376 " + nick + " :End of message of the day.")
        send(":home.danopia.net 251 " + nick + " :There are 18 users and 25 invisible on 7 servers")
        send(":home.danopia.net 252 " + nick + " 17 :operator(s) online")
        send(":home.danopia.net 254 " + nick + " 21 :channels formed")
        send(":home.danopia.net 255 " + nick + " :I have 14 clients and 3 servers")
        send(":home.danopia.net 265 " + nick + " :Current Local Users: 14  Max: 17")
        send(":home.danopia.net 266 " + nick + " :Current Global Users: 43  Max: 45")
        //send(":home.danopia.net 396 " + nick + " 9b-162d8c0e.east.verizon.net :is now your displayed host")
        send(":" + nick + "!a@9b-162d8c0e.east.verizon.net MODE " + nick + " +x")

        //send(":" + nick + "!a@9b-162d8c0e.east.verizon.net JOIN #ooc-lang")
      
      case "USER" =>
      
      case "PING" =>
        send(":home.danopia.net PONG home.danopia.net " + parts[0])
      
      case "JOIN" =>
        channel := server findChannel(parts[0])
        
        if (!channel) {
          channel = Channel new(server, parts[0])
          server channels add(channel)
        }
        
        channel add(this)
      
      case "PART" =>
        channel := server findChannel(parts[0])
        if (!channel) return
        
        if (parts size == 1)
          channel remove(this)
        else
          channel remove(this, parts[1])
      
      case "PRIVMSG" =>
        channel := server findChannel(parts[0])
        if (!channel) return
        
        channel sendToAllExcept(":" + nick + "!a@9b-162d8c0e.east.verizon.net PRIVMSG " + parts[0] + " :" + parts[1], this)
    }
    */
  }
  
  _split: func(line: String) -> ArrayList<String> {
    parts := ArrayList<String> new(line count(' '))
    index := 0
    
    while (index < line length()) {
      nextSpace := line indexOf(' ', index)
      if (nextSpace < 0) nextSpace = line length()
      
      part := line[index..nextSpace]
      part println()
      parts add(part)
      
      index = nextSpace + 1
    }
    
    return parts
  }
  
  /*send: func (pkt: Packet) {
    onSend(pkt)
    writer write(pkt toString() + "\r\n")
  }*/
  
  send: func (pkt: String) {
    writer write(pkt + "\r\n")
  }
  
}
