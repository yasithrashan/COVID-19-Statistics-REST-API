import ballerina/http;

// In memeory to keep data
final json[] covidStatusList =[];

service /covid/status/countries on new http:Listener(8080) {
    
    // GET /covid/status/countries
    resource function get .() returns json { 
        return covidStatusList;
        
    }


    // POST /covid/status/countries
    resource function post .(http:Caller caller,http:Request req) returns error? {
        json newCountryStatus  = check req.getJsonPayload();
        covidStatusList.push(newCountryStatus );


        // Respond to the caller
        check caller->respond(
            {
                status: http:STATUS_CREATED,
                message: { message: "Country COVID-19 status added", data: newCountryStatus }
            }
        );
    }
}