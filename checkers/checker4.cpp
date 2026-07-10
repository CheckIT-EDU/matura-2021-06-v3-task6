// 6.4 (0-2): names of bands that did NOT play any concert between 20 and 25 July 2017 inclusive.
// One band name per line (10 bands).
//
// CKE rubric:
//   2 pkt — exactly the 10 correct bands (the 20-25 July window, both boundary days included).
//   1 pkt — exactly the set produced when the BOUNDARY DAYS are dropped (21-24 July only) = 15 bands.
//           This is the one named CKE partial ("odpowiedz nieuwzgledniajaca dni granicznych"); it is
//           the ONLY thing worth 1 pkt, so it is matched exactly (an arbitrary partial hit scores 0).
//   0 pkt — otherwise.
#include "testlib.h"
#include <string>
#include <set>
#include <algorithm>
using namespace std;

static string toLower(string s) {
    for (auto& c : s) c = tolower((unsigned char)c);
    return s;
}

int main(int argc, char* argv[]) {
    registerTestlibCmd(argc, argv);

    // The 15-band set obtained by excluding the boundary days (bands not playing 21-24 July) — the
    // named CKE 1-pkt partial.
    set<string> withoutBoundaryDays = {
        "male nutki", "stare mandoliny", "wiosenne bebny", "powolne fortepiany", "ciche organy",
        "fajne trojkaty", "rozstrojone pianina", "metalowe klarnety", "zlote saksofony",
        "piszczace trabki", "czarne klawesyny", "czerwone wiolonczele", "jesienne talerze",
        "rytmiczne wibrafony", "zielone akordeony"
    };

    // .out: one band name per line (the 10 correct bands)
    set<string> expected;
    while (!ans.eof()) {
        string line = trim(ans.readString());
        if (line.empty()) continue;
        expected.insert(toLower(line));
    }

    // MySQL output
    set<string> user;
    while (!ouf.eof()) {
        string line = trim(ouf.readString());
        if (line.empty()) continue;
        user.insert(toLower(line));
    }

    if (user == expected)
        quitp(_pc(2), "Poprawna: %d zespolow", (int)expected.size());

    if (user == withoutBoundaryDays)
        quitp(_pc(1), "Czesciowo: zbior bez dni granicznych (21-24 lipca) — %d zespolow",
              (int)withoutBoundaryDays.size());

    quitp(_pc(0), "Niepoprawna odpowiedz");
}
