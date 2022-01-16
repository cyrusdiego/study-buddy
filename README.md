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

* Run tailwind watcher
  ```sh
  bin/rails tailwindcss:watch
  ```

* Retrieve your OpenAI API key [here](https://beta.openai.com/account/api-keys) and copy it to your clipboard

* Create a credentials file to hold required keys for development
  ```sh
  EDITOR="vim" bin/rails credentials:edit --environment development
  ```

* Ensure the contents of the file opened by the above command include the following
  ```
  openai:
    access_token: "insert-key-here"
  ```

* Run server
  ```sh
  bin/rails s
  ```
