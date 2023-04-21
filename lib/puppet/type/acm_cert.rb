require_relative '../../puppet_x/puppetlabs/property/tag.rb'
require 'puppet/property/boolean'

Puppet::Type.newtype(:acm_cert) do
  @doc = 'type representing an ACM certs'

  ensurable

  newparam(:name, namevar: true) do
    desc 'the name of the acm cert'
    validate do |value|
      fail 'Volume must have a name' if value == ''
      fail 'name should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:region) do
    desc 'the region in which to launch the volume'
    validate do |value|
      fail 'region should not contain spaces' if value =~ /\s/
      fail 'region should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:tags, :parent => PuppetX::Property::AwsTag) do
    desc 'the tags for the cert'
  end

  newproperty(:arn) do
    desc 'The certificate arn.'
    validate do |value|
      fail 'certificate should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:certificate) do
    desc 'The certificate.'
    validate do |value|
      fail 'certificate should be a String' unless value.is_a?(String)
    end
  end

  newproperty(:private_key) do
    desc 'Certificate private key'
    validate do |value|
      fail "Volume Type should be a String: #{value}" unless value.is_a?(String)
    end
  end

  newproperty(:cert_chain) do
    desc 'Certificate chain'
    validate do |value|
      fail "Volume Type should be a String: #{value}" unless value.is_a?(String)
    end
  end

end
