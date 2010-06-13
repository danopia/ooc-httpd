use httpd

import httpd/Server

server := HttpServer new(8000)

while (true) {
  server check()
}
