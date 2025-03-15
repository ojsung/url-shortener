#! /bin/bash
if [ "$ENV" = "development" ]; then
    # apt-get update && apt-get install -y inotify-tools
    # bash /app/watcher.sh "dart run /app/bin/server.dart"
    dart run /app/bin/server.dart
else 
    /app/bin/server
fi