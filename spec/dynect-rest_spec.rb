require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe DynectRest do
  let(:d) do
    DynectRest.new("customer", "username", "password", "zone", false)
  end

  describe "a" do
    subject { d.a }
    its(:resource_path) { should == 'ARecord/zone' }
  end

  describe "aaaa" do
    subject { d.aaaa }
    its(:resource_path) { should == 'AAAARecord/zone' }
  end

  describe "cname" do
    subject { d.cname }
    its(:resource_path) { should == 'CNAMERecord/zone' }
  end

  describe "dnskey" do
    subject { d.dnskey }
    its(:resource_path) { should == 'DNSKEYRecord/zone' }
  end

  describe "ds" do
    subject { d.ds }
    its(:resource_path) { should == 'DSRecord/zone' }
  end

  describe "key" do
    subject { d.key }
    its(:resource_path) { should == 'KEYRecord/zone' }
  end

  describe "loc" do
    subject { d.loc }
    its(:resource_path) { should == 'LOCRecord/zone' }
  end

  describe "mx" do
    subject { d.mx }
    its(:resource_path) { should == 'MXRecord/zone' }
  end

  describe "ns" do
    subject { d.ns }
    its(:resource_path) { should == 'NSRecord/zone' }
  end

  describe "ptr" do
    subject { d.ptr }
    its(:resource_path) { should == 'PTRRecord/zone' }
  end

  describe "rp" do
    subject { d.rp }
    its(:resource_path) { should == 'RPRecord/zone' }
  end

  describe "soa" do
    subject { d.soa }
    its(:resource_path) { should == 'SOARecord/zone' }
  end

  describe "srv" do
    subject { d.srv }
    its(:resource_path) { should == 'SRVRecord/zone' }
  end

  describe "txt" do
    subject { d.txt }
    its(:resource_path) { should == 'TXTRecord/zone' }
  end

  describe "node_list" do
    subject { d.node_list }
    its(:resource_path) { should == 'NodeList/zone' }
  end

  describe "node" do
    subject { d.node }
    its(:resource_path) { should == 'Node/zone' }
  end
end
