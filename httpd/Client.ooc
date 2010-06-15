import net/StreamSocket
import structs/[ArrayList, HashMap]
import text/StringTokenizer
import io/[Reader, Writer]

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
    if (reader available == 0) reader readMore(1) // to see if the socket died
    
    while (reader hasLine?)
      handleLine(reader readUntil~Char2('\n')) // i have to slap ndd for this
  }

  handleLine: func (line: String) {
    line = line trimRight('\n') trimRight('\r')
    
    if (request) { // headers
      if (line length() != 0) { // header line
        parts := line split(": ", 1) toArrayList()
        request headers[parts[0]] = parts[1]
      } else if (request headers["Content-Length"]) { // has body
        length := request headers["Content-Length"] toInt()
        request body = reader read(length)
        requestComplete()
      } else { // bodyless
        requestComplete()
      }
    
    } else { // initial line
      line println()
      
      request = HttpRequest new()
      
      parts := line split(' ') toArrayList()
      request method = parts[0]
      request path = parts[1]
      request version = (parts[2] split('/') toArrayList())[1]
    }
  }
  
  send: func (pkt: String) {
    writer write(pkt + "\r\n")
  }
  
  closed: Bool { get { reader closed } }
  
  requestComplete: func {
    response := HttpResponse new(request)
    
    //response headers["Date"] = "Sun, 13 Jun 2010 19:01:34 GMT"
    response headers["Server"] = "ooc-httpd/0.0.1"
    response headers["Content-Type"] = "text/html"
    //response headers["Connection"] = "close"
    
    server handleRequest(request, response)
    sendResponse(response)
    
    // close until we have chunked
    //socket close()
    //server clients remove(this)
    
    request = null
    state = 0
  }
  
  sendResponse: func (response: HttpResponse) {
    if (response body)
      response headers["Content-Length"] = response body length() toString()
    else
      response headers["Transfer-Encoding"] = "chunked"
    
    send("HTTP/%s %i %s" format(request version, response status, "OK"))
    for (name in response headers getKeys()) {
      send("%s: %s" format(name, response headers get(name)))
    }
    send("")
    
    if (response body)
      writer write(response body)
    else {
      buffer := String new(1024)
      
      while (response reader hasNext()) {
        size := response reader read(buffer, 0, 1024)
        writer write(size toHexString() + "\r\n")
        writer write(buffer, size)
        writer write("\r\n")
      }
      
      // termination chunk
      writer write("0\r\n\r\n")
    }
  }
}
