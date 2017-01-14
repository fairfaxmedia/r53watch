require "r53watch/version"

require 'net/dns'
require 'aws-sdk'
require 'thor'
require 'pp'

module R53Watch
  # Your code goes here...
  class R53Watch < Thor
    option :verbose, :type => :boolean, :default => false, :desc => 'Verbose output'
    desc 'check_delegation', 'checks delegation for all Route53-hosted zones'

    # deliberately NOT trying to make this fast... because Route53 rate limiting
    def check_delegation
      route53.list_hosted_zones.each do |response|
        response[:hosted_zones].each do |zone|
          begin
            puts "Checking #{zone.name}" if options[:verbose]
            # nameservers from route53
            ns_route53 = zone_nameservers_route53(zone.id,zone.name)
            puts "* NS from Route53 record: #{ns_route53.join(' ')}" if options[:verbose]

            # nameservers from our usual recursive resolver
            ns_dns = zone_nameservers_dns(zone.name)
            puts "* NS from DNS: #{ns_dns.join(' ')}" if options[:verbose]

            # check that all returned nameservers agree with each other
            ns_dns_status = []
            ok = ns_route53 == ns_dns
            ns_dns.each do |ns|
              delegation = zone_nameservers_dns(zone.name,ns)
              puts "* NS from DNS at #{ns}: #{ns_dns.join(' ')}" if options[:verbose]
              ok &&= (delegation == ns_dns)
              ns_dns_status << "#{ns}#{delegation == ns_dns ? "" : "(MISMATCH!)"}"
            end

            # check that delegating nameservers all agree too, if there's any point
            if ns_dns.size > 0
              delegation_ok = check_zone_delegation_consistent(zone.name, ns_dns)
            else
              delegation_ok = false
            end
            ok &&= delegation_ok

            # log output
            r53_status = "R53=#{ns_route53.join(',')}"
            dns_status = "DNS=#{ns_dns_status.join(',')}"
            delegation_status = "Delegation=#{delegation_ok ? "ok" : "MISMATCH!"}"
            puts [ (ok ? "OK   " : "FAIL "), zone.id.sub!('/hostedzone/', ''), zone.name, r53_status, dns_status, delegation_status, ].join(' ')
            # puts [ zone.id.sub!('/hostedzone/', ''), zone.name ].join(' ')
          rescue SystemExit,Interrupt
            puts "Aborted."
            exit
          rescue StandardError => e
            # DNS timeouts etc
            puts "ERROR #{zone.name} #{e.message}\n"
          end
        end
      end
    end

  private
    def route53
      @route53 ||= Aws::Route53::Client.new
    end

    def zone_nameservers_route53(id,name)
      route53.list_resource_record_sets({
        :hosted_zone_id => id,
        :start_record_type => 'NS',
        :start_record_name => name,
        :max_items => 1
      }).first[:resource_record_sets].first.resource_records.map { |x| x.value.sub(/\.$/,'') }.sort
    end

    def zone_nameservers_dns(name,ns='8.8.8.8')
      resolver = Net::DNS::Resolver.new
      resolver.nameservers = ns if ns
      dns_answer = resolver.query(name, Net::DNS::NS)
      ns_dns = dns_answer.answer.map { |ns| ns.nsdname.sub(/\.$/,'') }.sort
    end

    def zone_parent(name)
      name.split('.').drop(1).join('.')
    end

    def check_zone_delegation_consistent(name, nameservers)
      parent = zone_parent(name)
      parent_ns = zone_nameservers_dns(parent)
      agree = true
      parent_ns.each do |ns|
        delegation = zone_nameservers_dns(name,ns)
        agree &&= (delegation == nameservers)
        puts "* parent-ns[#{ns}]: #{agree ? "ok" : "MISMATCH!"}" if options[:verbose]
      end
      agree
    end
  end
end
