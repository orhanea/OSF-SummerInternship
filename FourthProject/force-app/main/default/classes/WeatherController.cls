/*
* **OSF Summer Internship**** 
* *****Fourth Exercise********
* @author Orhan Emre Anıl
* @date Sep 02, 2021
* @name WeatherController
* @description extension for the OpenWeatherMap visualforce page
*/
public with sharing class WeatherController {
   
    public Wrapper wrapperClass { get; set; }
    public String icon { get; set; }
    
    private static final String API_KEY = 'b8725857ec9c45908e1e420b2d3a3e16';
    private static final String endpoint = 'https://api.openweathermap.org/data/2.5/weather?q=';
    private static final String url_icon = 'https://openweathermap.org/img/wn/';
    private ApexPages.StandardController sdtController;
    
    public WeatherController(ApexPages.standardController sdtController) {
        this.sdtController = sdtController;   
    }
    
    private Account acct {
        get {
            if (acct == null) {
                acct = (Account) sdtController.getRecord();
            }
            return acct;
        }
        set;
    }
   
    public void init() {
        try {
             Http http = new Http();
		     HttpRequest request = new HttpRequest();
		     request.setEndpoint(endpoint + acct.BillingCity +'&appid=' + API_KEY);
		     request.setMethod('GET');
		     HttpResponse response = http.send(request);
        
		     // If the request is successful, parse the JSON response.
		     if (response.getStatusCode() == 200) { 
                 wrapperClass = (Wrapper) JSON.deserialize(response.getBody(), Wrapper.class);
                 icon = url_icon + wrapperClass.weather[0]?.icon + '.png';
             }   
        } catch (Exception e) {
            System.debug('Warning. There is an exception: ' + e.getMessage());
        }  
	}    
    
}