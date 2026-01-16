# frozen_string_literal: true

require 'test_helper'
require 'minitest/color'

class MoleculeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @molecule = Molecule.new
    @molecule.display_name = 'unique ethanol'
    @molecule.iso_smiles = 'CCO'
  end

  test 'molecule should be present' do
    assert @molecule.present?
  end

  test 'display_name should be present' do
    assert @molecule.display_name.present?
  end

  test 'iso_smiles should be present' do
    assert @molecule.iso_smiles.present?
  end

  test 'molecule should be valid' do
    assert @molecule.valid?
  end

  test 'molecule should be created by name' do
    molecule = Molecule.find_by(display_name: 'ethanol')
    molecule.destroy if molecule.present?
    molecule = Molecule.new_from_name('ethanol')
    assert molecule.valid?
  end

  test 'molecule should be created by cid' do
    molecule = Molecule.find_by(cid: 30)
    molecule.destroy if molecule.present?
    molecule = Molecule.new_from_cid(30)
    assert molecule.valid?
  end

  test 'cid presence' do
    @molecule.check_cid
    assert @molecule.cid.present?
  end

  test 'fixture one' do
    one = molecules(:molecule_one)
    assert one.valid?
  end

  test 'fixture two' do
    two = molecules(:molecule_two)
    assert two.valid?
  end


end
