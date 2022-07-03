#!/bin/bash -x

apt-get update -y
apt-get install nginx -y 
service nginx status


cat <<_EOF > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<table style="width:100%">
  <tr>
    <th>Region</th>
    <th>AZ</th>
  </tr>
  <tr>
    <td>${region}</td>
    <td>${az}</td>
  </tr>
</table>
</body>
</html>
_EOF