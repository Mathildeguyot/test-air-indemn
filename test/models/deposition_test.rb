require_relative '../test_helper'
#require_relative '../app/models/deposition'

class DepositionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Should return true when Refus d'embarquement" do
    depo = Deposition.create(reason: "Refus d'embarquement")
    indemn = depo.indemn?
    assert_equal(true, indemn)
  end
end
