module SupraService
  module Attachments

      def self.png(cid)

        folder_name = "app/assets/images/tmp/#{Time.new.to_i.to_s}_#{rand.to_s}"
        FileUtils.mkdir_p folder_name
        file = File.new("#{folder_name}/compound.png",'w')
        IO.copy_stream(open("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/#{cid}/png"), file.path)
        molecule = Molecule.new
        molecule.png = file
        molecule.save
        FileUtils.rm_rf(folder_name)
      end
  end

end
