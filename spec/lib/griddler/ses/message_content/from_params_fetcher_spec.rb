require 'spec_helper'

describe Griddler::Ses::MessageContent::FromParamsFetcher do
  subject(:fetcher) { described_class.new(email_json) }

  let(:email_json) do
    {
      'content' => 'aGVsbG8=\n'
    }
  end

  it 'returns decoded content' do
    expect(fetcher.call).to eq 'hello'
  end
end
