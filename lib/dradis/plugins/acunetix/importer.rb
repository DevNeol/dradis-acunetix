module Dradis::Plugins::Acunetix
  class Importer < Dradis::Plugins::Upload::Importer

    # The framework will call this function if the user selects this plugin from
    # the dropdown list and uploads a file.
    # @returns true if the operation was successful, false otherwise
    def import(params={})
      file_content    = File.read( params[:file] )

      logger.info{'Parsing Acunetix output file...'}
      @doc = Nokogiri::XML( file_content )
      logger.info{'Done.'}

      if @doc.xpath('/ScanGroup/Scan').empty?
        error = "No scan results were detected in the uploaded file (/ScanGroup/Scan). Ensure you uploaded an Acunetix XML report."
        logger.fatal{ error }
        content_service.create_note text: error
        return false
      end

      @doc.xpath('/ScanGroup/Scan').each do |xml_scan|
        process_scan(xml_scan)
      end

      return true
    end # /import


    private

    def process_scan(xml_scan)

      start_url = URI::parse(xml_scan.at_xpath('./StartURL').text()).host

      scan_node = content_service.create_node(label: start_url, type: :host)
      logger.info{ "\tScan start URL: #{start_url}" }

      scan_note = template_service.process_template(template: 'scan', data: xml_scan)
      content_service.create_note text: scan_note, node: scan_node

      xml_scan.xpath('./ReportItems/ReportItem').each do |xml_report_item|
        process_report_item(xml_report_item)
      end
    end

    def process_report_item(xml_report_item)
      # TODO
    end
  end
end