// 6.5 (0-3): bands that played more often on weekends than on weekdays. Output
// "nazwa\tweekendy\tdni_powszednie" per line (3 bands).
//
// CKE rubric — additive, 1 pkt for each of the three independently:
//   +1 — the correct set of band NAMES (exactly the bands whose weekend concerts > weekday concerts);
//   +1 — the WEEKEND counts correct for every listed band;
//   +1 — the WEEKDAY (dni powszednie) counts correct for every listed band.
// (So "correct names, wrong numbers" scores 1; the weekend / weekday points require the names first.)
#include "testlib.h"
#include <string>
#include <map>
#include <vector>
#include <algorithm>
using namespace std;

static string toLower(string s) {
    for (auto& c : s) c = tolower((unsigned char)c);
    return s;
}

// Parse a tab row: last field = weekday count, second-to-last = weekend count, the rest = the name.
static bool parseRow(const string& raw, string& name, int& weekend, int& weekday) {
    string line = trim(raw);
    if (line.empty()) return false;
    vector<string> parts;
    size_t pos = 0;
    while (true) {
        size_t tab = line.find('\t', pos);
        if (tab == string::npos) { parts.push_back(line.substr(pos)); break; }
        parts.push_back(line.substr(pos, tab - pos));
        pos = tab + 1;
    }
    if (parts.size() < 3) return false;
    try {
        weekday = stoi(trim(parts.back())); parts.pop_back();
        weekend = stoi(trim(parts.back())); parts.pop_back();
    } catch (...) { return false; }
    name.clear();
    for (auto& p : parts) { if (!name.empty()) name += " "; name += trim(p); }
    name = toLower(name);
    return true;
}

int main(int argc, char* argv[]) {
    registerTestlibCmd(argc, argv);

    // .out: "nazwa\tweekendy\tdni_powszednie"
    map<string, pair<int,int>> expected;   // name -> {weekend, weekday}
    while (!ans.eof()) {
        string name; int we, wd;
        if (parseRow(ans.readString(), name, we, wd)) expected[name] = {we, wd};
    }

    map<string, pair<int,int>> user;
    while (!ouf.eof()) {
        string name; int we, wd;
        if (parseRow(ouf.readString(), name, we, wd)) user[name] = {we, wd};
    }

    int score = 0;

    // 1 pkt: correct set of band names.
    bool names_ok = ((int)user.size() == (int)expected.size());
    if (names_ok) for (auto& [n,_] : expected) if (!user.count(n)) { names_ok = false; break; }
    if (names_ok) score += 1;

    // 1 pkt: weekend counts correct for every band (requires the names first).
    bool weekends_ok = names_ok;
    if (names_ok) for (auto& [n, v] : expected)
        if (user[n].first != v.first) { weekends_ok = false; break; }
    if (weekends_ok) score += 1;

    // 1 pkt: weekday counts correct for every band (requires the names first).
    bool weekdays_ok = names_ok;
    if (names_ok) for (auto& [n, v] : expected)
        if (user[n].second != v.second) { weekdays_ok = false; break; }
    if (weekdays_ok) score += 1;

    if (score == 3) quitp(_pc(3), "Poprawna");
    if (score > 0) quitp(_pc(score), "Czesciowo: %d/3", score);
    quitp(_pc(0), "Niepoprawna odpowiedz");
}
