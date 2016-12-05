module Spina
  class Printnode
    def self.client
      ::PrintNode::Client.new(auth)
    end

    def self.auth
      ::PrintNode::Auth.new(Rails.application.secrets.printnode_api_key)
    end

    def self.print(pdf_url, printer: nil)
      printjob = ::PrintNode::PrintJob.new(first_printer, 'PrintJob', 'pdf_uri', pdf_url, 'Mr Hop')
      client.create_printjob(printjob)
    end

    def self.first_printer
      client.printers.first.try(:id)
    end
  end
end