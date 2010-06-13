import net/StreamSocket
import structs/[ArrayList, HashMap]
import text/StringTokenizer

import httpd/[BufferedStreamReader, Server, Request, Response]

HttpClient: class {
  server: HttpServer
  socket: StreamSocket
  reader: BufferedStreamReader
  writer: StreamSocketWriter
  
  state: Int
  request: HttpRequest = null

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
        request = HttpRequest new()
        
        parts := line split(' ') toArrayList()
        request method = parts[0]
        request path = parts[1]
        request version = parts[2] split('/') toArrayList() first()
        
        state = 1
      
      case 1 =>
        if (line length() == 0) {
          headersOver()
        } else {
          parts := line split(": ", 2) toArrayList()
          request headers[parts[0]] = parts[1]
        }
    }
  }
  
  send: func (pkt: String) {
    writer write(pkt + "\r\n")
  }
  
  headersOver: func {
    response := server handleRequest(request)
    sendResponse(response)
    request = null
    state = 0
  }
  
  sendResponse: func (response: HttpResponse) {
    send("HTTP/%s %i %s" format(request version, response status, "OK"))
    send("Date: Sun, 13 Jun 2010 19:01:34 GMT")
    send("Server: Apache/2.2.12 (Ubuntu)")
    //send("Last-Modified: Mon, 14 Dec 2009 01:35:45 GMT")
    //send("ETag: \"4d84-b1-47aa64adc518f\"")
    send("Accept-Ranges: bytes")
    send("Content-Length: %i" format(response body length()))
    send("Vary: Accept-Encoding")
    send("Content-Type: text/html")
    send("")
    send(response body)
  }
}
