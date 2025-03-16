## URL Shortener
### Getting started
- Install (docker)[https://docs.docker.com/compose/install/] on your system
- Clone this project from github
#### Manual setup
- Create a `.env.local` file in the project directory (there should already be a .env file in the project)
- Add a secret key to the app by adding the the following variable to your `.env.local`:
  - `CREATE_KEY=<YOUR_KEY>`
- Run `docker compose --profile build --env-file=.env --env-file=.env.local up --build` to build the images then start the containers
#### Interactive setup (Linux, Mac, WSL)
- Alternatively, if you're on a linux or mac (or WSL), you can run `sh boot.sh` to add teh key and start the containers
### View the app
- Use your favorite browser to navigate to http://localhost:4000/web
  - If your port 4000 is taken, you can change the port on line 8 of the docker-compose.yml file
### Discussion
There are many features that would be nice to have, but are being cut for sake of time. Implementing these would be ideal, but my current life responsibilities prevent me from investing as much energy as I would like into this.
- There is no framework used for the front-end. I will skip this to save time again (and space, not having to install Node which would be a dependency for almost any js framework)
- I am not going to host these images in docker.io or any other image hosting service. Building them should be pretty quick, so purchasing space to host these seems unnecessary. There may be some relics remaining in the docker-compose.yml of initial plans to host them, but unless it is requested, the images will not be pushed up
- The migrations for the mysql db are being handled by the server itself (api repository). This could be handled by a dedicated service if multiple services needed to use this db.
- Each of these services, or repositories, could live in its own git repository. But for the sake of time, and because this is a solo project, I am going to place them all in one.
- I will not be using an ORM. It would be good practice for the sake of security and readability, but it would also add time. I will try to format the SQL in the most readable format possible. The `api` repository is using `mysql_client` as its MySQL client
- I have separated out the top-level nginx proxy from the nginx proxy that handles the routes for the web service. Trying to find a nice way for them all to live together would be wonderful, but again, I do not have time. And it isn't bad, per se, to have them living separately. Just a bit unnecessary and wasteful, considering how small the web service is.