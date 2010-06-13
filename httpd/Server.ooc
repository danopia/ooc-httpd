import net/berkeley // for select
import net/[StreamSocket, ServerSocket] // for the rest

import structs/ArrayList

import httpd/Client

solSocket: extern(SOL_SOCKET) Int
soReuseAddr: extern(SO_REUSEADDR) Int

__set: extern(FD_SET) func(fd: Int, fdset: FdSet*)
__isSet: extern(FD_ISSET) func(fd: Int, fdset: FdSet*) -> Bool
__clr: extern(FD_CLR) func(fd: Int, fdset: FdSet*)
__zero: extern(FD_ZERO) func(fdset: FdSet*)


HttpServer: class {
  listener := ServerSocket new()
  clients := ArrayList<HttpClient> new()
  
  init: func (port: Int) {
    setsockopt(listener descriptor, solSocket, soReuseAddr, 1 as Int*, Int size)
    listener bind(port)
    listener listen(5)
  }
  
  check: func {
    tv : TimeVal
    tv tv_sec = 5
    tv tv_usec = 0 // 1000 * 500
    
    //FdSet size toString() println()
    //FdSet instanceSize toString() println()
    
    
    read_fds: FdSet
    //__zero(read_fds&)
    //__set(3, read_fds)
    
    __zero(read_fds&)
    __set(listener descriptor, read_fds&)
    
    //  "1 %p" format(read_fds) println()
    //read_fds clear()
    //read_fds contains?(listener descriptor) toString() println()
    //read_fds add(listener descriptor)
    //read_fds contains?(listener descriptor) toString() println()
    
    biggest := listener descriptor
    
    for (client in clients) {
      __set(client socket descriptor, read_fds&)
      //read_fds add(client socket descriptor)
      
      if (biggest < client socket descriptor)
        biggest = client socket descriptor
    }
    
    select(biggest + 1, read_fds&, null as FdSet*, null as FdSet*, tv&)
    
    //if (read_fds contains?(listener descriptor))
    if (__isSet(listener descriptor, read_fds&))
      clients add(HttpClient new(this, listener accept()))
    
    for (client in clients)
      if (__isSet(client socket descriptor, read_fds&))
      //if (read_fds contains?(client socket descriptor))
        client handle()
  }
}