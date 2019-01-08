# BottledServices

![](https://ruby-gem-downloads-badge.herokuapp.com/bottled_services?type=total)

## The best thing to happen since bottled water

Ok, thats a drastic exaggeration, but now I have your attention lets get down to it.  
bottled_services are here to make your life easier, its that simple. Using services keeps our code cleaner, DRYer, and reusable. With this gem creating and using services is now as easy and pain-free as can be thanks to the bottled_services generator and the BottledService Class from which all bottled services are children of, all you need to worry about is adding your business logic, let bottled_services handle the rest.

## Notice:
This Readme explains the use of BottledServices up to version 0.1.3, currently 1.0.0.alpha is the latest version and contains breaking changes, the Readme will be updated along with the release of 1.0.0 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bottled_services'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bottled_services

## Usage

Service Objects can be generated using the bottled_service generator:

    $ rails g bottled_service ExampleService first_attribute:String second_attribute:Array

This will then create a service object that can accept two type-strict attributes, this service can then be called and executed by calling the class call method:

```ruby
ExampleService.call(first_attribute: 'This is a string.', second_attribute: ['This', 'is', 'an', 'Array'])
```
or :
```ruby
ExampleService.call(some_valid_params)
```

Bottled Services provide the ability to create strict-type attributes, however this is not a definite, and in the case of wanting to use type agnostic attributes, just leave out the type from the command:

    $ rails g bottled_service TypeAgnosticService first_attribute second_attribute

When using the generator with types, the attribute arguments will generate something like the following in your service object:
```ruby
att :first_attribute, String
att :second_attribute, Array
```

This tells the bottled service which attributes are acceptable, and the type for it. So when not using the generator, or when adding attributes later on, just add another line as you like to declare it.
And to allow any type, just leave out the type:

```ruby
att :third_attribute
```

Afterwards just add the logic to your new service's call method, and its ready to go:

```ruby
def call
  puts "My first attribute: #{@first_attribute}"
end
```

Bonus!

When you generate the service you will notice in the auto-generated call method there is a yield statement:

```ruby
def call
  # Do something...
  yield if block_given?
end
```

Bottled Services can accept blocks for those rare times when you want to run the service logic, but need a little something extra that you don't want to have to put in your controller logic, or have to write another service for, just pass the block in when initiating with the class call method, and it will be available to yield from your service instances call method:

```ruby
ExampleService.call(some_valid_params){|first_att, second_att| puts "All the atts! #{first_att}, #{second_att}" }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/John-Hayes-Reed/bottled_services. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
