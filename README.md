#Nashville Rails Beginners Developer Directory

A directory of Nashville, TN area developers.

##Installation

Clone from github:

`git clone https://github.com/seanski/nashville-developers.git`

Create the `database.yml` and `oauth.yml` files

  * Example files can be found in the <tt>config</tt> directory
  * You must create twitter and facebook apps and obtain the API keys from there
  * App uses Postgres DB by default, see installation docs for your platform

Configure the development database

`psql`

`create role 'nashville-developers' with createdb login password 'password';`

`create database "nashville-developers_development" owner "nashville-developers";`

`\q`

Install your bundle

`bundle install`

Run the server

`rails server`
