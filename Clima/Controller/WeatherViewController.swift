//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

//Added Text Field Delegate
class WeatherViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //The text field should report back to view controller. (Connects it go "Go" button)
        //Can alert it to user typing/not typing
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        searchTextField.delegate = self
        weatherManager.delegate = self
        
    }



    
}

//MARK: -UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        //Get value of text field.
        searchTextField.endEditing(true)
        
    }
    //Triggers when user presses "return"/"go"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
        return true
    }
    
    //Decides what happens when the user deselects the text field. Good for validation.
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something."
            return false
        }
    }
    
    //Code triggered when editing is ended using any method.
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Use searchTextField.text to get the weather for that city.
        //Check if string, if so, call fetchWeather function.
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        
        //Clears text field.
        searchTextField.text = ""
    }
}

//MARK: -WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weatherObject: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weatherObject.temperatureString
            self.conditionImageView.image = UIImage(systemName: weatherObject.conditionName)
            self.cityLabel.text = weatherObject.cityName
        }
        
    }
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    @IBAction func locationUpdatePressed(_ sender: UIButton) {
        locationManager.requestLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(longitude: lon, lattitude: lat)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
