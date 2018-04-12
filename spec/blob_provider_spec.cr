require "spec"
require "../src/blob_provider.cr"

describe BlobProvider do

  it "can write blobs to disk" do

  end

end


describe Blob do
  it "can be created from a config" do
    blob = Blob.from_config Config.new("test_name")
    blob.should be_a(Blob)
  end

  it "serializes the config data" do
    blob = Blob.from_config Config.new("test_name")
    blob.data.should be_a(Bytes)
    blob.data.size.should be > 0
  end

  it "deserializes the config data" do
    blob = Blob.from_config Config.new("test_name")
    config = blob.into_config
    config.name.should eq "test_name"
  end

  it "can get blobs from disk" do
    blob = Blob.from_file "./test_blobs/test_config.blob"
    config = blob.into_config
    config.name.should eq "test_name"
  end

  it "raises an exception if deserialization fails" do
    expect_raises(DeserializationDataInvalidError) do
    blob = Blob.from_file "./test_blobs/bad_blob.blob"
    config = blob.into_config
    end
  end

end
