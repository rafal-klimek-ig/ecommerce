# How to run

## Docker

1. Get docker
2. Copy sample env vars to .env
```
cp .env.sample .env
docker compose up
```

This should prepare and seed the database and get everything up

## Linux/MacOS

Ruby is not set up to work on Windows from the get-go.

On linux/mac install ruby 3.3.0 first http://ruby-lang.org/en/documentation/installation/

Once that's done install postgres on mac (or use postgres with docker)

After both of these are done you can start installing project gems
```
cp .env.sample .env
bundle install
```

Then prepare the database
```
rake db:create
rake db:migrate
rake db:seed
```

Finally, after all of that
```
rails s
```
and you can access the project from http://localhost:3000/


## Testing
email: 'john@example.com'
password: 'password123'
