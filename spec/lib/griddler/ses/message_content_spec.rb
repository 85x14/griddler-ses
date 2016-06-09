require 'spec_helper'

describe Griddler::Ses::MessageContent do
  subject(:resolver) { described_class }

  describe '.resolve' do
    let(:email_json) do
      {
        'receipt' => {
          'action' => action_hash
        },
        'content' => 'Some'
      }
    end

    let(:action_hash) do
      {
        'type' => action_type,
        'objectKey' => 'ahaha'
      }
    end

    let(:fetcher) { double(:fetcher, call: nil) }

    after do
      resolver.resolve(email_json)
    end
    
    context 'when action is S3' do
      let(:action_type) { 'S3' }

      it 'calls proper fetcher' do
        expect(Griddler::Ses::MessageContent::S3Fetcher).to receive(:new).with(action_hash) { fetcher }
      end
    end

    context 'when action is SNS' do
      let(:action_type) { 'SNS' }

      it 'calls proper fetcher' do
        expect(Griddler::Ses::MessageContent::FromParamsFetcher).to receive(:new).with(email_json) { fetcher }
      end
    end
  end
end
