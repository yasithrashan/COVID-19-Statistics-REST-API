// Creating a dataset of COVID-19 statistics
import ballerina/http;

public type CovidEntry record {|
    readonly string iso_code;

    string country;
    int cases;
    int deaths;
    int recovered;
    int active;
|};

public type ErrorMsg record {|
    string errmsg;
|};
public type ConflictingIsoCodesError record {|
    *http:Conflict;
    ErrorMsg body;
|};

public type InvalidIsoCodeError record {|
    *http:NotFound;
    ErrorMsg body;
|};



public final table<CovidEntry> key(iso_code) covidTable = table [
    {iso_code: "AFG", country: "Afghanistan", cases: 159303, deaths: 7386, recovered: 146084, active: 5833},
    {iso_code: "SL", country: "Sri Lanka", cases: 598536, deaths: 15243, recovered: 568637, active: 14656},
    {iso_code: "US", country: "USA", cases: 69808350, deaths: 880976, recovered: 43892277, active: 25035097}
];

service /covid/status on new http:Listener(9000) {

    // GET endpoint to get data
    resource function get countries() returns CovidEntry[] {
        return covidTable.toArray();
    }

    // POST endpoint to add a new entry
    resource function post countries(@http:Payload CovidEntry[] covidEntries)
        returns CovidEntry[]|ConflictingIsoCodesError {

    string[] conflictingISOs = from CovidEntry covidEntry in covidEntries
                            where covidTable.hasKey(covidEntry.iso_code)
                            select covidEntry.iso_code;

    if conflictingISOs.length() > 0 {
            return {
                body: {
                    errmsg: string:'join(" ", "Conflicting ISO Codes:", ...conflictingISOs)
                }
            };
        } else {
            covidEntries.forEach(covdiEntry => covidTable.add(covdiEntry));
            return covidEntries;
        }
}

}

