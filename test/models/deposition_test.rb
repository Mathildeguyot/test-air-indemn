require_relative '../test_helper'
#require_relative '../app/models/deposition'

class DepositionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  # # CAS REFUS D'EMBARQUEMENT

  test "Should return true when Refus d'embarquement" do
    reason = "Refus d'embarquement"
    dep_city = "Paris"
    arr_city = "Berlin"
    departure = DateTime.new(2020, 8, 20, 8, 0, 0)
    arrival = DateTime.new(2020, 8, 20, 10, 0, 0)
    depo = Deposition.create(reason: reason, dep_city: dep_city, arr_city: arr_city, departure: departure, arrival: arrival)
    indemn = depo.indemn?
    assert_equal(true, indemn)
  end


  # # CAS ANNULATION SANS REACHEMINEMENT

  # # 1. sans avoir ete alerte

  test "should return true when there is no alert date and the reason is cancelation." do
    reason = 'Annulation'
    dep_city = "Paris"
    arr_city = "Berlin"
    departure = DateTime.new(2020, 8, 20, 8, 0, 0)
    arrival = DateTime.new(2020, 8, 20, 10, 0, 0)
    alert_date = "Jamais"
    depo = Deposition.create(reason: reason, departure: departure, arrival: arrival, dep_city: dep_city, arr_city: arr_city, alert_date: alert_date)
    indemn = depo.indemn?
    assert_equal(true, indemn)
  end

   # 2. alerte entre 7 et 14 jours a l'avance

  test "should return true when the alert date is less than 14 days before the flight and the reason is cancelation." do
    reason = 'Annulation'
    dep_city = "Paris"
    arr_city = "Berlin"
    departure = DateTime.new(2020, 8, 20, 8, 0, 0)
    arrival = DateTime.new(2020, 8, 20, 10, 0, 0)
    alert_date = "Entre 7 et 14 jours avant le vol"
    depo = Deposition.create(reason: reason, departure: departure, arrival: arrival, dep_city: dep_city, arr_city: arr_city, alert_date: alert_date)
    indemn = depo.indemn?
    assert_equal(true, indemn)
  end

  # 3. alerte plus de 14 jours a l'avance

  test "should return false when the alert date is more than 14 days before the flight and the reason is cancelation." do
    reason = 'Annulation'
    dep_city = "Paris"
    arr_city = "Berlin"
    departure = DateTime.new(2020, 8, 20, 8, 0, 0)
    arrival = DateTime.new(2020, 8, 20, 10, 0, 0)
    alert_date = "Plus de 14 jours avant le vol"
    depo = Deposition.create(reason: reason, departure: departure, arrival: arrival, dep_city: dep_city, arr_city: arr_city, alert_date: alert_date)
    indemn = depo.indemn?
    assert_equal(false, indemn)
  end


  # CAS ANNULATION AVEC REACHEMINEMENT

  # 1. prevenu entre 7 et 14 jours a l'avance et reacheminement avec depart 2h max plus tot et arrivee 4h max plus tard

  test "1 should return false when the alert date is more than 7 days before the flight, the real departure is less than 2 hours before the flight, the arrival is less than 4 hours after the arrival and the reason is cancelation." do
    reason = 'Annulation'
    dep_city = "Paris"
    arr_city = "Berlin"
    departure = DateTime.new(2020, 8, 20, 8, 0, 0)
    arrival = DateTime.new(2020, 8, 20, 10, 0, 0)
    alert_date = "Entre 7 et 14 jours avant le vol"
    forward = true
    forward_dep = DateTime.new(2020, 8, 20, 7, 0, 0)
    pp (departure - forward_dep) * 24 < 2
    forward_arr = DateTime.new(2020, 8, 20, 11, 0, 0)
    depo = Deposition.create(forward: forward, forward_dep: forward_dep, forward_arr: forward_arr, reason: reason, departure: departure, arrival: arrival, dep_city: dep_city, arr_city: arr_city, alert_date: alert_date)
    # pp (departure - forward_dep) * 24 <= 2 && (forward_arr - arrival) * 24 <= 4
    indemn = depo.indemn?
    assert_equal(false, indemn)
  end


  # 2. prevenu entre 7 et 14 jours a l'avance et reacheminement avec depart 3h plus tot

  test "2 should return true when the alert date is more than 7 days before the flight, the real departure is more than 2 hours before the flight or the arrival is more than 4 hours after the arrival and the reason is cancelation." do
    reason = 'Annulation'
    dep_city = "Paris"
    arr_city = "Berlin"
    departure = DateTime.new(2020, 8, 20, 8, 0, 0)
    arrival = DateTime.new(2020, 8, 20, 10, 0, 0)
    alert_date = "Entre 7 et 14 jours avant le vol"
    forward = true
    forward_dep = DateTime.new(2020, 8, 20, 5, 0, 0)
    forward_arr = DateTime.new(2020, 8, 20, 11, 0, 0)
    depo = Deposition.create(forward: forward, forward_dep: forward_dep, forward_arr: forward_arr, reason: reason, departure: departure, arrival: arrival, dep_city: dep_city, arr_city: arr_city, alert_date: alert_date)
    indemn = depo.indemn?
    assert_equal(true, indemn)
  end

  # 3. prevenu moins de 7 jours a l'avance et reacheminement avec depart 1h max plus tot et arrivee 2h max plus tard

  test '3 should return false when the alert date is less than 7 days before the flight, the real departure is less than 1 hour before the flight && the arrival is less than 2 hours after the arrival and the reason is cancelation.' do
    reason = 'Annulation'
    dep_city = "Paris"
    arr_city = "Berlin"
    departure = DateTime.new(2020, 8, 20, 8, 0, 0)
    arrival = DateTime.new(2020, 8, 20, 10, 0, 0)
    alert_date = "Moins de 7 jours avant le vol"
    forward = true
    forward_dep = DateTime.new(2020, 8, 20, 8, 0, 0)
    forward_arr = DateTime.new(2020, 8, 20, 11, 0, 0)
    depo = Deposition.create(forward: forward, forward_dep: forward_dep, forward_arr: forward_arr, reason: reason, departure: departure, arrival: arrival, dep_city: dep_city, arr_city: arr_city, alert_date: alert_date)
    indemn = depo.indemn?
    assert_equal(false, indemn)
  end

  # # 4. prevenu moins de 7 jours a l'avance et reacheminement avec depart 2h max plus tot

  test 'should return true when the alert date is less than 7 days before the flight, the real departure is more than 1 hour before the flight or the arrival is more than 2 hours after the arrival and the reason is cancelation.' do
    reason = 'Annulation'
    dep_city = "Paris"
    arr_city = "Berlin"
    departure = DateTime.new(2020, 8, 20, 8, 0, 0)
    arrival = DateTime.new(2020, 8, 20, 10, 0, 0)
    alert_date = "Moins de 7 jours avant le vol"
    forward = true
    forward_dep = DateTime.new(2020, 8, 20, 6, 0, 0)
    forward_arr = DateTime.new(2020, 8, 20, 11, 0, 0)
    depo = Deposition.create(forward: forward, forward_dep: forward_dep, forward_arr: forward_arr, reason: reason, departure: departure, arrival: arrival, dep_city: dep_city, arr_city: arr_city, alert_date: alert_date)
    indemn = depo.indemn?
    assert_equal(true, indemn)
  end

  # CAS ANNULATION CRISE SANITAIRE

  test "2 should return false when there is a problem because of covid" do
    reason = 'Annulation'
    excuse = "Crise sanitaire"
    dep_city = "Paris"
    arr_city = "Berlin"
    departure = DateTime.new(2020, 8, 20, 8, 0, 0)
    arrival = DateTime.new(2020, 8, 20, 10, 0, 0)
    alert_date = "Entre 7 et 14 jours avant le vol"
    forward = true
    forward_dep = DateTime.new(2020, 8, 20, 5, 0, 0)
    forward_arr = DateTime.new(2020, 8, 20, 11, 0, 0)
    depo = Deposition.create(excuse: excuse, forward: forward, forward_dep: forward_dep, forward_arr: forward_arr, reason: reason, departure: departure, arrival: arrival, dep_city: dep_city, arr_city: arr_city, alert_date: alert_date)
    indemn = depo.indemn?
    assert_equal(false, indemn)
  end


  # CAS RETARD SANS REACHEMINEMENT

  # 1. retard de moins de 3h a l'arrivee
  test 'should return false when the reason is late and the delay is less than 3 hours after the arrival.' do
    reason = 'Retard'
    dep_city = "Paris"
    arr_city = "Berlin"
    departure = DateTime.new(2020, 8, 20, 8, 0, 0)
    arrival = DateTime.new(2020, 8, 20, 10, 0, 0)
    delay = "Moins de 3h"
    depo = Deposition.create(reason: reason, departure: departure, arrival: arrival, dep_city: dep_city, arr_city: arr_city, delay: delay)
    indemn = depo.indemn?
    assert_equal(false, indemn)
  end

  # 2. retard de plus de 3h a l'arrivee
  test 'should return true when the reason is late and the delay is more than 3 hours after the arrival.' do
    reason = 'Retard'
    dep_city = "Paris"
    arr_city = "Berlin"
    departure = DateTime.new(2020, 8, 20, 8, 0, 0)
    arrival = DateTime.new(2020, 8, 20, 10, 0, 0)
    delay = "3h ou plus"
    depo = Deposition.create(reason: reason, departure: departure, arrival: arrival, dep_city: dep_city, arr_city: arr_city, delay: delay)
    indemn = depo.indemn?
    assert_equal(true, indemn)
  end

end
