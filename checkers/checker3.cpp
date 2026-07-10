// 6.3 (0-3): for each voivodeship, the average number of concerts per city, rounded to 2 decimals,
// sorted descending. Output "wojewodztwo\tsrednia" per line (16 voivodeships).
//
// CKE rubric (0-3), additive, all tiers {0,1,2,3} reachable:
//   +1 — the AVERAGE is computed (concerts / number of cities) correctly for every voivodeship
//        (i.e. the division was done — accepts a rounded OR an un-rounded value within 0.005);
//   +1 — the values are ROUNDED to 2 decimal places (a value carrying more than 2 decimals — e.g.
//        5.5333 instead of 5.53 — does NOT earn this point, even though it is numerically close);
//   +1 — the rows are sorted by the average descending.
//   Separately, 1 pkt (and only 1) for the CKE partial "obliczenie tylko liczby koncertow w kazdym
//   wojewodztwie" — the un-divided concert TALLY per voivodeship — recognised against the embedded
//   raw counts; this path never coexists with the average path (the tallies, e.g. slaskie=83, are far
//   from the averages, e.g. 5.53).
#include "testlib.h"
#include <string>
#include <vector>
#include <map>
#include <sstream>
#include <cmath>
#include <algorithm>
using namespace std;

static string toLower(string s) {
    for (auto& c : s) c = tolower((unsigned char)c);
    return s;
}

// Raw concert count per voivodeship (the un-divided tally) — the CKE 1-pkt partial oracle.
static const map<string,int> RAW_COUNTS = {
    {"slaskie",83}, {"dolnoslaskie",19}, {"kujawsko-pomorskie",17}, {"wielkopolskie",17},
    {"malopolskie",16}, {"lodzkie",14}, {"lubuskie",13}, {"warminsko-mazurskie",8},
    {"pomorskie",8}, {"swietokrzyskie",8}, {"zachodniopomorskie",8}, {"mazowieckie",8},
    {"opolskie",7}, {"lubelskie",5}, {"podkarpackie",5}, {"podlaskie",4}
};

struct UserVal { double d; bool twoDecimals; };

static bool parseRow(const string& raw, string& name, double& val, bool& twoDecimals) {
    string line = trim(raw);
    if (line.empty()) return false;
    for (auto& c : line) if (c == ',') c = '.';   // accept comma decimal separator
    size_t tab = line.find('\t');
    string valStr;
    if (tab != string::npos) {
        name = toLower(trim(line.substr(0, tab)));
        valStr = trim(line.substr(tab + 1));
    } else {
        istringstream iss(line);
        string n, v;
        if (!(iss >> n >> v)) return false;
        name = toLower(n); valStr = v;
    }
    val = atof(valStr.c_str());
    // "two decimals or fewer": at most 2 digits after the decimal point in the printed value.
    size_t dot = valStr.find('.');
    twoDecimals = (dot == string::npos) || (valStr.size() - dot - 1 <= 2);
    return true;
}

int main(int argc, char* argv[]) {
    registerTestlibCmd(argc, argv);

    // .out: "wojewodztwo\tsrednia" per line (rounded, sorted desc)
    map<string,double> expected;
    while (!ans.eof()) {
        string name; double v; bool td;
        if (parseRow(ans.readString(), name, v, td)) expected[name] = v;
    }

    // MySQL output
    map<string,UserVal> user;
    vector<string> order;
    while (!ouf.eof()) {
        string name; double v; bool td;
        if (parseRow(ouf.readString(), name, v, td)) {
            user[name] = {v, td};
            order.push_back(name);
        }
    }

    bool exact = ((int)user.size() == (int)expected.size());
    if (exact) for (auto& [n,_] : expected) if (!user.count(n)) { exact = false; break; }

    // Average path: division done (values within 0.005 of the rounded key) + rounded (<=2 decimals).
    bool division_ok = exact, rounded_ok = exact;
    if (exact) {
        for (auto& [n, ev] : expected) {
            const UserVal& uv = user[n];
            if (fabs(uv.d - ev) > 0.005) division_ok = false;
            if (!(fabs(uv.d - ev) < 0.005 && uv.twoDecimals)) rounded_ok = false;
        }
    }

    // Counts-only partial: values equal the raw concert tally per voivodeship.
    bool counts_only = exact;
    if (exact) {
        for (auto& [n, cnt] : RAW_COUNTS) {
            auto it = user.find(n);
            if (it == user.end() || fabs(it->second.d - (double)cnt) > 1e-6) { counts_only = false; break; }
        }
    }

    // Sorted descending by value.
    bool sorted_desc = true;
    for (size_t i = 1; i < order.size(); i++)
        if (user[order[i]].d > user[order[i-1]].d + 1e-9) { sorted_desc = false; break; }

    if (division_ok) {
        int score = 1;
        if (rounded_ok) score += 1;
        if (sorted_desc) score += 1;
        if (score == 3) quitp(_pc(3), "Poprawna");
        quitp(_pc(score), "Czesciowo: %d/3 (srednia%s%s)", score,
              rounded_ok ? "" : ", brak zaokraglenia",
              sorted_desc ? "" : ", brak sortowania malejacego");
    }

    if (counts_only)
        quitp(_pc(1), "Czesciowo: obliczono tylko liczbe koncertow w wojewodztwie (bez dzielenia)");

    quitp(_pc(0), "Niepoprawna odpowiedz");
}
