module Suprababel

  # mdl V3000
  MOLFILE_COUNT_LINE_START      = 'M  V30 COUNTS '
  MOLFILE_BEGIN_CTAB_BLOCK_LINE = 'M  V30 BEGIN CTAB'
  MOLFILE_BEGIN_ATOM_BLOCK_LINE = 'M  V30 BEGIN ATOM'
  MOLFILE_END_ATOM_BLOCK_LINE   = 'M  V30 END ATOM'
  MOLFILE_BEGIN_BOND_BLOCK_LINE = 'M  V30 BEGIN BOND'
  MOLFILE_END_BOND_BLOCK_LINE   = 'M  V30 END BOND'
  MOLFILE_END_CTAB_BLOCK_LINE   = 'M  V30 END CTAB'

  # mdl V(2|3)000
  MOLFILE_BLOCK_END_LINE = 'M  END'


    def hello
        'Hello'
    end



        def mofile_2000_cut(molfile)
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


        def molecule_info_from_smiles(smiles)

          molfile = molfile_from_iso_smiles(smiles)


          k = OpenBabel::OBConversion.new
          k.set_in_format 'mol'

          version = molfile_version(molfile)
          is_partial = molfile_has_R(molfile, version)

          molfile = molfile_skip_R(molfile, version) if is_partial

          mf = molfile_clear_coord_bonds(molfile, version)
          if mf
            version += ' T9'
          else
            mf = molfile
          end

          c = OpenBabel::OBConversion.new
          c.set_in_format 'mol'

          m = OpenBabel::OBMol.new
          c.read_string m, mf

          c.set_out_format 'smi'
          smiles = c.write_string(m, false).to_s.gsub(/\s.*/m, "").strip

          c.set_out_format 'can'
          ca_smiles = c.write_string(m, false).to_s.gsub(/\s.*/m, "").strip

          c.set_out_format 'inchi'
          inchi = c.write_string(m, false).to_s.gsub(/\n/, "").strip

          c.set_out_format 'inchikey'
          inchikey = c.write_string(m, false).to_s.gsub(/\n/, "").strip

          {
            charge: m.get_total_charge,
            mol_wt: m.get_mol_wt,
            mass: m.get_exact_mass,
            title_legacy: m.get_title,
            spin: m.get_total_spin_multiplicity,
            smiles: smiles,
            inchikey: inchikey,
            inchi: inchi,
            formula: m.get_formula,
            #svg: svg_from_molfile(mf),
            cano_smiles: ca_smiles,
            fp: fingerprint_from_molfile(mf),


            molfile: molfile
          }

        end


        def molecule_info_from_molfile(molfile)

          k = OpenBabel::OBConversion.new
          k.set_in_format 'mol'

          version = molfile_version(molfile)
          is_partial = molfile_has_R(molfile, version)

          molfile = molfile_skip_R(molfile, version) if is_partial

          mf = molfile_clear_coord_bonds(molfile, version)
          if mf
            version += ' T9'
          else
            mf = molfile
          end

          c = OpenBabel::OBConversion.new
          c.set_in_format 'mol'

          m = OpenBabel::OBMol.new
          c.read_string m, mf

          c.set_out_format 'smi'
          smiles = c.write_string(m, false).to_s.gsub(/\s.*/m, "").strip

          c.set_out_format 'can'
          ca_smiles = c.write_string(m, false).to_s.gsub(/\s.*/m, "").strip

          c.set_out_format 'inchi'
          inchi = c.write_string(m, false).to_s.gsub(/\n/, "").strip

          c.set_out_format 'inchikey'
          inchikey = c.write_string(m, false).to_s.gsub(/\n/, "").strip

          {
            charge: m.get_total_charge,
            mol_wt: m.get_mol_wt,
            mass: m.get_exact_mass,
            title_legacy: m.get_title,
            spin: m.get_total_spin_multiplicity,
            smiles: smiles,
            inchikey: inchikey,
            inchi: inchi,
            formula: m.get_formula,
            svg: svg_from_molfile(mf),
            cano_smiles: ca_smiles,
            fp: fingerprint_from_molfile(mf),


            molfile: molfile
          }

        end


        def mdl_to_svg(molfile_path)
          input = OpenBabel::OBConversion.new
          input.set_in_format 'mol'

          output= OpenBabel::OBMol.new
          input.read_string output, molfile_path
          input.set_out_format 'svg'

          svgfile= input.write_string(output, false)
          return svgfile

        end


        def can_to_svg(cano)
          input = OpenBabel::OBConversion.new
          input.set_in_format 'can'

          output= OpenBabel::OBMol.new
          input.read_string output, cano
          input.set_out_format 'svg'

          svgfile= input.write_string(output, false)
          return svgfile

        end

        def inchi_to_svg(inchi)
          input = OpenBabel::OBConversion.new
          input.set_in_format 'inchi'

          output= OpenBabel::OBMol.new
          input.read_string output, inchi
          input.set_out_format 'svg'

          svgfile= input.write_string(output, false)
          return svgfile

        end

        def iso_to_svg(iso)
          input = OpenBabel::OBConversion.new
          input.set_in_format 'smi'

          output= OpenBabel::OBMol.new
          input.read_string output, iso
          input.set_out_format 'svg'

          svgfile= input.write_string(output, false)
          return svgfile

        end

        def valid_url?(url)
          uri = URI.parse(url)
          return true
        rescue URI::InvalidURIError
          false
        end


        def molfile_from_cano_smiles(cano_smiles)
          #cano_smiles=self.cano_smiles
          c = OpenBabel::OBConversion.new
          c.set_in_format 'can'

          m = OpenBabel::OBMol.new
          c.read_string m, cano_smiles

          c.set_out_format 'mol'
          opts = OpenBabel::OBConversion::GENOPTIONS
          c.add_option 'gen2D', opts
          molfile=c.write_string(m, false).to_s
          #self.mdl_string=molfile
        end

        def molfile_from_iso_smiles(smi)
          c = OpenBabel::OBConversion.new
          c.set_in_format 'smi'

          m = OpenBabel::OBMol.new
          c.read_string m, smi

          c.set_out_format 'mol'
          molfile = c.write_string(m, false).to_s.rstrip
        end

        def smiles_to_canon_smiles
          smiles = self.smiles
          c = OpenBabel::OBConversion.new
          c.set_in_format 'smi'
          c.set_out_format 'can'
          m = OpenBabel::OBMol.new
          c.read_string m, smiles.to_s
          ca_smiles = c.write_string(m, false).to_s.gsub(/\n/, "").strip
          self.cano_smiles= ca_smiles
        end


        def molfile_version(molfile)
          return 'nil' unless molfile.present?
          mf = molfile.lines[0..4]
          return "V#{$1}000" if mf[3]&.strip =~ /V(2|3)000$/
          return "V3000" if mf[4] =~ /^M  V30/
          'unkwn'
        end

        def molfile_has_R(molfile, version = nil)
          version = self.molfile_version(molfile) unless version
          case version[0..5]
          when 'V2000'
            molfile_2000_has_R(molfile)
          when  'V3000'
            molfile_3000_has_R(molfile)
          else
            molfile.include? ' R# '
          end
        end

        def molfile_2000_has_R(molfile)
          molfile.lines[4..-1].each do |line|
            return true if line =~ /^.{31}R\#/
            return false if line =~ /^#{MOLFILE_BLOCK_END_LINE}/
          end
          false
        end

        def molfile_3000_has_R(molfile)
          molfile.lines[4..-1].each do |line|
            return true if line =~ /^M  V30 \d+ R\#/
            return false if line =~ /^#{MOLFILE_END_ATOM_BLOCK_LINE}/
          end
          false
        end


        def molfile_skip_R(molfile, version = nil)
          version = self.molfile_version(molfile) unless version
          case version[0..5]
          when 'V2000'
            molfile_2000_skip_R(molfile)
          when  'V3000'
            molfile_3000_skip_R(molfile)
          else
            begin
              molfile_2000_skip_R(molfile)
            rescue
              false
            end
          end
        end

        # skip residues in molfile and replace with Carbon
        # TODO should be replaced with Hydrogens or removed
        def molfile_2000_skip_R(molfile)
          lines = molfile.lines
          lines.size > 3 && lines[4..-1].each.with_index do |line, i|
            break if line =~ /^#{MOLFILE_BLOCK_END_LINE}/
            # replace residues with Carbons
            lines[i+4] = "#{$1}C #{$'}" if line =~/^(.{31})R\#/
            # delete R group info line
            lines[i+4] = nil if line =~ /^M\s+RGP[\d ]+/
          end
          lines.join
        end

        def molfile_3000_skip_R(molfile)
          lines = molfile.lines
          lines.size > 3 && lines[4..-1].each.with_index do |line, i|
            break if line =~ /^#{MOLFILE_END_ATOM_BLOCK_LINE}/
            # lines[i+4] = "#{$1}C #{$'}" if line =~/^(M  V30 \d+ )R# /
            # replace residues with Carbons, delete R group info
            lines[i+4] = "#{$1}C#{$2}#{$3}#{$'}" if line =~/^(M  V30 \d+ )R#(.*)RGROUPS\=\([\d ]*\)(.*)/
          end
          lines.join
        end

        def molfile_clear_coord_bonds(molfile, version = nil)
          case version || molfile_version(molfile)
          when 'V2000'
            molfile_2000_clear_coord_bonds(molfile)
          when 'V3000'
            molfile_3000_clear_coord_bonds(molfile)
          else
            false
          end
        end

        def molfile_2000_clear_coord_bonds(molfile)
          # clear bond lines with bond type 8(any), 9(coord), or 10(hydrogen)
          # split ctab from properties
          mf = molfile.split(/^(#{MOLFILE_BLOCK_END_LINE}\r?\n)/)
          ctab = mf[0]
          # select lines
          ctab_arr = ctab.lines
          filtered_ctab_arr = ctab_arr.select do |line|
            !line.match(
              /^(  [0-9]| [1-9][0-9]|[1-9][0-9][0-9])(  [0-9]| [1-9][0-9]|[1-9][0-9][0-9])(  [89]| 10)(...)(...)(...)(...)/
            )
          end
          coord_bond_count =  ctab_arr.size - filtered_ctab_arr.size
          return false if coord_bond_count.zero?
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


        def molfile_3000_clear_coord_bonds(molfile)
          # clear bond lines with bond type 8(any), 9(coord), or 10(hydrogen)
          # split ctab from properties asumming only 1 CTAB (no RGFile)
          mf = molfile.split(/^(#{MOLFILE_BLOCK_END_LINE}\r?\n)/)
          ctab = mf[0]
          # select lines
          ctab_arr = ctab.lines
          id_count_line = nil
          id_bond_block_start_line = nil
          count_line_a = nil

          filtered_ctab_arr = ctab_arr.select.with_index do |line, i|
            unless id_count_line
              line =~ /(#{MOLFILE_COUNT_LINE_START}\d+ )(\d+)/
              if $&
                count_line_a = [$1, $2.to_i, $']
                id_count_line = i
                ori_bond_count = $2.to_i
              end
            end
            if !id_bond_block_start_line
              line =~ /#{MOLFILE_BEGIN_BOND_BLOCK_LINE}/ && (id_bond_block_start_line = i)
              next true
            end
            if line.match(/^M  V30 \d+ (8|9|10) \d+ \d+/)
              count_line_a[1] -= 1
              next false
            end
            true
          end

          coord_bond_count =  ctab_arr.size - filtered_ctab_arr.size
          return false if !id_count_line
          return nil if coord_bond_count.zero?
          filtered_ctab_arr[id_count_line] = count_line_a.join

          # concat to molfile
          (filtered_ctab_arr + mf[1..-1]).join
        end

        def svg_from_molfile(molfile, options={})
          c = OpenBabel::OBConversion.new
          c.set_in_format 'mol'
          c.set_out_format 'svg'

          unless options[:highlight].blank?
            c.add_option 's', OpenBabel::OBConversion::GENOPTIONS, "#{options[:highlight]} green"
          end
          c.set_options 'd u', OpenBabel::OBConversion::OUTOPTIONS

          m = OpenBabel::OBMol.new
          c.read_string m, molfile

          #please keep
          #m.do_transformations c.get_options(OpenBabel::OBConversion::GENOPTIONS), c

          c.write_string(m, false)
        end

        def fingerprint_from_molfile(molfile)
          c = OpenBabel::OBConversion.new
          m = OpenBabel::OBMol.new

          c.set_in_format('mol')
          c.read_string(m, molfile)

          fp = OpenBabel::VectorUnsignedInt.new
          # We will gets default size of fingerprint: 1024 bits
          fprinter = OpenBabel::OBFingerprint.find_fingerprint('FP2')
          fprinter.get_fingerprint(m, fp)

          fp_16 = []
          fp_16[0]  = fp[31] << 32 | fp[30]
          fp_16[1]  = fp[29] << 32 | fp[28]
          fp_16[2]  = fp[27] << 32 | fp[26]
          fp_16[3]  = fp[25] << 32 | fp[24]
          fp_16[4]  = fp[23] << 32 | fp[22]
          fp_16[5]  = fp[21] << 32 | fp[20]
          fp_16[6]  = fp[19] << 32 | fp[18]
          fp_16[7]  = fp[17] << 32 | fp[16]
          fp_16[8]  = fp[15] << 32 | fp[14]
          fp_16[9]  = fp[13] << 32 | fp[12]
          fp_16[10] = fp[11] << 32 | fp[10]
          fp_16[11] = fp[9]  << 32 | fp[8]
          fp_16[12] = fp[7]  << 32 | fp[6]
          fp_16[13] = fp[5]  << 32 | fp[4]
          fp_16[14] = fp[3]  << 32 | fp[2]
          fp_16[15] = fp[1]  << 32 | fp[0]

          fp_16
        end



    require 'rubabel'


    def ertl_TPSA(iso_smiles)
      mol = Rubabel::Molecule.from_string(iso_smiles)
      lines = IO.readlines("lib/tpsa.tab")
      header = lines.shift
      patterns = lines.map {|line| line.chomp.split("\t") }
      patterns.inject(0.0) {|s,p| s + p[0].to_f * mol.matches(p[1]).size }
    end

    def xlogP3(iso_smiles)
      #mol-rubabel mol
      mol = Rubabel::Molecule.from_string(iso_smiles)
      mol.write_file("tmp/#{mol.mol_wt}.mol2")
      #now execute the progam as follows:
      `./lib/xlogp_ver3.2.2/XLOGP3/bin/xlogp3 tmp/#{mol.mol_wt}.mol2 tmp/#{mol.mol_wt}.txt lib/xlogp_ver3.2.2/XLOGP3/parameter/DEFAULT.TTDB`
      # xlogp3 tmp/#{mol.smiles}.mol2 tmp/#{mol.smiles}.txt
      # could also work with .ttdb
      out = ""
      File.open("tmp/#{mol.mol_wt}.txt").each do |line|
        out = line.gsub("                              XLOGP3 of MOL *****: ","")
      end
      xlogP3 = out.to_f
      File.delete("tmp/#{mol.mol_wt}.mol2")
      File.delete("tmp/#{mol.mol_wt}.txt")
      return xlogP3
    end

    def rule_of_five

    end

    def fule_of_three

    end

    def ghose_filter

    end

    def vebers_rule

    end


end
