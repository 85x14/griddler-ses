require 'spec_helper'

describe Griddler::Ses::Config do
  it { is_expected.to respond_to :topic_suffix }
  it { is_expected.to respond_to :topic_suffix= }

  it { is_expected.to respond_to :aws_region }
  it { is_expected.to respond_to :aws_region= }
  it { is_expected.to respond_to :aws_access_key_id }
  it { is_expected.to respond_to :aws_access_key_id= }
  it { is_expected.to respond_to :aws_secret_access_key }
  it { is_expected.to respond_to :aws_secret_access_key= }
end

