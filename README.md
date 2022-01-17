<p align="center">
  <img width="128" height="128" src="app/assets/images/logo.svg">
</p>
<h1 align="center">StudyBuddy</h1>

StudyBuddy is here to help you ace your exams. Give it a pdf copy of your lectures and it'll write up questions for you 
to practice on.

The devpost for the project can be seen [here](https://devpost.com/software/studybuddy-ogze4u).

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

* Create a credentials file to hold required keys for development
  ```sh
  EDITOR="vim" bin/rails credentials:edit --environment development
  ```

* Run server
  ```sh
  bin/rails s
  ```

## Secrets

* Retrieve your OpenAI API key [here](https://beta.openai.com/account/api-keys) and copy it to your clipboard

* Ensure the contents of the file opened by the above command include the following
  ```
  openai:
    access_token: "insert-key-here"
  ```
