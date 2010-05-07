# opal_bit_set_spec.rb
# Opal
#
# Created by Christian Niles on 5/4/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

framework "Foundation"
framework "Opal"

describe OpalMutableBitSet do
  
  describe "#bitAtIndex" do
    it "should return the bit at the given index" do
      mutable_data = NSMutableData.alloc.initWithCapacity(1)
      mutable_data.appendData("\x01".dataUsingEncoding(1)) # ascii
      bit_set = OpalMutableBitSet.alloc.initWithData(mutable_data)
      
      (0...8).collect { |i| bit_set.bitAtIndex(i) }.should.equal([1, 0, 0, 0, 0, 0, 0, 0])
    end
  end

  describe "#setBitAtIndex:to" do
    it "should set the bit to the specified value" do
      bit_set = OpalMutableBitSet.alloc.initWithLength(8)
      (0...8).collect { |i| bit_set.bitAtIndex(i) }.should.equal([0, 0, 0, 0, 0, 0, 0, 0])

      bit_set.setBitAtIndex(6, to:true)
      
      (0...8).collect { |i| bit_set.bitAtIndex(i) }.should.equal([0, 0, 0, 0, 0, 0, 1, 0])
    end
  end
  
  describe "#setBitsInRange:to" do
    it "should set all the bits to the specified value" do
      bit_set = OpalMutableBitSet.alloc.initWithLength(8)
      range = NSMakeRange(1, 3)
      bit_set.setBitsInRange(range, to:true)
      
      (0...8).collect { |i| bit_set.bitAtIndex(i) }.should.equal([0, 1, 1, 1, 0, 0, 0, 0])
    end
  end
  
end