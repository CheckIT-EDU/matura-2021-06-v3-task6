// 6.1 (0-1): number of concerts that took place in July. Single integer.
#include "testlib.h"
#include <string>
#include <sstream>
using namespace std;

int main(int argc, char* argv[]) {
    registerTestlibCmd(argc, argv);

    int expected = ans.readInt();

    int user_val = -1;
    while (!ouf.eof()) {
        string line = trim(ouf.readString());
        if (line.empty()) continue;
        istringstream iss(line);
        int a;
        if (iss >> a) { user_val = a; break; }
    }

    // Doczytaj resztę wyniku ucznia. Bez tego testlib kończy PRESENTATION ERROR-em i uczeń widzi
    // angielskie „Incorrect output format: Extra information in the output file" zamiast zdania po
    // polsku — a wystarczy JEDEN nadmiarowy wiersz. Punktacja się NIE zmienia: nadmiarowy wiersz to
    // nadal 0 pkt, dokładnie tyle, ile platforma przyznaje dziś za ten błąd formatu.
    bool extra_rows = false;
    while (!ouf.eof())
        if (!trim(ouf.readString()).empty()) extra_rows = true;
    if (extra_rows)
        quitp(_pc(0), "Niepoprawna: oczekiwano jednej wartosci, a zapytanie zwrocilo wiecej wierszy");


    if (user_val == expected)
        quitp(_pc(1), "Poprawna: %d", expected);
    quitp(_pc(0), "Niepoprawna: got %d, expected %d", user_val, expected);
}
