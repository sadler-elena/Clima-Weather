//
//  WeatherManager.swift
//  Clima
//
//  Created by Elena Sadler on 10/31/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weatherObject: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?units=imperial&appid=13da0f39f3dc06237367f45a3f222a62"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    func fetchWeather(longitude: CLLocationDegrees, lattitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(lattitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        //Carry out networking steps: 1) Create URL 2) Create urlSession 3) Give urlSession a task 4) Start the task
        //1) Create URL (create optional URL?)
        if let url = URL(string: urlString) {
            //2) Create session
            let session = URLSession(configuration: .default)
            
            //3) Give session a task
            //When the task is complete, it will call the completionHandler
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    //Tells function to exit, if there was an error
                    return
                }
                if let safeData = data {
                    //Time to parse! (in JSON format)
                    if let weatherObject = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weatherObject: weatherObject)
                    }
                    
                }
            }
            
            //4) Start the task
            task.resume()
        }
        

    }
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temperature = decodedData.main.temp
            let cityName = decodedData.name
            
            let weatherObject = WeatherModel(conditionID: id, cityName: cityName, temperature: temperature)
            print(weatherObject.conditionName)
            print(weatherObject.temperatureString)
            return weatherObject
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }

    
}

