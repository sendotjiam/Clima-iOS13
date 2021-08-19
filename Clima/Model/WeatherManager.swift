//
//  WeatherManager.swift
//  Clima
//
//  Created by Sendo Tjiam on 18/08/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager : WeatherManager, weather : WeatherModel);
    func didFailWithError(_ error : Error);
}

struct WeatherManager {
    var apiKey = "SECRET-API-KEY";
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&units=metric"
    
    var delegate : WeatherManagerDelegate?;
    
    func fetchWeather(cityName : String) {
        let urlString = "\(weatherURL)&q=\(cityName)";
        performRequest(with: urlString);
    }
    
    func fetchWeather(latitude : CLLocationDegrees, longitude : CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)";
        performRequest(with: urlString);
    }
    
    func performRequest(with urlString : String) {
        // 1. Create URL
        if let url = URL(string: urlString) {
            // 2. Create URLSession
            let session = URLSession(configuration: .default);
            // 3. Give the session a task --> URLSessionDataTask
            // CLOSURE function
            let task = session.dataTask(with: url) { (data, urlResponse, error) in
                if error != nil {
                    print(error!);
                    self.delegate?.didFailWithError(error!);
                    return;
                }
                if let safeData = data {
                    if let weather = parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather);
                    }
                }
            }
            // 4. Start the task
            task.resume();
        }
    }
    
    func parseJSON(_ weatherData : Data) -> WeatherModel? {
        let decoder = JSONDecoder();
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData);
            let id = decodedData.weather[0].id;
            let name = decodedData.name;
            let temp = decodedData.main.temp;
            
            return WeatherModel(conditionId: id, cityName: name, temperature: temp);
        } catch {
            print(error);
            self.delegate?.didFailWithError(error);
            return nil;
        }
    }
    
}
