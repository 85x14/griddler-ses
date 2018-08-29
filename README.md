# Griddler::AmazonSES

This is a [Griddler](https://github.com/thoughtbot/griddler) adapter that allows you to parse email replies when used with Amazon SES.


## Installation

Add these lines to your application's Gemfile:

```ruby
gem 'griddler'
gem 'griddler-amazon_ses'
```

And then execute:

    $ bundle


## Usage

1. Setup Amazon SES to receive emails -- see http://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-setting-up.html

2. From AWS SES -> Rule Sets, choose to "Create Receipt Rule" and choose to use SNS.  Add an action with a new SNS topic that *ends in `_griddler`*, with a Base64 encoding.

3. Go to AWS SNS (Simple Notification Service) -> Topics.  Click on your `_griddler` topic.  Add a subscription that points to your configured griddler endpoint (the default route is `/email_processor`).  You're server must be already running to confirm the subscription request!

4. In your griddler handler, be sure to handle/ignore empty reply emails (ie. check for `email.headers.empty?`) to account for the fact that some hooks are just SNS's subscription handling.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ccallebs/griddler-amazon_ses.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

