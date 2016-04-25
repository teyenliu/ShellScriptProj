#! /bin/bash
(echo "CONNECT $1:$2 HTTP/1.0"; echo; cat ) | socket 10.144.3.112 8080 | (read a; read a; cat )