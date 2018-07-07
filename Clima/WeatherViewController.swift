//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController , CLLocationManagerDelegate, ChangeCityProtocol{
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let weatherDataModel = WeatherDataModel()
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeather(url: String, parameters: [String:String]) {
        print(parameters)
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (responce) in
            if responce.result.isSuccess {
                let weatherJson = JSON(responce.result.value!)
                if weatherJson["cod"].int == 200 {
                    self.updateWeatherData(json: weatherJson)
                }else{
                    self.temperatureLabel.text = "--"
                    self.cityLabel.text = weatherJson["message"].stringValue
                }
                
                                print(weatherJson)
                
            }else{
                print("Error \(responce.result.error?.localizedDescription)")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json: JSON){
        weatherDataModel.temperature = Int(json["main"]["temp"].double! - 273.15)
        weatherDataModel.city = json["name"].string!
        weatherDataModel.condition = json["weather"][0]["id"].int!
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        updateUIWeatherData()
        
        
        
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWeatherData(){
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)º"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
                    print("Latitudes : \(location.coordinate.latitude) , Longitudes : \(location.coordinate.longitude)")
            var cdata = [String:String]()
            cdata["lat"] = "\(location.coordinate.latitude)"
            cdata["lon"] = "\(location.coordinate.longitude)"
            cdata["appid"] = APP_ID
            getWeather(url: WEATHER_URL, parameters: cdata)
            
        }
    }
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error \(error.localizedDescription)")
    }
    
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    func getChangedCity(city: String) {
        var param = [String:String]()
        param["q"] = city
        param["appid"] = APP_ID
        print(param)
        getWeather(url: WEATHER_URL, parameters: param)
    }
    
    //Write the userEnteredANewCityName Delegate method here:
    
    
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let vc = segue.destination as! ChangeCityViewController
            vc.delegate = self
        }
    }
    
    
    
}


