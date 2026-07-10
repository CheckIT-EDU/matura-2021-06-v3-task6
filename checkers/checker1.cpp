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

    if (user_val == expected)
        quitp(_pc(1), "Poprawna: %d", expected);
    quitp(_pc(0), "Niepoprawna: got %d, expected %d", user_val, expected);
}
