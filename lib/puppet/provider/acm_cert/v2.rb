require_relative '../../../puppet_x/puppetlabs/aws'

Puppet::Type.type(:acm_cert).provide(:v2, :parent => PuppetX::Puppetlabs::Aws) do
  confine feature: :aws

  mk_resource_methods

  def self.instances
    regions.collect do |region|
      acm = acm_client(region)
      begin
        certs = []
        cer_response = acm.list_certificates()
        cer_response.certificate_summary_list.collect do |cert|
          hash = cert_to_hash(region, cert)
          certs << new(hash) if has_name?(hash)
        end
        certs
      rescue Timeout::Error, StandardError => e
        raise PuppetX::Puppetlabs::FetchingAWSDataError.new(region, self.resource_type.name.to_s, e.message)
      end
    end.flatten
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name] # rubocop:disable Lint/AssignmentInCondition
        resource.provider = prov if resource[:region] == prov.region
      end
    end
  end

  def self.cert_to_hash(region, cert)
    config = {
      name: cert.domain_name,
      ensure: :present,
      arn: cert.certificate_arn,
      region: region,
    }
    config
  end

  def exists?
    Puppet.info("Checking if ACM certificate #{name} exists in region #{target_region}")
    @property_hash[:ensure] == :present
  end

  def acm
    acm = acm_client(target_region)
    acm
  end

  def create
    Puppet.info("Creating Certificate #{name} in region #{target_region}")
    cert_file = File.open(resource[:certificate]).read()
    key_file = File.open(resource[:private_key]).read()
    chain_file = File.open(resource[:cert_chain]).read()
    
    config = {
      certificate: cert_file,
      private_key: key_file,
      certificate_chain: chain_file,
    }

    response = acm.import_certificate(config)

    @property_hash[:arn] = response.certificate_arn
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.info("Deleting Certificate #{name} in region #{target_region}")
    # Detach if in use first
    config = {
      certificate_arn: arn,
    }
    acm.delete_certificate(config)
    @property_hash[:ensure] = :absent
  end
end
