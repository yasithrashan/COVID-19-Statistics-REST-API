// Creating a dataset of COVID-19 statistics

public type CovidEntry record {|
    readonly string iso_code;

    string country;
    int cases;
    int deaths;
    int recovered;
    string active;
 |};

 public final table<CovidEntry> key(iso_code) covidTable = table [
    { iso_code: "USA", country: "United States", cases: 1000000, deaths: 50000, recovered: 800000, active: "150000" },
    { iso_code: "IND", country: "India", cases: 900000, deaths: 30000, recovered: 700000, active: "170000" },
    { iso_code: "BRA", country: "Brazil", cases: 800000, deaths: 40000, recovered: 600000, active: "160000" },
    { iso_code: "RUS", country: "Russia", cases: 700000, deaths: 20000, recovered: 500000, active: "180000" },
    { iso_code: "GBR", country: "United Kingdom", cases: 600000, deaths: 25000, recovered: 450000, active: "175000" }
];

