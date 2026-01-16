module SupraService::OpenBabelService


    def self.mofile_2000_cut(molfile)
      # clear bond lines with bond type 8(any), 9(coord), or 10(hydrogen)
      # split ctab from properties
      molefile_block_endline = 'M  END'
      mf = molfile.split(/^(#{molefile_block_endline}\r?\n)/)
      ctab = mf[0]
      # select lines
      ctab_arr = ctab.lines
      filtered_ctab_arr = ctab_arr.select do |line|
        !line.match(
          /^(  [0-9]| [1-9][0-9]|[1-9][0-9][0-9])(  [0-9]| [1-9][0-9]|[1-9][0-9][0-9])(  [89]| 10)(...)(...)(...)(...)/
        )
      end
      coord_bond_count =  ctab_arr.size - filtered_ctab_arr.size

      original_count_line = ctab_arr[3]
      original_count_line.match(/^(  [0-9]| [1-9][0-9]|[1-9][0-9][0-9])(  [0-9]| [1-9][0-9]|[1-9][0-9][0-9]).*V2000$/)
      original_bond_count = $2.to_i
      bond_count = original_bond_count - coord_bond_count
      count_line = original_count_line.clone
      count_line[3..5] = bond_count.to_s.rjust(3)
      filtered_ctab_arr[3] = count_line

      # concat to molfile
      (filtered_ctab_arr + mf[1..-1]).join

    end


    def self.mdl_to_svg(molfile_path)
      input = OpenBabel::OBConversion.new
      input.set_in_format 'mol'

      output= OpenBabel::OBMol.new
      input.read_string output, molfile_path
      input.set_out_format 'svg'

      svgfile= input.write_string(output, false)
      return svgfile

    end


    def self.can_to_svg(cano)
      input = OpenBabel::OBConversion.new
      input.set_in_format 'can'

      output= OpenBabel::OBMol.new
      input.read_string output, cano
      input.set_out_format 'svg'

      svgfile= input.write_string(output, false)
      return svgfile

    end

    def self.inchi_to_svg(inchi)
      input = OpenBabel::OBConversion.new
      input.set_in_format 'inchi'

      output= OpenBabel::OBMol.new
      input.read_string output, inchi
      input.set_out_format 'svg'

      svgfile= input.write_string(output, false)
      return svgfile

    end

    def self.iso_to_svg(iso)
      input = OpenBabel::OBConversion.new
      input.set_in_format 'smi'

      output= OpenBabel::OBMol.new
      input.read_string output, iso
      input.set_out_format 'svg'

      svgfile= input.write_string(output, false)
      return svgfile

    end
end
