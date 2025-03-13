#! /bin/bash
if [ "$ENV" = "development" ]; then
    dart run /app/bin/server.dart
else 
    /app/bin/server
fi