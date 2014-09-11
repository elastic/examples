#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe "the max function" do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    Puppet::Parser::Functions.function("max").should == "function_max"
  end

  it "should raise a ParseError if there is less than 1 arguments" do
    lambda { scope.function_max([]) }.should( raise_error(Puppet::ParseError))
  end

  it "should be able to compare strings" do
    scope.function_max(["albatross","dog","horse"]).should(eq("horse"))
  end

  it "should be able to compare numbers" do
    scope.function_max([6,8,4]).should(eq(8))
  end
end
