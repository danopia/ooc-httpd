use httpd
import httpd/[Server, Request, Response]

import io/[File, FileReader]
import structs/HashMap

FileServer: class extends HttpServer {
  root: File
  
  init: func {
    super()
    root = File new(File getCwd())
  }
  init: func~withPort (port: Int) {
    super(port)
    root = File new(File getCwd())
  }
  init: func~withPath (path: File) {
    super()
    root = path
  }
  init: func~withPortAndPath (port: Int, path: File) {
    super(port)
    root = path
  }
  
  handleRequest: func (request: HttpRequest, response: HttpResponse) {
    if (request path contains("..")) {
      response status = 403
      response body = "I can't let you do that, Bob."
      return
    }
    
    target := File new(root, request path)
    
    if (!target exists()) {
      response status = 404
      response body = "404'ed!"
    } else if (target isDir()) {
      response status = 200
      response body = "<h2>%s</h2><ul><li><a href=\"..\">..</a></li>" format(target name())
      for (child in target getChildren()) {
        if (child isDir())
          response body += "<li><a href=\"%s/\">%s</a></li>" format(child name(), child name())
      }
      for (child in target getChildren()) {
        if (child isFile())
        response body += "<li><a href=\"%s\">%s</a> (%i KiB)</li>" format(child name(), child name(), child size() / 1024)
      }
      response body += "</ul>"
    } else if (target isFile()) {
      response status = 200
      response body = target read()
      response headers["Content-Type"] = "text/plain"
    } else {
      response status = 500
      response body = "Huh. It's not a folder or file."
    }
  }
}

server := FileServer new(3000)
server run()
