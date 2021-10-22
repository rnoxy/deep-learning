# deep-learning
Docker set up for my deep-learning images `rnoxy/deep-learning`; see https://hub.docker.com/r/rnoxy/deep-learning

## Build docker image
> `docker-compose build`

## Start service
> `docker-compose start`
This will start the container that you car SSH into with command
> `ssh localhost -l dl -p 45822` (see the `ports` setup in [docker-compose.yml](docker-compose.yml))
