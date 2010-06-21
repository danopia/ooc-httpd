use httpd
import httpd/[Server, Request, Response]

import io/[File, FileReader]
import structs/[ArrayList, HashMap]

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
    
    target := File new(root, request path trim('/'))
    
    if (!target exists()) {
      response status = 404
      response body = "404'ed!"
      
    } else if (target isDir()) {
      response status = 200
      response body = "<h2>"
      
      parent := target
      hierarchy := ArrayList<File> new()
      while (parent path trimRight('/') != root path) {
        parent = parent parent()
        hierarchy add(0, parent)
      }
      
      i := 0
      for (parent in hierarchy ) {
        dotdots := ".."
        for (j in 1..(hierarchy size() - i)) {
          dotdots += "/.."
        }
        i += 1
        
        response body += "<a href=\"%s/\">%s</a> / " format(dotdots, parent name())
      }
      
      response body += "%s</h2><ul>" format(target name())
      
      for (child in target getChildren()) {
        if (!child isDir() || child name() startsWith('.')) continue
        response body += "<li><a href=\"%s/\">%s</a></li>" format(child name(), child name())
      }
      
      for (child in target getChildren()) {
        if (!child isFile() || child name() startsWith('.')) continue
        
        size := child size()
        scale := "B"
        
        if (size > 2*1024*1024) {
          size /= 1024*1024
          scale = "MiB"
        } else if (size > 2*1024) {
          size /= 1024
          scale = "KiB"
        }
        response body += "<li><a href=\"%s\">%s</a> (%i %s)</li>" format(child name(), child name(), size, scale)
      }
      response body += "</ul>"
      
    } else if (target isFile()) {
      response status = 200
      response reader = FileReader new(target)
      response headers["Content-Type"] = "text/plain"
      
    } else {
      response status = 500
      response body = "Huh. It's not a folder or file."
    }
  }
}

server := FileServer new(3000)
server run()
