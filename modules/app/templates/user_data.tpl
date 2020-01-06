#!/bin/bash -ex

apt-get update && \
sudo apt-get -y install ruby-mongo ruby-sinatra && \
echo "Mongo Address: ${mongo_address}"

cat > /home/ubuntu/app.rb <<EOF
require "mongo"
require "sinatra"

set :port, 8080
set :bind, '0.0.0.0'

configure do
  client = Mongo::Connection.new "${mongo_address}"
  db = client['example_data']
  set :mongo_db, db['restaurants']
end

get "/test.htm" do
<<-PAGE
  <html>
    <head>
      <title>Nice Job!</title>
    </head>
    <body>
      <h1>
        It Works!
      </h1>
      You are able to access this app over a standard HTTP connection.  Now try the database query <a href="/query.json">endpoint</a>
    </body>
  </html>
PAGE
end

get "/query.json" do
  "{record_count: #{settings.mongo_db.count}}"
end

EOF

nohup ruby /home/ubuntu/app.rb &

exit 0
