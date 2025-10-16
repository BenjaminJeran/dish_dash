
# 1.1 Testni primer TC-01 – Prijava uporabnika

| ID Testa        | TC-01                                                                                           |
| :-------------- | :---------------------------------------------------------------------------------------------- |
| **Naziv testa** | Prijava uporabnika z veljavnimi podatki                                                         |
| **Namen**       | Preverjanje ali sistem omogoča uspešno prijavo registriranemu uporabniku.                       |
| Predpogoji      | Uporabniški račun obstaja (ime: benjamin, geslo: test123!)<br>Nahajamo se na zaslonu za prijavo |

## Koraki izvedbe in pričakovani rezultati 

| Korak izvedbe                     | Pričakovani rezultat                                              |
| :-------------------------------- | :---------------------------------------------------------------- |
| 1. Vnesi e-poštni naslov in geslo | Vpisano uporabniško ime in geslo. Geslo je prikazano le s pikami. |
| 2. Pritisni na gumb prijava       | Prikaz začetne strani                                             |

## Pričakovani rezultat 

* Pričakujem, da ob uspešni prijavi z ustreznimi podatki, sistem prikaže začetno stran aplikacije.

---

# 1.2 Testni primer TC-02 – Ustvarjanje novega recepta

| ID Testa        | TC-01                                                                                           |
| :-------------- | :---------------------------------------------------------------------------------------------- |
| **Naziv testa** | Ustvarjanje novega recepta                                                                      |
| **Namen**       | Preveriti, če sistem pravilno shrani recept in ga prikaže za nadaljnjo uporabo                  |
| Predpogoji      | Uporabnik je uspešno prijavljen v aplikacijo<br>Nahajamo se na zaslonu za raziskovanje receptov |

## Koraki izvedbe in pričakovani rezultati 

| Korak izvedbe              | Pričakovani rezultat                                   |
| :------------------------- | :----------------------------------------------------- |
| 1. Klik na FAB +           | Prikaže se nam vnosna forma za vnos recepta            |
| 2.. Izpolnjevanje forme    | Izpolnjena forma                                       |
| 3.  Klik na dodaj sliko    | Odpre se možnost izbire slike iz galerija ali kamere   |
| 4. Izbira Kamera           | Odpre se fotoaparat                                    |
| 5. Nareditev fotografije   | Fotografija se shrani v formo                          |
| 6. Klik na dodaj recept    | Prikaže se zaslon za raziskovanje receptov             |
| 7. Klik na zavihek recepti | Prikaže se zavihek z recepti ter na novo dodan recept. |
| 8. Klik na recept          | Prikaže se  stran s podrobnosti recepta                |

## Pričakovani rezultat 

- Pričakujem, da je nov recept z vsemi vnešenimi podatki in sliko, posneto s kamero, **uspešno shranjen** v podatkovni bazi aplikacije.
- Po shranjevanju je uporabnik preusmerjen na glavni zaslon.
- Recept je viden in dostopen na zavihku **Recepti / Moji Recepti**.

---

# 1.3 Testni primer TC-03 – Všečkanje recepta

| ID Testa        | TC-01                                                                                                                              |
| :-------------- | :--------------------------------------------------------------------------------------------------------------------------------- |
| **Naziv testa** | Všečkanje recepta                                                                                                                  |
| **Namen**       | Preveriti, če sistem uspešno zabeleži všeček                                                                                       |
| Predpogoji      | Uporabnik je uspešno prijavljen v aplikacijo<br>Nahajamo se na zaslonu za raziskovanje receptov<br>V aplikaciji so vnešeni recepti |

## Koraki izvedbe in pričakovani rezultati 

| Korak izvedbe                    | Pričakovani rezultat                                                                              |
| :------------------------------- | :------------------------------------------------------------------------------------------------ |
| 1.  Kliknemo na izbrani recept   | Prikažejo se nam podrobnosti recepta                                                              |
| 2..  Klik na ikono srca          | Ikona se pobarva na rdeče (recept je bil všečlkan)<br>Count št. všečkov se poveča na receptu za 1 |
| 3. Klik na gumb za nazaj         | Preusmerjeni smo na stran za raziskovanje                                                         |
| 4. Klik na zavihek Recepti       | Preusmerjen smo na stran z recepti                                                                |
| 5. Izberemo tab Všečkani recepti | Prikazan je recept, ki smo ga všečkali                                                            |

## Pričakovani rezultat 
- **Ikona srca** ostane **rdeča/oblikovana** po kliku, kar potrjuje, da je uporabnik uspešno všečkal recept.
- **Števec všečkov** na tem receptu se **poveča za eno enoto** in ta sprememba se trajno shrani v podatkovni bazi (preverba ob osvežitvi strani).
- **Najpomembnejše:** Recept, ki smo ga všečkali, je **uspešno prikazan na seznamu** na zavihku **Všečkani recepti**, kar potrjuje trajnost shranjevanja in pravilno delovanje filtriranja.

---

# 1.4 Testni primer TC-03  Dodajanje sestavin iz recepta v nakupovalno košarico

| ID Testa        | TC-03                                                                                                                                  |
| :-------------- | :------------------------------------------------------------------------------------------------------------------------------------- |
| **Naziv testa** | Dodajanje sestavin iz recepta v nakupovalno košarico                                                                                   |
| **Namen**       | Preveriti, če se nakupovalna košarica pravilno napolni iz sestavin iz recepta                                                          |
| Predpogoji      | Uporabnik je uspešno prijavljen v aplikacijo<br>Nahajamo se na podrobnem pogledo dočenenega recepta<br>V aplikaciji so vnešeni recepti |

## Koraki izvedbe in pričakovani rezultati 

| Korak izvedbe                                 | Pričakovani rezultat                                                                                                     |
| :-------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------- |
| 1.  Kliknemo na izbrani recept                | Prikažejo se nam podrobnosti recepta                                                                                     |
| 2..  Kliknemo na "Dodaj v nakupovalni seznam" | Pojavita se dva obvestila: <br>- "Dodajanje sestavin v nakupovalni seznam"<br>- "Sestavine so bile dodane v nakupovalni" |
| 3. Klik na gumb za nazaj                      | Preusmerjeni smo na stran za raziskovanje                                                                                |
| 4. Klik na hamburger meni                     | Odpre se nam meni                                                                                                        |
| 5. Kliknemo na "Nakupovalni seznam"           | Odpre se nam zaslon nakupovalnega seznama, lkjer so prikazane sestavine, ki jih moramo kupiti!                           |
|                                               |                                                                                                                          |

## Pričakovani rezultat 
- Na tem zaslonu **morajo biti prikazane vse sestavine** iz recepta, ki so bile dodane v koraku 2, kar potrjuje, da se je nakupovalni seznam pravilno napolnil iz recepta.

---




# 1.5 Testni primer TC-05 - Izbris lastnega recepta 

| ID Testa        | TC-05                                                                                                                                                      |
| :-------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Naziv testa** | Izbris lastnega recepta                                                                                                                                    |
| **Namen**       | Preveriti, če je recept pravilno izbrisan iz aplikacije                                                                                                    |
| Predpogoji      | Uporabnik je uspešno prijavljen v aplikacijo<br>Nahajamo se na zavihku "Recepti" -> Tab "Moji Recepti"<br>Uporabnik ima v aplikacijo vnešene svoje recepte |

## Koraki izvedbe in pričakovani rezultati 

| Korak izvedbe                              | Pričakovani rezultat                                                             |
| :----------------------------------------- | :------------------------------------------------------------------------------- |
| 1.  Izbrani recept povlečemo v levo        | Pod receptom se prikaže ikona za smeti                                           |
| 2.  Spustimo recept, ko je povlečen v levo | Pojavi se modalno okno za potrjevanje izbrisa                                    |
| 3. Kliknemo na "Izbriši"                   | Modalno okno se zapre<br>Prikaže se obvestilo, da je bil recept uspešno izbrisan |

## Pričakovani rezultat 
- Na tem zaslonu mora biti recept pravilno izbrisan, prikazati se more obvestilo o izbrisu. 

---

| Funkcionalnost / Testni primer              | TC-01 (Prijava) | TC-02 (Ustvarjanje recepta) | TC-03 (Všečkanje recepta) | TC-04 (Dodajanje v nakupovalni seznam) | TC-05 (Izbris recepta) |
| :------------------------------------------ | :-------------- | :-------------------------- | :------------------------ | :------------------------------------- | :--------------------- |
| **Prijava uporabnika**                      | X               |                             |                           |                                        |                        |
| **Ustvarjanje novega recepta**              |                 | X                           |                           |                                        |                        |
| **Pregled vseh receptov**                   |                 | X                           |                           |                                        |                        |
| **Pregled podrobnega recepta**              |                 | X                           | X                         | X                                      |                        |
| **Všečkanje/Shranjevanje recepta**          |                 |                             | X                         |                                        |                        |
| **Dodajanje sestavin v nakupovalni seznam** |                 |                             |                           | X                                      |                        |
| **Pregled nakupovalnega seznama**           |                 |                             |                           | X                                      |                        |
| **Brisanje recepta**                        |                 |                             |                           |                                        | X                      |
