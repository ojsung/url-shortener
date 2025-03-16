#! /bin/sh
if ! which docker >/dev/null 2>&1; then
    echo "Docker is not installed! Please install it before trying again"
    exit 1
fi
if [ ! -f ".env.local" ]; then
    echo "Creating a .env.local file for you"
    touch .env.local
fi
if which lsof; then
    if lsof -i :4000 >/dev/null 2>&1; then
        echo "Port 4000 is already in use! Choose a different port for nginx: "
        read -r nginx_port
        echo "NGINX_EXTERNAL_PORT=$nginx_port" >>.env.local
    fi
    if lsof -i :4001 >/dev/null 2>&1; then
        echo "Port 4001 is already in use!Choose a different port for the api: "
        read -r api_port
        echo "API_EXTERNAL_PORT=$api_port" >>.env.local
    fi
    if lsof -i :4002 >/dev/null 2>&1; then
        echo "Port 4002 is already in use! Choose a different port for the web service: "
        read -r web_port
        echo "WEB_EXTERNAL_PORT=$web_port" >>.env.local
    fi
    if lsof -i :4003 >/dev/null 2>&1; then
        echo "Port 4003 is already in use! Choose a different port for mysql: "
        read -r mysql_port
        echo "MYSQL_EXTERNAL_PORT=$mysql_port" >>.env.local
    fi
fi
echo "Enter your secret key: "
read -r key

echo "$key" >>.env.local
echo "Starting your containers!"

docker compose --profile build --env-file=.env --env-file=.env.local up -d --build
