# README

## Requirements

- ruby
- node
- yarn

  ```shell
  npm i -g yarn
  ```

## Getting started

* Install dependencies
  ```sh
  bundle install
  yarn install
  ```

* Run missing database migrations
  ```sh
  bin/rails db:migrate
  ```

* Build tailwind for production
  ```sh
  bin/rails tailwindcss:build
  ```

* Run server
  ```sh
  bin/rails s
  ```
