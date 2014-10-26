# Sunalytics


[Sunalytics](https://sunalytics.co) is a tool for creating analytical charts with data from a Ruby on Rails application. It aims to empower non-developer users to freely explore their website data without any development effort.

This is the plugin gem, which accesses the data within the Rails app and provides it directly to [sunalytics.co](https://sunalytics.co)



## Supported Environments
* Rails 2.3 or later
* PostgreSQL
* MySQL



## Getting Started

1. Add the Plugin gem to your project's Gemfile.

    `gem 'sunalytics', :github => 'sunalytics/sunalytics'`

2. Set the environmental variables

  * `SUNALYTICS_USER`
  * `SUNALYTICS_PASSWORD`

  to values of your choice. Here is a Heroku example:
  <pre>heroku config:set SUNALYTICS_USER=<em>your_user</em> SUNALYTICS_PASSWORD=<em>your_pass</em></pre>

3. Create a free account at https://sunalytics.co

  Follow the configuration steps to enter your *website url*, *sunalytics_user* and *sunalytics_password*. Then check if the connection is successful and allow sunalytics to retrieve the app's database schema.


## Support

You can find more about Sunalytics [on our website](https://sunalytics.co).

Reach out to us on our support e-mail:  support @ sunalytics.co for any inquiry or request feature.


Thank you for trying this analytics tool!

Martin Tomov,
Sunalytics.co