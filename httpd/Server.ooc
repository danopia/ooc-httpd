import net/[StreamSocket, ServerSocket] // for the rest
import structs/ArrayList
import httpd/[Client, FdSet, Request, Response]

solSocket: extern(SOL_SOCKET) Int
soReuseAddr: extern(SO_REUSEADDR) Int

HttpServer: abstract class {
  listener := ServerSocket new()
  clients := ArrayList<HttpClient> new()
  
  init: func { init(80) }
  init: func~withPort (port: Int) {
    setsockopt(listener descriptor, solSocket, soReuseAddr, 1&, Int size)
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
      "Client connected" println()
      clients add(HttpClient new(this, listener accept()))
    }
    
    for (client in clients)
      if (read_fds contains?(client socket descriptor)) {
        client handle()
        
        if (client closed) {
          "Connection closed" println()
          clients remove(client)
          client socket close()
        }
      }
  }
  
  run: func {
    while (true) check()
  }
  
  handleRequest: abstract func (request: HttpRequest, response: HttpResponse)
}
