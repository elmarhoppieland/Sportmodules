# Importeer de random library
from random import *

# Open het bestand
keuzes = open("keuzes.txt", "a")

# Leeg het bestand
keuzes.truncate(0)

# Vraag om het aantal leerlingen, en sla dat op als n
aantal = int(input("Hoeveel leerlingen zijn er: "))

# Vraag om de populariteit van de sporten
pop_a = int(input("Wat is de populariteit van sport a: "))
pop_b = int(input("Wat is de populariteit van sport b: "))
pop_c = int(input("Wat is de populariteit van sport c: "))
pop_d = int(input("Wat is de populariteit van sport d: "))
pop_e = int(input("Wat is de populariteit van sport e: "))

# Maak een lijst met alle sporten
sporten = ["a", "b", "c", "d", "e"]

# Herhaal alle code dat naar rechts is het "aantal" keer
for n in range(aantal):

    n += 1
    
    # Maak de eerste keuze
    k_1 = str(choices(sporten, weights = [pop_a, pop_b, pop_c, pop_d, pop_e])).strip("[]'")

    # Maak de tweede keuze, die niet hetzelfde is als de eerste keuze
    k_2 = str(choices(sporten, weights = [pop_a, pop_b, pop_c, pop_d, pop_e])).strip("[]'")

    while k_1 == k_2:
        k_2 = str(choices(sporten, weights = [pop_a, pop_b, pop_c, pop_d, pop_e])).strip("[]'")

    # Maak de derde keuze, die niet hetzelfde is als de eerste en de tweede
    k_3 = str(choices(sporten, weights = [pop_a, pop_b, pop_c, pop_d, pop_e])).strip("[]'")

    while k_1 == k_3 or k_2 == k_3:
        k_3 = str(choices(sporten, weights = [pop_a, pop_b, pop_c, pop_d, pop_e])).strip("[]'")

    # Schrijf het getal, de 1e, 2e, en 3e keuze in het bestand.
    keuzes.write(str(n) + " " + k_1 + " " + k_2 + " " + k_3 + "\n")
    
# Stop met schrijven
keuzes.close()