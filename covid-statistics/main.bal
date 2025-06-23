import ballerina/http;

service /covid/status on new http:Listener(9000) {

    resource function get countries() returns CovidEntry[] {
        return covidTable.toArray();
    }

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
            covidEntries.forEach(covidEntry => covidTable.add(covidEntry));
            return covidEntries;
        }
    }

    resource function get countries/[string iso_code]() returns CovidEntry|InvalidIsoCodeError {
        CovidEntry? covidEntry = covidTable[iso_code];
        if covidEntry is () {
            return {
                body: {
                    errmsg: string `Invalid ISO Code: ${iso_code}`
                }
            };
        }
        return covidEntry;
    }

    resource function put countries/[string iso_code](@http:Payload CovidEntry updatedEntry)
                                    returns CovidEntry|error {
        if !covidTable.hasKey(iso_code) {
            return error(string `Invalid ISO Code: ${iso_code}`);
        }
        
        if updatedEntry.iso_code != iso_code {
            return error("ISO code in payload does not match path parameter");
        }
        
        covidTable.put(updatedEntry);
        return updatedEntry;
    }

    resource function delete countries/[string iso_code]() returns http:NoContent|InvalidIsoCodeError {
        if !covidTable.hasKey(iso_code) {
            return {
                body: {
                    errmsg: string `Invalid ISO Code: ${iso_code}`
                }
            };
        }
        
        _ = covidTable.remove(iso_code);
        return http:NO_CONTENT;
    }
}

public type CovidEntry record {|
    readonly string iso_code;
    string country;
    decimal cases;
    decimal deaths;
    decimal recovered;
    decimal active;
|};

public final table<CovidEntry> key(iso_code) covidTable = table [
    {iso_code: "AFG", country: "Afghanistan", cases: 159303, deaths: 7386, recovered: 146084, active: 5833},
    {iso_code: "LK", country: "Sri Lanka", cases: 598536, deaths: 15243, recovered: 568637, active: 14656},
    {iso_code: "US", country: "USA", cases: 69808350, deaths: 880976, recovered: 43892277, active: 25035097}
];

public type ConflictingIsoCodesError record {|
    *http:Conflict;
    ErrorMsg body;
|};

public type InvalidIsoCodeError record {|
    *http:NotFound;
    ErrorMsg body;
|};

public type ErrorMsg record {|
    string errmsg;
|};