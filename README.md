# Identificarea unui Sistem Dinamic de Ordinul II prin Regresie Liniara

## Descrierea Proiectului
Acest repository prezinta o solutie de modelare si identificare a unui sistem dinamic de ordinul II cu poli reali (regim aperiodic amortizat). Scopul proiectului este deducerea analitica a modelului matematic (functia de transfer si reprezentarea in spatiul starilor) folosind exclusiv seturi de date de intrare-iesire obtinute in urma aplicarii unui semnal de tip treapta. 

Abordarea folosita evita functiile predefinite de tip "black-box" in favoarea unei implementari matematice explicite, bazate pe liniarizare si regresie liniara.

## Metodologia de Identificare
Modelul matematic a fost structurat pe baza a trei parametri fundamentali care caracterizeaza dinamica sistemului, extrasi dintr-un singur experiment continuu:

1. **Factorul de proportionalitate (K):** A fost determinat analizand comportamentul sistemului in regim stationar. S-a calculat raportul dintre variatia semnalului de iesire si cel de intrare, valorile fiind mediate pentru a anula efectul zgomotului de masurare indus de convertoarele ADC/DAC.

2. **Constanta de timp dominanta (T1):** A fost extrasa prin aplicarea logaritmului natural pe datele corespunzatoare regimului tranzitoriu. Panta dreptei obtinute in zona liniarizata a fost determinata folosind metoda celor mai mici patrate (regresie liniara), iar valoarea lui T1 a fost dedusa analitic din aceasta.

3. **Constanta de timp nedominanta (T2):** A fost calculata prin estimarea momentului de timp la care apare punctul de inflexiune pe graficul raspunsului indicial. Utilizand acest reper temporal, valoarea lui T2 a fost extrasa prin rezolvarea numerica/grafica a ecuatiei transcendente specifice raspunsului sistemului.

## Validarea Modelului
Pentru a garanta acuratetea modelului identificat fata de procesul fizic real, validarea s-a realizat in doua moduri distincte:
* **Functia de Transfer:** Simulare ideala, plecand de la conditii initiale nule.
* **Spatiul Starilor (State-Space):** Simulare realista, configurata cu conditiile initiale nenule prezente fizic in sistem la momentul aplicarii treptei de test.

Performanta modelului este evaluata folosind eroarea medie patratica normalizata (eMPN). In urma calibrarii, suprapunerea raspunsului simulat peste datele brute atinge o eroare eMPN de sub 10%, confirmand robustetea identificarii.

## Structura si Rulare
* `system_identification.m` - Scriptul principal de MATLAB care gestioneaza setul de date, executa algoritmul de regresie si calculeaza parametrii sistemului.
* `dynamic_system.slx` - Modelul procesului fizic din Simulink folosit pentru achizitia datelor.

**Instructiuni de utilizare:**
Pentru a rula algoritmul, deschideti fisierul `system_identification.m` in MATLAB si executati scriptul. Acesta va apela automat modelul Simulink in fundal pentru a genera setul de date si va afisa graficele comparative de validare.
