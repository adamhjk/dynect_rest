require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe DynectRest do

  let(:dynect) do
    DynectRest.new("customer", "username", "password", "zone", false)
  end

  it "A Record" do
    expect(dynect.a.resource_path).to eq('ARecord/zone')
  end

  it "AAAA Record" do
    expect(dynect.aaaa.resource_path).to eq('AAAARecord/zone')
  end

  it "CNAME Record" do
    expect(dynect.cname.resource_path).to eq('CNAMERecord/zone')
  end

  it "DNSKEY Record" do
    expect(dynect.dnskey.resource_path).to eq('DNSKEYRecord/zone')
  end

  it "DS Record" do
    expect(dynect.ds.resource_path).to eq('DSRecord/zone')
  end

  describe "gslb" do
    subject { dynect.gslb }
    its(:resource_path) { should == 'GSLB/zone' }
  end

  describe "key" do
    subject { dynect.key }
    its(:resource_path) { should == 'KEYRecord/zone' }
  end

  it "KEY Record" do
    expect(dynect.key.resource_path).to eq('KEYRecord/zone')
  end

  it "LOC Record" do
    expect(dynect.loc.resource_path).to eq('LOCRecord/zone')
  end

  it "MX Record" do
    expect(dynect.mx.resource_path).to eq('MXRecord/zone')
  end

  it "NS Record" do
    expect(dynect.ns.resource_path).to eq('NSRecord/zone')
  end

  it "PTR Record" do
    expect(dynect.ptr.resource_path).to eq('PTRRecord/zone')
  end

  it "RPR Record" do
    expect(dynect.rp.resource_path).to eq('RPRecord/zone')
  end

  it "SOA Record" do
    expect(dynect.soa.resource_path).to eq('SOARecord/zone')
  end

  it "SRV Record" do
    expect(dynect.srv.resource_path).to eq('SRVRecord/zone')
  end

  it "TXT Record" do
    expect(dynect.txt.resource_path).to eq('TXTRecord/zone')
  end
end
