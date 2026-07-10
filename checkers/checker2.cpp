// 6.2 (0-2): city (or cities) with the largest TOTAL number of artists. One city name per line.
// CKE rubric: 2 pkt = all the correct cities and nothing else; 1 pkt = at least one correct city name.
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

    // .out: one city name per line
    set<string> expected;
    while (!ans.eof()) {
        string line = trim(ans.readString());
        if (line.empty()) continue;
        expected.insert(toLower(line));
    }

    // MySQL output: one city name per line
    set<string> user;
    while (!ouf.eof()) {
        string line = trim(ouf.readString());
        if (line.empty()) continue;
        user.insert(toLower(line));
    }

    int found = 0;
    for (auto& name : expected)
        if (user.count(name)) found++;
    int total = (int)expected.size();
    bool no_extra = ((int)user.size() == total);

    // 2 pkt both cities, 1 pkt at least one correct city name.
    if (found == total && no_extra)
        quitp(_pc(2), "Poprawna: %d miast", total);
    if (found > 0)
        quitp(_pc(1), "Czesciowo: %d/%d miast", found, total);
    quitp(_pc(0), "Niepoprawna odpowiedz");
}
