require 'spec_helper'

describe CaptureTools do
  before(:all) do
    # TODO
    # load an instance of the class using a supplied yaml file
    # for the config data, you should not care about this application
  end

  it 'should initialize without' do
    true.should == true
  end

  it 'should throw an error' do
    CaptureTools::Api.new
  end
end
