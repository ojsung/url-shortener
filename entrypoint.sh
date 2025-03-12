#! /bin/sh
if [ -f ".env" ]; then
    . ./.env
fi

if [ -f ".env.local" ]; then
    . ./.env.local
fi

if [ $(which docker) ]; then
    docker-compose up -d web
else
    echo "Docker is not installed"
fi
