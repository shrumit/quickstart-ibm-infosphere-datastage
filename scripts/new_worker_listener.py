#!/usr/bin/python

# New Worker Listener Server: API server for registering a new worker to the cluster

from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer
import cgi
import json
import subprocess
import sys
import time

PORT_NUMBER = 8080
CWD = '/disk1/quickstart/installer/DS-Kube-Installer'

# example use:
# curl -d "ip=$IP&hostname=$HN&label=$LABEL" -X POST $ip:8080/addWorker

class myHandler(BaseHTTPRequestHandler):

    #Handler for the GET requests
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type','text/html')
        self.end_headers()
        # Send the html message
        self.wfile.write('Hello World !')
        return

    def do_POST(self):
        if self.path=='/addWorker':
            form = cgi.FieldStorage(
                fp=self.rfile,
                headers=self.headers,
                environ={'REQUEST_METHOD':'POST'}
            )
            print 'ip:%s, hostname:%s, label:%s' % (form['ip'].value, form['hostname'].value, form['label'].value)
            sys.stdout.flush()
            if form['label'].value == 'is-engine':
                time.sleep(400)
            in_file = open('/disk1/quickstart/nodes.json', 'r')
            out_file = open('/disk1/quickstart/installer/DS-Kube-Installer/nodes.json', 'w')
            data = json.loads(in_file.read())
            data['workerNodeHost'][0]['name'] = form['hostname'].value
            data['workerNodeHost'][0]['label'] = form['label'].value
            out_file.write(json.dumps(data))
            out_file.close()
            subprocess.Popen(['/disk1/quickstart/installer/DS-Kube-Installer/addNodes.sh', CWD], cwd=CWD)
            # subprocess.call(['/disk1/quickstart/installer/DS-Kube-Installer/deleteDeadNodes.sh', CWD], cwd=CWD)
            self.send_response(200)
            self.end_headers()
            self.wfile.write('Receipt success')
            return

try:
    server = HTTPServer(('', PORT_NUMBER), myHandler)
    print 'Started new_worker_listener server on port ' , PORT_NUMBER
    server.serve_forever()

except KeyboardInterrupt:
    print '^C received, killing new_worker_listener server'
    server.socket.close()
