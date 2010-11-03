require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe DynectRest do
  let(:d) do
    DynectRest.new("customer", "username", "password", "zone", false)
  end

  describe "a" do
    subject { d.a }
    its(:resource_path) { should == 'ARecord/zone' }
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
