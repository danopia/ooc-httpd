use httpd
import httpd/[Server, Request, Response]

HelloServer: class extends HttpServer {
  init: super func
  init: super func~withPort
  
  handleRequest: func (request: HttpRequest, response: HttpResponse) {
    response status = 200
    response body = "Hello, World!<br/><br/>This is %s<br/><br/>" format(request path)
    
    response body += "<form method=post action=submit><input type=text name=field1></input><input type=submit value=Save></input></form>"
  }
}

server := HelloServer new(8000)
server run()
