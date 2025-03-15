# Use latest stable channel SDK.
FROM dart:3.7.1 AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

EXPOSE 5000
EXPOSE 8181

# Copy app source code (except anything in .dockerignore) and AOT compile app.
COPY . .
RUN dart compile exe bin/server.dart -o bin/server
# Build minimal serving image from AOT-compiled `/server`
# and the pre-built AOT-runtime in the `/runtime/` directory of the base image.
# FROM scratch
# COPY --from=build /runtime/ /
# COPY --from=build /bin/ /bin/
# COPY --from=build /app/bin/server /app/bin/
COPY --chown=root:root entrypoint.sh watcher.sh ./
RUN chmod +x /app/entrypoint.sh /app/watcher.sh

# CMD ["/app/bin/server"]
# CMD ["bash", "/app/entrypoint.sh"]
ENTRYPOINT [ "/app/entrypoint.sh" ]