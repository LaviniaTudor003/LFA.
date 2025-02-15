Acesta tema implementează o aplicație care analizează definițiile automatelor finite și ale gramaticilor formale, preluate dintr-un fișier dat.
Programul procesează informațiile și afișează, în mod structurat, caracteristicile esențiale ale fiecărui element identificat.

- Principala provocare a fost manipularea starilor pentru a gestiona corect diferitele sectiuni ale inputului.
  Am rezolvat acest lucru folosind o stiva de stari (yy_push_state si yy_pop_state) care imi permite sa procesez secvential fiecare componenta, fara a utiliza functii suplimentare de procesare
  a string-urilor.

- Un aspect important al implementarii este modularitatea, deoarece fiecare componenta este tratata independent, cu stari si logica dedicate, permitand o intretinere si extindere usoara a codului.
  Ce m-a pus cel mai mult pe ganduri a fost mentinerea corecta a stivei din FLEX pentru a face conditiile de start reutilizabile.

- O alta provocare a fost gestionarea corecta a variabilelor complexe, in special in cazul tranzitiilor.
  Am rezolvat acest aspect prin expandarea domeniului variabilelor in momentul procesarii tranzitiilor, asigurand astfel o implementare robusta si flexibila.

In rest tema mi s-a parut destul de intuitiva. Am facut reguli pentru cazurile specifice starilor in care ma aflu, precum citirea unui alfabet sau a tranzitiilor, unde scriam in stdout ce se cerea si/sau treceam in alte stari.
