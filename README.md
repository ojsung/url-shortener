## URL Shortener
### Getting started
- Install [docker](https://docs.docker.com/compose/install/) on your system
- Clone this project from github
#### Manual setup
- Create a `.env.local` file in the project directory (there should already be a .env file in the project)
- Add a secret key to the app by adding the the following variable to your `.env.local`:
  - `CREATE_KEY=<YOUR_KEY>`
- Run `docker compose --profile build --env-file=.env --env-file=.env.local up --build` to build the images then start the containers
#### Interactive setup (Linux, Mac, WSL)
- Alternatively, if you're on a linux or mac (or WSL), you can run `sh boot.sh` to add the key and start the containers
### View the app
- Use your favorite browser to navigate to http://localhost:4002
  - If your port 4002 is taken, you can change the port in the docker-compose.yml file
- In the web app, all routes testable via cURL are available. In the web app, you can
  - Create a url that is unassociated with a user
  - Create a user
  - Log in as a user
  - After logging in, "Manage links" will be added to the header. In this page you can:
    - Create a url that is associated with a user
    - Click "Refresh" to retrieve user urls
    - Edit user urls
    - Delete user urls
### Resources
- W3 Schools for most of the regular expressions
- This was my first time writing a Dockerfile or docker-compose.yml. I used the [Getting Started](https://docs.docker.com/compose/gettingstarted/) from docker as a reference.
- The middleware pattern is based on [this thread](https://codereview.stackexchange.com/questions/274183/authentication-middleware-using-dart-shelf/274219#274219)

### Routes
- Create a shortened url
  - Create a url that is unassociated with a user
```shell
curl --location 'http://localhost:4000/api/shorten' \
--header 'Content-Type: application/json' \
--data '{
    "longUrl": "https://google.com"
}'
```
- Get and be redirected to the saved url
```shell
curl --location --request GET 'http://localhost:4000/api/r/i' \
--header 'Content-Type: application/json' \
--data '{
    "longUrl": "https://google.com"
}'
```
- Signup
```shell
curl --location 'http://localhost:4001/auth/signup' \
--header 'Content-Type: application/json' \
--data '{
    "username": "some_username",
    "password": "a password"
}'
```
- Login
```shell
curl --location 'http://localhost:4001/auth/login' \
--header 'Content-Type: application/json' \
--data '{
    "username": "some_username",
    "password": "a password"
}'
```
- Get user
  - Returns the user's username. Not very interesting
  - Note, you'll have to take the token you receive from Login and replace the {token} text with it
```shell
curl --location 'http://localhost:4000/api/user' \
--header 'Authorization: Bearer {token}'
```
- Get user urls
  - Return all urls associated with the logged in user
```shell
curl --location 'http://localhost:4000/api/user/urls' \
--header 'Authorization: Bearer {token}'
```
- Create user url
  - Create a url associated with your user
```shell
curl --location 'http://localhost:4000/api/user/urls' \
--header 'Authorization: Bearer {token}' \
--header 'Content-Type: application/json' \
--data '{
    "longUrl": "https://google.com"
}'
```
- Update user url
  - You will need the url id as well, which is returned to you when you create the url initially, or when you GET your urls
```shell
curl --location --request PUT 'http://localhost:4000/api/user/urls' \
--header 'Authorization: Bearer {token}' \
--header 'Content-Type: application/json' \
--data '{
    "urlId": {id},
    "longUrl": "https://googley.com"
}'
```
- Delete user url
  - Soft-delete a url. It will remain in the database, but with a `deleted_at` timestamp
```shell
curl --location --request DELETE 'http://localhost:4000/api/user/urls' \
--header 'Authorization: Bearer {token}' \
--header 'Content-Type: application/json' \
--data '{
    "urlId": {urlId}
}'
```
### Discussion
I thought it would be a fun challenge to try creating this app in Dart. It was very fun, but it means that, for lack of time, some features were not added. Implementing these would be ideal, but my current life responsibilities prevent me from investing as much energy as I would like into this.
- There is no framework used for the front-end. I will skip this to save time again (and space, not having to install Node which would be a dependency for almost any js framework)
- I am not going to host these images in docker.io or any other image hosting service. Building them should be pretty quick, so purchasing space to host these seems unnecessary. There may be some relics remaining in the docker-compose.yml of initial plans to host them, but unless it is requested, the images will not be pushed up
- I will not be using an ORM. It would be good practice for the sake of security and readability, but it would also add time. I will try to format the SQL in the most readable format possible. The `api` repository is using `mysql_client` as its MySQL client
- I have separated out the top-level nginx proxy from the nginx proxy that handles the routes for the web service. Trying to find a nice way for them all to live together would be wonderful, but again, I do not have time. And it isn't bad, per se, to have them living separately. Just a bit unnecessary and wasteful, considering how small the web service is.
### Unresolved issues
- It is my first time trying out Dart's testing framework. I have always used Flutter's. However, the environment variables set in the tests do not seem to be passed into the testing environment itself. Regrettably, this means all the tests I wrote will not run. I hope they look nice regardless, and you can forgive my lack of underestanding of this testing framework

