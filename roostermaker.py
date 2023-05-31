def cap_req(naam, min=float('-inf'), max=float('inf')):
    while True:
        aantal = input(f"Wat is de max capaciteit van {naam}? ")
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

class Sport:
    def __init__(self, naam, max_cap, populariteit=0, leerlingen=[]):
        self.naam = naam
        self. max_cap = max_cap
        self.leerlingen = leerlingen
        self.populariteit = populariteit

class Leerling:
    def __init__(self, naam: int, keuze_1, keuze_2, keuze_3, plek=None):
        self.naam = naam
        self.keuze_1 = keuze_1
        self.keuze_2 = keuze_2
        self.keuze_3 = keuze_3
        self.plek = plek
    def bereken_score_leerling(self):
        if self.plek == self.keuze_1:
            return 0
        elif self.plek == self.keuze_2:
            return 1
        elif self.plek == self.keuze_3:
            return 2
        else:
            return 10

# Lees alle sporten
with open("keuzes.txt") as keuzes_bestand:
    remover = []
    sporten = list(keuzes_bestand.readline().removeprefix("De sporten: ").removesuffix(" \n").split(", "))
    for sport in sporten:
        max_cap = cap_req(naam=sport, min=1)
        sport_object = Sport(sport, max_cap)
        sporten.append(sport_object)
        remover.append(sport)
    sporten = list(set(sporten) - set(remover))
    

