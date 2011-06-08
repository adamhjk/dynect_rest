require 'dynect_rest'

DYNECT_CUST = ENV['DYNECT_CUST'] || 'customer'
DYNECT_USER = ENV['DYNECT_USER'] || 'user'
DYNECT_PASS = ENV['DYNECT_PASS'] || 'secretword'
DYNECT_ZONE = ENV['DYNECT_ZONE'] || 'example.com'

@dyn = DynectRest.new(DYNECT_CUST, DYNECT_USER, DYNECT_PASS, DYNECT_ZONE, true)

# Create or Update an A Record for the given host
host = "example.#{DYNECT_ZONE}"
@record = @dyn.a.fqdn(host)
if @record.get(host)
 @dyn.a.fqdn(host).ttl(300).address("10.4.5.254").save(true)
 # the true flag will use a put instead of a post.  This is required if you want to be able to update, as welll as create
else
  @dyn.a.fqdn(host).ttl(300).address("10.4.5.254").save(false)  
end

# Create a new cname record
@dyn.cname.fqdn("example-cname.#{DYNECT_ZONE}").cname("ec2-10-10-10-10.amazonaws.com").save

@dyn.publish
@dyn.logout



