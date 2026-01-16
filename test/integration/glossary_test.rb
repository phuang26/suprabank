require 'test_helper'

class GlossaryPageTest < Capybara::Rails::TestCase


test 'introduction exists' do
  visit glossary_path
  assert page.has_content?("Glossary")
  assert has_css?(".eq", count: 34)

  assert has_selector?("#host_guest_chemistry")
  assert has_selector?("#protein-ligand_binding")
  assert has_selector?("#f1")
  assert has_selector?("#artificial_host_systems")
  assert has_selector?("#HGC_ref")
  assert has_link?("Ed.: B. Wang, E. V. Anslyn")
  click_link "Ed.: B. Wang, E. V. Anslyn"
  assert_no_current_path glossary_path
end

test 'Assay chapter exists' do
  visit glossary_path
  assert has_selector?("#assay_type")
  assert has_selector?("#direct_binding_assay")
  assert has_selector?("#f2")
  assert has_selector?("#associative_binding_assay")
  assert has_selector?("#f3")
  assert has_selector?("#competitive_binding_assay")
  assert has_selector?("#f4")
  assert has_selector?("#AT_ref")
  assert has_link?("H. Tang, D. Fuentealba")
  click_link "H. Tang, D. Fuentealba"
  assert_no_current_path glossary_path
 end

 test 'technique chapter exists' do
  visit glossary_path
  assert has_selector?("#techniques")
  assert has_selector?("#itc")
  assert has_selector?("#f5")
  assert has_selector?("#itc_data_acquisition_example")
  assert has_selector?("#f5a")
  assert has_selector?("#nmr")
  assert has_selector?("#f6")
  assert has_selector?("#photophysics")
  assert has_selector?("#Jablonski")
  assert has_selector?("#f7")
  assert has_selector?("#abs")
  assert has_selector?("#f8")
  assert has_selector?("#f9")
  assert has_selector?("#fl")
  assert has_selector?("#f10")
  assert has_selector?("#cd")
  assert has_selector?("#f11")
  assert has_selector?("#f12")
  assert has_selector?("#sers")
  assert has_selector?("#ext")
  assert has_selector?("#pot")
  assert has_selector?("#epr")
  assert has_selector?("#Tec_ref")
  assert has_link?("M. W. Freyer, E. A. Lewis")
  click_link "M. W. Freyer, E. A. Lewis"
  assert_no_current_path glossary_path
 end

 test 'TD chapter exists' do

   visit glossary_path
   assert has_selector?("#theory")
   assert has_selector?("#SimFit_tools")
   assert has_link?("Mathematica software package ASDSE thermoSimFit")
   click_link "Mathematica software package ASDSE thermoSimFit"
   assert_no_current_path glossary_path

   visit glossary_path
   assert has_link?("Mathematica software package ASDSE kineticSimFit")
   click_link "Mathematica software package ASDSE kineticSimFit"
   assert_no_current_path glossary_path

   visit glossary_path
   assert has_selector?("#TD")
   assert has_selector?("#TD_Ka")
   assert has_selector?("#TD_dG")
   assert has_selector?("#TD_unit")
   assert has_selector?("#t1")
   assert has_selector?("#jobs")
   assert has_selector?("#f13")
   assert has_selector?("#TD_E")
   assert has_selector?("#Kin")
   assert has_selector?("#kinetics_pfo")
   assert has_selector?("#Kin_Ea")
   assert has_selector?("#TD_ref")
   assert has_link?("C. Y. Huand")
   click_link "C. Y. Huand"
   assert_no_current_path glossary_path

   visit glossary_path
   assert has_selector?("#simulations")
 end

end
