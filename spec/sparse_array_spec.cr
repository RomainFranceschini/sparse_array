require "./spec_helper"

describe SparseArray do
  describe "[]" do
    it "returns the value corresponding to the given key" do
      a = SparseArray{1 => 2, 3 => 4, 5 => 6, 7 => 8}
      a[1].should eq(2)
      a[3].should eq(4)
      a[5].should eq(6)
      a[7].should eq(8)

      a = SparseArray{1 => :two, 3 => :four, 5 => :six}
      a[3].should eq(:four)
    end

    it "raises on a missing key" do
      a = SparseArray{1 => :two, 2 => :four}
      expect_raises KeyError do
        a[5]
      end
    end
  end

  describe "[]?" do
    it "returns nil if the key is missing" do
      a = SparseArray{1 => "one", 2 => "two"}
      a[3]?.should eq(nil)
      a[5]?.should eq(nil)
    end
  end

  describe "fetch" do
    it "returns the value corresponding to the given key, yields otherwise" do
      a = SparseArray{1 => 2, 3 => 4, 5 => 6, 7 => 8}
      a.fetch(1) { 10 }.should eq(2)
      a.fetch(3) { 10 }.should eq(4)
      a.fetch(5) { 10 }.should eq(6)
      a.fetch(7) { 10 }.should eq(8)
      a.fetch(9) { 10 }.should eq(10)
    end
  end

  describe "[]=" do
    it "adds a new key-value pair if the key is missing" do
      a = SparseArray(Int32, Int32).new
      a[1] = 2
      a[1].should eq(2)
    end

    it "replaces the value if the key already exists" do
      a = SparseArray(Int32, Int32).new
      a[1] = 2
      a[1] = 3
      a[1].should eq(3)
    end
  end

  describe "has_key?" do
    it "returns true if the given key is present, false otherwise" do
      a = SparseArray{1 => "one", 2 => "two"}
      a.has_key?(1).should be_true
      a.has_key?(2).should be_true
      a.has_key?(3).should be_false
    end
  end

  describe "dup" do
    it "returns a duplicate of the SparseArray" do
      a = SparseArray{1 => "1", 2 => "2"}
      a.should eq(a.dup)
    end
  end

  describe "size" do
    it "returns the number of key-value pairs" do
      a = SparseArray(Int32, Int32).new
      a.size.should eq(0)

      a = SparseArray{1 => 2}
      a.size.should eq(1)

      a = SparseArray{1 => 2, 3 => 4, 5 => 6, 7 => 8}
      a.size.should eq(4)
    end
  end

  describe "to_s" do
    it "returns a string representation" do
      a = SparseArray(Int32, Int32).new
      a.to_s.should eq("{}")

      a = SparseArray{1 => 2}
      a.to_s.should eq("{1 => 2}")

      a = SparseArray{1 => 2, 3 => 4, 5 => 6, 7 => 8}
      a.to_s.should eq("{1 => 2, 3 => 4, 5 => 6, 7 => 8}")
    end
  end
end
