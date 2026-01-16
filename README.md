# SupraBank

A repository for intermolecular interactions - <http://suprabank.org>

![CircleCI](https://img.shields.io/circleci/build/github/StephanSinn/suprabank/development?style=plastic&token=44909844ea4a61e219a0eb274cd4c822c444fc2d)

![Codacy Badge](https://img.shields.io/codacy/grade/f22e9157f6f44b308aef8476e2ae4088?style=plastic)

Offical Docker Image: <https://hub.docker.com/r/stephansinn/suprabank.org>

---

## Local Development

### Prerequisites
-  Docker CE (community edition): <https://docs.docker.com/install/>
-  Docker Compose <https://docs.docker.com/compose/install/>

### Get Started

You might need sudo rights.
#### Starting

Clone the repository from the development branch

```
git clone https://github.com/StephanSinn/suprabank.git
```

```
cp ./.env.example ./.env
```
 No local postgresql server should be running
```
service postgresql stop
```
It might be necessary to increase the HTTP timeout
```
export COMPOSE_HTTP_TIMEOUT=240
```
Start the container
```
docker-compose up -d
```
If there are problems with gems, first stop the container with
```
docker-compose down
```

and then uncomment the following two lines in docker_entrypoint.sh
```
bundle update
bundle install --path vendor/bundle
```
and start the container again
```
docker-compose up -d
```

#### Accessing the Container
```
docker-compose exec web bash
```

#### Running Tests
```
docker-compose exec web bash
```
In the docker bash:

```
rake test
```
If this fails, try:
```
bundle exec rake test
```

#### Shutting Down
```
docker-compose down
```
If this fails, call first
```
sudo aa-remove-unknown
```
and then try again.

### Build Docker Image
build the docker image locally using the following command:
```
docker build -t stephansinn/suprabank.org .
```

to launch the local development environment run
```
docker-compose up -d
```

### Working

The database will be empty, does you need some data to work with.

```
docker-compose exec web bash
```
In the docker bash:

```
rake db:seed
rake interactor:runall
```
If this fails, try:

```
bundle exec rake db:seed
bundle exec rake interactor:runall
```

These two comments will feed the Technique and AssayType arrays as well as generate some Users, Molecules and Interactions to work with. All defined in lib/tasks/interactor.rake
If you want to have an user with admin rights, you need to change the role of one of the users:
Open the rails console in the docker bash:
```
rails c
```
and then e.g.:
```
user = User.find_by(email:"user1@gmail.com")
user.admin!
```

### Interactive Debugging
We use the byebug gem for debugging, it is already available in test and development environment. docker-compose up does not support interactive debugging. <https://github.com/docker/compose/issues/4677>

stop the running containers and start two instances via run to have the server
```
docker-compose down
docker-compose run --service-ports web
```
 and the bash.
```
docker-compose run web bash
```
### Learn More
Tutorial we followed to create the series of commands / steps listed below:
<https://thoughtbot.com/blog/rails-on-docker>

---

## Branching

We follow the "Github Flow" branching strategy. If you want to learn more: <https://guides.github.com/introduction/flow/>

1.  checkout  ```development```
2.  create feature branch
3.  commit
4.  push
5.  open pull request to  ```development```
