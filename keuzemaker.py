# Importeer de random library
from random import *


# Definieer een functie die vraagt om een naam en een geheel getal met een optioneel minimum en maximum
def int_input(naam, min=float('-inf'), max=float('inf')):
    while True:
        aantal = input(f"Hoeveel verschillende {naam} zijn er? ")
        try:
            aantal = int(aantal)
            if aantal < min:
                print(f"Voer een getal groter/gelijk aan {min} in.")
                print("")
                continue
            elif aantal > max:
                print(f"Voer een getal kleiner/gelijk aan {max} in.")
                print("")
                continue
            break
        except ValueError:
            print(f"Voer een geheel getal in dat groter/gelijk aan {min} is en kleiner/gelijk aan {max} is.")
            print("")
    return aantal

# Vraagt de gebruiker om het aantal sporten, het aantal keuzes, en het aantal leerlingen
aantal_sporten = int_input("sporten", min=1)
aantal_keuzes = int_input("keuzes", max=aantal_sporten)
aantal_leerlingen = int_input("leerlingen", min=1)

# Definieer de lijsten "sporten" en "gewichten"
sporten = []
gewichten = []

# Vraag per sport om de naam en de populariteit
for n in range(aantal_sporten):
    n += 1
    while True:
        sport= str(input(f"Hoe heet sport nummer {n}? "))
        if ", " in sport:
            print(f"de naam mag niet \", \" (met een spatie) bevatten.")
        elif sport in sporten:
            print(f"Er is al een sport die \"{sport}\" heet, probeer het nog een keer.")
        else:
            sporten.append(sport)
            break
    while True:
        try:
            populariteit = float((input(f"Wat is de populariteit van {sporten[n-1]}? ")))
            if populariteit <= 0:
                print("Voer een getal in groter dan 0.")
                continue
            gewichten.append(populariteit)
            break
        except:
            print("Voer een getal in groter dan 0.")
            continue

# Open het bestand
keuze_lijst = open("keuzes.txt", "a")

# Leeg het bestand
keuze_lijst.truncate(0)

# Schrijf alle sporten op
vertaling_tabel = str.maketrans("", "", "[]'")
sporten_txt = str(sporten).translate(vertaling_tabel)
keuze_lijst.write(f"De sporten: {sporten_txt}; aantal keuzes: {aantal_keuzes} \n" )

# Maak en schrijf de keuzes in het bestand
for n in range(aantal_leerlingen):
    n += 1
    keuzes_leerling = []

    while len(keuzes_leerling) < aantal_keuzes:
        keuze = choices(sporten, gewichten)
        if keuze not in keuzes_leerling:
            keuzes_leerling.append(keuze)

    keuzes_string = str(keuzes_leerling).translate(vertaling_tabel)
    keuze_lijst.write(str(n) + ", " + keuzes_string + "\n")