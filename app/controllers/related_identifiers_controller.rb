class RelatedIdentifiersController < ApplicationController
before_action :set_related_identifier, only: [:citation_export]

      def citation_export
        case params[:export]
        when "bibtex"
          send_file(@related_identifier.bibtex.path,
            filename: "#{@related_identifier.relatedIdentifier}.bib")
        when "ris"
          send_file(@related_identifier.ris_export,
            filename: "#{@related_identifier.relatedIdentifier}.ris")
        when "endnote"
          send_file(@related_identifier.enw_export,
            filename: "#{@related_identifier.relatedIdentifier}.enw")

        end
      end


  private
    # Use callbacks to share common setup or constraints between actions.

    def set_related_identifier
      @related_identifier = RelatedIdentifier.find(params[:id])
    end

end
