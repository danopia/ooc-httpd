import net/StreamSocket
import structs/[ArrayList, HashMap]
import text/StringTokenizer

import httpd/[BufferedStreamReader, Server]

HttpClient: class {
  server: HttpServer
  socket: StreamSocket
  reader: BufferedStreamReader
  writer: StreamSocketWriter
  
  state: Int
  method, path, version: String
  headers: HashMap<String, String>
  body: String

  init: func (=server, =socket) {
    reader = BufferedStreamReader new(socket)
    writer = socket writer()
    
    state = 0
  }

  handle: func {
    while (reader hasLine?)
      handleLine(reader readUntil~Char2('\n')) // i have to slap ndd for this
  }

  handleLine: func (line: String) {
    line println()
    line = line trimRight('\n') trimRight('\r')
    
    match state {
      case 0 =>
        parts := line split(' ') toArrayList()
        
        method = parts[0]
        path = parts[1]
        version = parts[2] split('/') toArrayList() first()
        
        headers = HashMap<String, String> new()
        
        state = 1
      
      case 1 =>
        if (line length() == 0) {
          state = 0
          headersOver()
          return
        }
        
        parts := line split(": ", 2) toArrayList()
        headers[parts[0]] = parts[1]
    }
  }
  
  send: func (pkt: String) {
    writer write(pkt + "\r\n")
  }
  
  headersOver: func {
    send("HTTP/1.1 200 OK")
    send("Date: Sun, 13 Jun 2010 19:01:34 GMT")
    send("Server: Apache/2.2.12 (Ubuntu)")
    //send("Last-Modified: Mon, 14 Dec 2009 01:35:45 GMT")
    //send("ETag: \"4d84-b1-47aa64adc518f\"")
    send("Accept-Ranges: bytes")
    send("Content-Length: 3")
    send("Vary: Accept-Encoding")
    send("Content-Type: text/html")
    send("")
    send("Hi!")
  }
}
