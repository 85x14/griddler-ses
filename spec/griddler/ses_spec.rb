require 'spec_helper'

describe Griddler::Ses::Adapter do
  before do
    # mock the hash check on the notification, as we've zero'd the numbers
    allow_any_instance_of(AWS::SnsMessage).to receive(:authentic?).and_return(true)
  end

  it 'registers itself with griddler' do
    expect(Griddler.adapter_registry[:ses]).to eq Griddler::Ses::Adapter
  end

  describe "Griddler shared examples" do
    before do
      sns_message[:mail][:commonHeaders][:to] = ['Hello World <hi@example.com>']
      sns_message[:mail][:commonHeaders][:cc] = ['emily@example.com']
      sns_message[:mail][:commonHeaders][:from] = ['There <there@example.com>']

      allow_any_instance_of(Griddler::Ses::Adapter).to receive(:sns_json).and_return(default_params)
    end

    it_behaves_like 'Griddler adapter', :ses, {}
  end

  describe '.normalize_params' do
    it 'parses out the "to" addresses, returning an array' do
      expect(Griddler::Ses::Adapter.normalize_params(default_params)[:to]).to eq ['"Mr Fugushima at Fugu, Inc" <hi@example.com>', 'Foo bar <foo@example.com>']
    end

    it 'parses out the "from" address, returning a string' do
      expect(Griddler::Ses::Adapter.normalize_params(default_params)[:from]).to eq "Test There <there@example.com>"
    end

    it 'parses out the "subject", returning a string' do
      expect(Griddler::Ses::Adapter.normalize_params(default_params)[:subject]).to eq "Test"
    end

    it 'parses out the text' do
      expect(Griddler::Ses::Adapter.normalize_params(default_params)[:text]).to eq "Hi\n"
    end
  end

  let(:default_params) {
    {
      "Type": "Notification",
      "MessageId": "00000000-0000-0000-0000-0000000000000",
      "TopicArn": "arn:aws:sns:us-west-2:0000000000:replies_griddler",
      "Subject": "Amazon SES Email Receipt Notification",
      "Message": sns_message.to_json,
      "Timestamp": "2016-04-12T22:02:34.502Z",
      "SignatureVersion": "1",
      "Signature": "g9FJ0tZvhNJE0uhaIAkFpk4tgRkLfQJyseZIsJy4gNcN1tUeABpIQ7pt7ICZItteAI0UAGT34BFPK0eji/e+/ZplV0wiLWzQAUJyW3hjFP3MWaeSIyXIXCA7i7yTcXvVxqyxWbnmg09RML/D4rMzQlm5Tp1SJVqL3eMR+b7qH0PPelUY3VWDA+/VITeXyG8d4Qa3ssCHHet7SMPeV1keYtAFvRefd1Uq6ACtcHT6BfVNeeGivz85+unTNRN/HNvV/htUzyFu+Gi8gv646IInVl4OP8F44OxcP8M3v9X8dIE1wqKogKZdXLkO7K1QD7occm8HV7vrdIYJf5072VBvQA==",
      "SigningCertURL": "https://sns.us-west-2.amazonaws.com/SimpleNotificationService-bb750dd426d95ee9390147a5624348ee.pem",
      "UnsubscribeURL": "https://sns.us-west-2.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:us-west-2:522466693830:staging_replies_griddler:c6688868-1126-42fd-a6df-2156257538ec"
    }.as_json
  }

  let(:sns_message) {
    {
      "notificationType": "Received",
      "mail": {
        "timestamp": "2016-04-12T22:02:34.087Z",
        "source": "there@example.com",
        "messageId": "vg7gbujm982l5htab7k2ao6ph9lg701kf3d4ito1",
        "destination": [
          "hi@example.com",
          "foo@example.com"
        ],
        "headersTruncated": false,
        "headers": [
          {
            "name": "Received",
            "value": "from [192.168.10.141] ([100.36.63.67]) by smtp.gmail.com with ESMTPSA id p189sm25370923pfb.51.2016.04.12.15.02.32 for <reply@replies.test.com> (version=TLSv1/SSLv3 cipher=OTHER); Tue, 12 Apr 2016 15:02:32 -0700 (PDT)"
          },
          {
            "name": "To",
            "value": '"Mr Fugushima at Fugu, Inc" <hi@example.com>, Foo bar <foo@example.com>',
          },
          {
            "name": "From",
            "value": "Test There <there@example.com>"
          },
          {
            "name": "Subject",
            "value": "Test"
          },
          {
            "name": "Date",
            "value": "Tue, 12 Apr 2016 15:02:32 -0700"
          },
          {
            "name": "User-Agent",
            "value": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:38.0) Gecko/20100101 Thunderbird/38.7.2"
          },
          {
            "name": "MIME-Version",
            "value": "1.0"
          },
          {
            "name": "Content-Type",
            "value": "text/plain; charset=utf-8; format=flowed"
          },
          {
            "name": "Content-Transfer-Encoding",
            "value": "7bit"
          }
        ],
        "commonHeaders": {
          "returnPath": "there@example.com",
          "from": [
            "Test There <there@example.com>",
          ],
          "date": "Tue, 12 Apr 2016 15:02:32 -0700",
          "to": [
            '"Mr Fugushima at Fugu, Inc" <hi@example.com>',
            'Foo bar <foo@example.com>'
          ],
          "subject": "Test"
        }
      },
      "receipt": {
        "timestamp": "2016-04-12T22:02:34.087Z",
        "processingTimeMillis": 375,
        "recipients": [
           "hi@example.com"
        ],
        "spamVerdict": {
          "status": "PASS"
        },
        "virusVerdict": {
          "status": "PASS"
        },
        "spfVerdict": {
          "status": "PASS"
        },
        "dkimVerdict": {
          "status": "PASS"
        },
        "action": {
          "type": "SNS",
          "topicArn": "arn:aws:sns:us-west-2:000000000000:staging_replies_griddler",
          "encoding": "BASE64"
        }
      },
      "content": Base64.encode64(mail_content)
    }
  }

  let(:mail_content) {
    "Return-Path: <there@example.com>\r\nReceived: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])\r\n by inbound-smtp.us-west-2.amazonaws.com with SMTP id vg7gbujm982l5htab7k2ao6ph9lg701kf3d4ito1\r\n for reply@replies.test.com;\r\n Tue, 12 Apr 2016 22:02:34 +0000 (UTC)\r\nX-SES-Spam-Verdict: PASS\r\nX-SES-Virus-Verdict: PASS\r\nReceived-SPF: pass (spfCheck: domain of test.com designates 209.85.192.171 as permitted sender) client-ip=209.85.192.171; envelope-from=test.er@test.com; helo=mail-pf0-f171.google.com;\r\nAuthentication-Results: amazonses.com;\r\n spf=pass (spfCheck: domain of test.com designates 209.85.192.171 as permitted sender) client-ip=209.85.192.171; envelope-from=test.er@test.com; helo=mail-pf0-f171.google.com;\r\n dkim=pass header.i=@test.com;\r\nReceived: by mail-pf0-f171.google.com with SMTP id 184so21324776pff.0\r\n        for <reply@replies.test.com>; Tue, 12 Apr 2016 15:02:33 -0700 (PDT)\r\nDKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;\r\n        d=test.com; s=google;\r\n        h=to:from:subject:message-id:date:user-agent:mime-version\r\n         :content-transfer-encoding;\r\n        bh=j+uJ1+KwQjMpdNiCngwvlv2FTzZnzkokoCYASnN36NE=;\r\n        b=F+gjErW9ENEpFZcLn8mwvDyw4fOp0oVfI/rdc48UK3pRi3LVE15gJ9I+K5tF+Vzqos\r\n         a3a28ggvaOWhxZDpSIp/9XcqbpsnnPbliNrXArXMOYD2hxqgD7VzPjrC9+wu7Gl98RLB\r\n         05w7vTRCNlrzoKALt2SfDNz6iFwEB5Z0Rml6I=\r\nX-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;\r\n        d=1e100.net; s=20130820;\r\n        h=x-gm-message-state:to:from:subject:message-id:date:user-agent\r\n         :mime-version:content-transfer-encoding;\r\n        bh=j+uJ1+KwQjMpdNiCngwvlv2FTzZnzkokoCYASnN36NE=;\r\n        b=O6redBWimLOBW2IiKBoF9bG6+JY5g5hJD8i+5kPGLPKxTqvxYlJjL2jjnKpgsemAp4\r\n         I5374SssbuSQ4AD4k483mBQadPNvTAc9U+M22rxaR0PP/IaTgCQpBOa70q0SZOwpDps8\r\n         6gwhf0pF3dfoLRwFlgMy/RqFad7JJ63nr8q5KIt7gVgsSfvlZhT1Yjj4GAITqeGQP1d+\r\n         uZYbm0N0IBJtYLvybiK+8wTAzxj0sHiz2gQyUH+29iIrLIeAi88rgHCJyRRFWX4mRCum\r\n         Q4z9jCPkFgaPO3PvBqomXT0jIu6OYmpd7pJkE/UAacABPvTKua7ZOYca7zmRiTs/LZEp\r\n         23Wg==\r\nX-Gm-Message-State: AOPr4FUDVHbzUNx7DRqsn7ZfchMoAqKy2WDthXo+xNjLngk5GgbbGPksRz5SoXVwzRn5PKXf\r\nX-Received: by 10.98.34.200 with SMTP id p69mr7861240pfj.114.1460498553646;\r\n        Tue, 12 Apr 2016 15:02:33 -0700 (PDT)\r\nReturn-Path: <test.er@test.com>\r\nReceived: from [192.168.10.141] ([100.36.63.67])\r\n        by smtp.gmail.com with ESMTPSA id p189sm25370923pfb.51.2016.04.12.15.02.32\r\n        for <reply@replies.test.com>\r\n        (version=TLSv1/SSLv3 cipher=OTHER);\r\n        Tue, 12 Apr 2016 15:02:32 -0700 (PDT)\r\nTo: reply@replies.test.com\r\nFrom: Test Er <test.er@test.com>\r\nSubject: Test\r\nMessage-ID: <570D7078.9000204@test.com>\r\nDate: Tue, 12 Apr 2016 15:02:32 -0700\r\nUser-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:38.0)\r\n Gecko/20100101 Thunderbird/38.7.2\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=utf-8; format=flowed\r\nContent-Transfer-Encoding: 7bit\r\n\r\nHi\r\n"
  }
end
