module Griddler
  module Ses
    class AttachmentsWrapper
      attr_reader :attachments

      def initialize(attachments)
        @attachments = attachments
      end

      def call
        attachments.map(&method(:wrap))
      end
      
      private

      def wrap(attachment)
        ActionDispatch::Http::UploadedFile.new({
          type: attachment.mime_type,
          filename: attachment.filename,
          tempfile: tempfile_for_attachment(attachment)
        })
      end

      def tempfile_for_attachment(attachment)
        filename = attachment.filename.gsub(/\/|\\/, '_')
        tempfile = Tempfile.new(filename, Dir::tmpdir, encoding: 'ascii-8bit')
        content = attachment.body.decoded
        tempfile.write(content)
        tempfile.rewind
        tempfile
      end
    end
  end
end
