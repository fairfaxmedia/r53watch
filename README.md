# R53watch

Check that your zones are actually delegated to AWS Route53 correctly.

Iterates over all hosted zones in your AWS account and:

* retrieves their NS records from Route53
* retrieves NS records for the zone from public DNS
* retrieves NS records for the zone from public DNS from the parent zone's nameservers
* logs a failure if any of these don't agree

## Installation

    $ gem install r53watch

## Usage

Make sure your AWS credentials are setup, eg. via `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

Then run it, and if you have more than a few zones, save the output to a file:

    $ r53watch check_delegation > delegation.log

or for (much) greater detail:

    $ r53watch check_delegation --verbose > delegation.log

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/indigoid/r53watch.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

