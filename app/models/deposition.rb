require 'json'
require 'open-uri'

class Deposition < ApplicationRecord
  REASON = ["Retard", "Annulation", "Refus d'embarquement"]
  ALERT = ["Plus de 14 jours avant le vol", "Entre 7 et 14 jours avant le vol", "Moins de 7 jours avant le vol", "Jamais"]
  DELAY = ["Moins de 2h", "Entre 2h et 3h", "Entre 3h et 4h", "Plus de 4h" ]
  EXCUSE = ["Conditions météorologiques", "Problème technique", "Grève", "Aucune raison"]
  UE = ["AT", "GF", "FR", "DE", "ES", "PT", "IT", "BE", "BG", "CY", "HR", "DK", "EE", "FI", "GR", "HU", "IE", "LV", "LT", "LU", "MA", "NL", "PL", "RO", "SI", "SK", "SE", "CZ", "MQ"]

  def indemn?
    # cas refus d'embarquement
    if reason == "Refus d'embarquement"
      return true
    # cas annulation
    elsif reason == "annul"
      # cas pas prevenu
      if alert_date == "Jamais"
        return true
      # cas prevenu et reacheminement
      elsif forward?
        # cas prevenu plus de 7 jours a l'avance
        if alert_date == "Entre 7 et 14 jours avant le vol" || alert_date == "Plus de 14 jours avant le vol"
          (departure - forward_dep) * 24 <= 2 && (forward_arr - arrival) * 24 <= 4 ? false : true
        # cas prevenu moins de 7 jours a l'avance
        else
          (departure - forward_dep) * 24 <= 1 && (forward_arr - arrival) * 24 <= 2 ? false : true
        end
      # cas prevenu mais pas de reacheminement
      else
        alert_date == "Plus de 14 jours avant le vol" ? false : true
      end
    # cas retard
    elsif reason == "Retard"
      (forward_arr - arrival) * 24 >= 3 && alert_date != "Plus de 14 jours avant le vol" ? true : false
    end
  end

  def distance
    url1 = "https://maps.googleapis.com/maps/api/geocode/json?address=#{dep_city}&key=AIzaSyBwPq7BdcZGiHBlmSkL1IgcRWh9BtCyh5M"
    city1 = JSON.parse(open(url1).read)
    lat1 = (city1['results'][0]['geometry']['location']['lat'] * Math::PI) / 180
    lng1 = (city1['results'][0]['geometry']['location']['lng'] * Math::PI) / 180

    url2 = "https://maps.googleapis.com/maps/api/geocode/json?address=#{arr_city}&key=AIzaSyBwPq7BdcZGiHBlmSkL1IgcRWh9BtCyh5M"
    city2 = JSON.parse(open(url2).read)
    lat2 = (city2['results'][0]['geometry']['location']['lat'] * Math::PI) / 180
    lng2 = (city2['results'][0]['geometry']['location']['lng'] * Math::PI) / 180

    distance = 6371 * Math.acos(Math.sin(lat1) * Math.sin(lat2) + Math.cos(lat1) * Math.cos(lat2) * Math.cos((lng2 - lng1).abs))

    return distance.floor
  end

  def intra?
    url1 = "https://maps.googleapis.com/maps/api/geocode/json?address=#{dep_city}&key=AIzaSyBwPq7BdcZGiHBlmSkL1IgcRWh9BtCyh5M"
    city1 = JSON.parse(open(url1).read)
    country1 = city1['results'][0]['address_components'].last['short_name']
    url2 = "https://maps.googleapis.com/maps/api/geocode/json?address=#{arr_city}&key=AIzaSyBwPq7BdcZGiHBlmSkL1IgcRWh9BtCyh5M"
    city2 = JSON.parse(open(url2).read)
    country2 = city2['results'][0]['address_components'].last['short_name']
    UE.include?(country1) && UE.include?(country2)
  end

  def amount
    result = 0
    if distance <= 1500
      result += 250
      # si acheminement propose avec moins de deux heures de retard a l'arrivee
      result -= 125 if forward? && (forward_arr - arrival) * 24 <= 2
    elsif distance > 1500 && intra? || distance > 1500 && distance <= 3500
      result += 400
      result -= 200 if forward? && (forward_arr - arrival) * 24 <= 3
    else
      result += 600
      result -= 300 if forward? && (forward_arr - arrival) * 24 <= 4
    end

    result
  end
end
