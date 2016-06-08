require 'spec_helper'

describe Griddler::Ses::Config do
  it { is_expected.to respond_to :topic_suffix }
  it { is_expected.to respond_to :topic_suffix= }
end

