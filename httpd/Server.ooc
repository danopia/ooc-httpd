import net/[StreamSocket, ServerSocket] // for the rest
import structs/ArrayList
import httpd/[Client, FdSet, Request, Response]

solSocket: extern(SOL_SOCKET) Int
soReuseAddr: extern(SO_REUSEADDR) Int

HttpServer: class {
  listener := ServerSocket new()
  clients := ArrayList<HttpClient> new()
  
  init: func (port: Int) {
    setsockopt(listener descriptor, solSocket, soReuseAddr, 1 as Int*, Int size)
    listener bind(port)
    listener listen(5)
  }
  
  check: func {
    tv := TimeVal new(5)
    
    read_fds := FdSet new()
    read_fds add(listener descriptor)
    
    biggest := listener descriptor
    
    for (client in clients) {
      read_fds add(client socket descriptor)
      
      if (biggest < client socket descriptor)
        biggest = client socket descriptor
    }
    
    select(biggest + 1, read_fds, null as FdSet, null as FdSet, tv)
    
    if (read_fds contains?(listener descriptor)) {
      "Got a connection" println()
      socket := listener accept()
      setsockopt(socket descriptor, solSocket, soReuseAddr, 1 as Int*, Int size)
      clients add(HttpClient new(this, socket))
    }
    
    for (client in clients)
      if (read_fds contains?(client socket descriptor)) {
        client handle()
        
        if (client closed) {
          "Connection closed" println()
          clients remove(client)
        }
      }
  }
  
  handleRequest: func (request: HttpRequest, response: HttpResponse) {
    response status = 200
    response body = "Hello, World!<br/><br/>This is %s<br/><br/>" format(request path)
    
    response body += "<form method=post action=submit><input type=text name=field1></input><input type=submit value=Save></input></form>"
  }
}
