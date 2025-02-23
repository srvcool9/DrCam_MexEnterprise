import http.server
import socketserver
import sys

sys.stdout.reconfigure(encoding='utf-8')

PORT = 5000  # Change if needed

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write("✅ Python server is running without Flask!")

# Start the server
with socketserver.TCPServer(("", PORT), MyHandler) as httpd:
    print(" Server running at http://127.0.0.1:5000")
    httpd.serve_forever()
