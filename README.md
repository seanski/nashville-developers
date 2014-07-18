#Nashville Developers Directory

A directory of Nashville, TN area developers.

##Installation

Clone from github:

`git clone https://github.com/seanski/nashville-developers.git`

Create the `database.yml` and `oauth.yml` files

  * Example files can be found in the <tt>config</tt> directory
  * You must create twitter and facebook apps and obtain the API keys from there
  * App uses Postgres DB by default, see installation docs for your platform

Install your bundle

`bundle install`

Configure the development database

`rake db:create`
`rake db:migrate`

Run the server

`rails server`
