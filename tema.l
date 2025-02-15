/* LAVINIA TUDOR 334CC */

%{
#include <iostream>
#include <cstdio>
#include <vector>
#include <string>
#include <unordered_map>
#include <unordered_set>

using namespace std;

extern "C" {
    extern int yylex();
    int yywrap() {
        return 1;
    }
}

unordered_map<string, vector<string>> variabile;
unordered_set<string> nume_variabile_locale;
string var_name;

vector<string> alfabet;
vector<string> stari;
string stare_start;
vector<string> litere_tranzitie;
unordered_map<string, vector<pair<string, string>>> tranzitii;

int nr_productii = 0;

void scrie_tip_automat() {
    cout << "Tipul automatului: ";
    bool determinist = true;
    for (const auto& tranzitie : tranzitii) {
        for (const auto& val : tranzitie.second) {
            if (val.first == "e") {
                determinist = false;
                break;
            }
            int cnt = 0;
            for (const auto& val2 : tranzitie.second) {
                if (val.first == val2.first) {
                    cnt++;
                }
            }
            if (cnt > 1) {
                determinist = false;
                break;
            }
        }
        if (!determinist) {
            break;
        }
    }
    if (determinist) {
        cout << "determinist" << endl;
    } else {
        cout << "nedeterminist" << endl;
    }
}

void scrie_variabile_locale() {
    for (auto& x : variabile) {
        if (nume_variabile_locale.find(x.first) == nume_variabile_locale.end()) {
            continue;
        }
        cout << "Variabila locala: " << endl;
        cout << "   Identificator: " << x.first << endl;
        cout << "   Domeniu: { ";
        for (auto& y : x.second) {
            if (x.second.back() == y) {
                cout << y << " }" << endl;
            } else {
                cout << y << ", ";
            }
        }
    }
}

%}

%option stack

%s citeste_nume_variabila_globala citeste_nume_variabila_locala variabila_globala variabila_locala
%s corp_automat corp_gramatica
%s sterge_inceput sterge_inceput_variabila sterge_inceput_tranzitie sterge_punct_si_virgula
%s citeste_alfabet citeste_stari citeste_stare_initiala citeste_productii
%s proceseaza_tranzitie proceseaza_final_tranzitie
%s scrie_domeniu

ws [ \t]

variable [vV][aA][rR][iI][aA][bB][lL][eE]
finite_automaton [fF][iI][nN][iI][tT][eE][aA][uU][tT][oO][mM][aA][tT][oO][nN]
grammar [gG][rR][aA][mM][mM][aA][rR]
alphabet [aA][lL][pP][hH][aA][bB][eE][tT]{ws}*"::"{ws}*
states [sS][tT][aA][tT][eE][sS]{ws}*"::"{ws}*
final_states [fF][iI][nN][aA][lL]"_"[sS][tT][aA][tT][eE][sS]{ws}*"::"{ws}*
initial_state [iI][nN][iI][tT][iI][aA][lL]"_"[sS][tT][aA][tT][eE]{ws}*"::"{ws}*
nonterminals [nN][oO][nN][tT][eE][rR][mM][iI][nN][aA][lL][sS]{ws}*"::"{ws}*
start_symbol [sS][tT][aA][rR][tT]"_"[sS][yY][mM][bB][oO][lL]{ws}*"::"{ws}*

%%

"%"[^\n]*\n { ; }
"/*"([^*]|"*"+[^*/])*"*"+"/" { ; }

" "|\t|\n { ; }

<sterge_inceput>("::="{ws}*{finite_automaton}|"::="{ws}*{grammar}){ws}*({ws}|\n)*{ws}*"\(" {
    yy_pop_state();
}

<sterge_inceput_variabila>"::="{ws}*"\{" {
    yy_pop_state();
}

<sterge_inceput_tranzitie>"->"{ws}*"\(" {
    yy_pop_state();
}

<sterge_punct_si_virgula>";" {
    yy_pop_state();
}

<INITIAL>{
    [a-zA-Z0-9_]+/{ws}*"::="{ws}*{finite_automaton} {
        cout << "Numele automatului: " << yytext << endl;

        yy_push_state(corp_automat);
        yy_push_state(sterge_inceput);
    }
    [a-zA-Z0-9_]+/{ws}*"::="{ws}*{grammar} {
        cout << "Numele gramaticii: " << yytext << endl;

        yy_push_state(corp_gramatica);
        yy_push_state(sterge_inceput);
    }
    {variable} {
        yy_push_state(variabila_globala);
        yy_push_state(sterge_inceput_variabila);
        yy_push_state(citeste_nume_variabila_globala);
    }
}

<citeste_nume_variabila_globala>[a-z][a-zA-Z0-9_]* {
    var_name = yytext;
    yy_pop_state();
}

<citeste_nume_variabila_locala>[a-z][a-zA-Z0-9_]* {
    nume_variabile_locale.insert(yytext);
    var_name = yytext;
    yy_pop_state();
}

<variabila_globala>{
    , { ; }
    [a-z0-9] {
        variabile[var_name].push_back(yytext);
    }
    "\}"{ws}*";" {
        cout << "Variabila globala: " << endl;
        cout << "   Identificator: " << var_name << endl;
        cout << "   Domeniu: { ";
        for (auto& x : variabile[var_name]) {
            if (variabile[var_name].back() == x) {
                cout << x << " }" << endl;
            } else {
                cout << x << ", ";
            }
        }
        cout << endl;

        yy_pop_state();
    }
}

<variabila_locala>{
    , { ; }
    [a-z0-9] {
        variabile[var_name].push_back(yytext);
    }
    "\}"{ws}*";" {
        yy_pop_state();
    }
}

<corp_automat>{
    {variable} {
        yy_push_state(variabila_locala);
        yy_push_state(sterge_inceput_variabila);
        yy_push_state(citeste_nume_variabila_locala);
    }
    {alphabet}"\{" {
        cout << "Alfabetul: { ";
        yy_push_state(citeste_alfabet);
    }
    {states}"\{" {
        cout << "Numarul de stari: ";
        yy_push_state(citeste_stari);
    }
    {final_states} {
        cout << "Starile finale: ";
        yy_push_state(scrie_domeniu);
    }
    {initial_state} {
        cout << "Starea initiala: ";
        yy_push_state(citeste_stare_initiala);
    }
    [a-zA-Z][a-zA-Z0-9_]* {
        stare_start = yytext;
        yy_push_state(proceseaza_tranzitie);
        yy_push_state(sterge_inceput_tranzitie);
    }
    "\)"{ws}*";;" {
        scrie_tip_automat();
        cout << "Functia de tranzitie: " << endl;
        for (const auto& tranzitie : tranzitii) {
            for (const auto& val : tranzitie.second) {
                cout << "  m(" << tranzitie.first << ", " << val.first << ") = " << val.second << endl;
            }
        }
        scrie_variabile_locale();
        cout << endl;

        alfabet.clear();
        stari.clear();
        litere_tranzitie.clear();
        for (auto& nume : nume_variabile_locale) {
            variabile.erase(nume);
        }
        nume_variabile_locale.clear();


        yy_pop_state();
    }
}

<corp_gramatica>{
    {variable} {
        yy_push_state(variabila_locala);
        yy_push_state(sterge_inceput_variabila);
        yy_push_state(citeste_nume_variabila_locala);
    }
    {alphabet} {
        cout << "Alfabetul: ";
        // aici nu trebuie si retinut
        yy_push_state(scrie_domeniu);
    }
    {nonterminals}"\{".*"\}"{ws}*";" { ; }
    {start_symbol}.*";" { ; }
    [A-Z][a-zA-Z0-9_]*.*"->" {
        yy_push_state(citeste_productii);
    }
    "\)"{ws}*";;" {
        cout << "Numarul de reguli de productie: " << nr_productii << endl;
        scrie_variabile_locale();
        cout << endl;

        nr_productii = 0;
        for (auto& nume : nume_variabile_locale) {
            variabile.erase(nume);
        }
        nume_variabile_locale.clear();
        yy_pop_state();
    }
}

<citeste_alfabet>{
    , { ; }
    [a-z0-9] {
        alfabet.push_back(yytext);
        cout << yytext << ", ";
    }
    [a-z0-9]/{ws}*"\}" {
        alfabet.push_back(yytext);
        cout << yytext << " }" << endl;
    }
    "\}" {
        yy_pop_state();
        yy_push_state(sterge_punct_si_virgula);
    }
}

<citeste_stari>{
    , { ; }
    [a-zA-Z][a-zA-Z0-9_]* {
        stari.push_back(yytext);
    }
    "\}" {
        cout << stari.size() << endl;
        yy_pop_state();
        yy_push_state(sterge_punct_si_virgula);
    }
}

<scrie_domeniu>"\{".*"\}" {
    cout << yytext << endl;
    yy_pop_state();
    yy_push_state(sterge_punct_si_virgula);
}

<citeste_stare_initiala>[a-zA-Z][a-zA-Z0-9_]* {
    cout << yytext << endl;
    yy_pop_state();
    yy_push_state(sterge_punct_si_virgula);
}

<proceseaza_tranzitie>{
    , { ; }
    [a-z][a-zA-Z0-9_]* {
        if (variabile.find(yytext) != variabile.end()) {
            for (const auto& val : variabile[yytext]) {
                litere_tranzitie.push_back(val);
            }
        } else {
            litere_tranzitie.push_back(yytext);
        }
    }
    -> {
        yy_push_state(proceseaza_final_tranzitie);
    }
    "\)"{ws}*";" {
        yy_pop_state();
    }
}

<proceseaza_final_tranzitie>[a-zA-Z][a-zA-Z0-9_]* {
    for (auto& litera : litere_tranzitie) {
        tranzitii[stare_start].push_back({litera, yytext});
    }

    litere_tranzitie.clear();
    yy_pop_state();
    yy_push_state(sterge_punct_si_virgula);
}

<citeste_productii>{
    [a-zA-Z0-9_&]+ { ; }
    "|" {
        nr_productii++;
    }
    ";" {
        nr_productii++;
        yy_pop_state();
    }
}

%%

int main(int argc, char* argv[]) {
    if (argc != 2) {
        cout << "Utilizare: " << argv[0] << " <nume_fisier>" << endl;
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        cout << "Eroare la deschiderea " << argv[1] << endl;
        return 1;
    }

    yylex();
    fclose(yyin);
    return 0;
}