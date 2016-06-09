require 'spec_helper'

describe Griddler::Ses::MessageContent::S3Fetcher do
  subject(:fetcher) { described_class.new(action_hash) }

  let(:action_hash) do
    {
      'bucketName' => bucket_name,
      'objectKey'  => object_key
    }
  end
  let(:bucket_name) { 'some_bucket' }
  let(:object_key) { 'h2m78rzhmry72z8r2' }

  let(:s3_object) do
    double(:s3_object,
           body: StringIO.new(content))
  end
  let(:content) { 'Message-ID: dmzd23...' }

  let(:s3_client) { double(:s3_client) }  

  it 'reads message body from S3' do
    expect(Aws::S3::Resource).to receive(:new) { s3_client }
    expect(s3_client).to receive_message_chain(:bucket, :object, :get) { s3_object }
    expect(fetcher.call).to eq content
  end
end
