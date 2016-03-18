# Description:
#   Interact with fabric8
#
# Dependencies:
#   None
#
# Configuration:
#   KUBERNETES_MASTER

# Commands:
#   fabric8 get pods - lists the running pods

# URLS:
#   POST /hubot/notify/<room> (message=<message>)
#
# Author:
#   fabric8.io

fabric8GetPods = (msg) ->
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
    host = process.env.KUBERNETES_SERVICE_HOST
    port = process.env.KUBERNETES_SERVICE_PORT
    path = "https://#{host}:#{port}/api/v1/namespaces/default/pods"

    req = msg.http(path)

    req.header('Content-Length', 0)
    req.get() (err, res, body) ->
        if err
          msg.reply "fabric8 says: #{err}"
        else if 200 <= res.statusCode < 400 # Or, not an error code.
          results = []
          data = JSON.parse(body)
          for items in data.items
            results.push (items.id + "\n")

          msg.reply "Pods: #{results}"

        else
          msg.reply "fabric8 says: #{res.statusCode} #{body}"

module.exports = (robot) ->

  fs = require 'fs'

  robot.router.post '/hubot/notify/:room', (req, res) ->
    room = req.params.room
    message = req.body.message
    robot.messageRoom room, message
    res.end()

  robot.respond /get pods/i, (msg) ->
    fabric8GetPods msg, msg.match[1]
