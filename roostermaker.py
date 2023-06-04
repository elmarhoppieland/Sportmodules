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

def score_voor_n_keuze(x):
    x = int(x)
    return 0.3*x**2 + 2*x - 2.3

class Sport:
    def __init__(self, naam, max_cap, populariteit=0.0, leerlingen=[]):
        self.naam = naam
        self.max_cap = max_cap
        self.leerlingen = leerlingen
        self.populariteit = populariteit


class Leerling:
    def __init__(self, naam: int, keuzes, plek=None):
        self.naam = naam
        self.keuzes = keuzes
        self.plek = plek


# Lees alle sporten
with open("keuzes.txt") as keuzes_bestand:
    sporten, n_keuzes = list(keuzes_bestand.readline().removeprefix("De sporten: ").removesuffix(" \n").split("; aantal keuzes: "))
    sporten = sporten.split(", ")
    n_sporten = len(sporten)
    remover = []
    n = 0
    for sport in sporten:
        if n == n_sporten:
            sporten = list(set(sporten) - set(remover))
            break
        max_cap = cap_req(naam=sport, min=1)
        sport_object = Sport(sport, max_cap)
        sporten.append(sport_object)
        remover.append(sport)
        n += 1

# Bereken de max capaciteit van alle sporten
tot_cap = 0
for sport in sporten:
    tot_cap += sport.max_cap

# Lees de leerlingen
with open("keuzes.txt") as keuzes_bestand:
    n_leerlingen = 0
    leerlingen = []
    next(keuzes_bestand)
    for regel in keuzes_bestand:
        if regel != "\n":
            n_leerlingen += 1
            leerling = regel.split(", ")
            leerling = list(map(lambda s: s.strip(), leerling))
            leerling = Leerling(leerling[0], list(leerling[1:]))
            leerlingen.append(leerling)


# Bereken de populariteit van alle sporten
max_score = score_voor_n_keuze(n_keuzes)
for sport in sporten:
    sport.populariteit = n_leerlingen * max_score
    for leerling in leerlingen:
        if sport.naam in leerling.keuzes:
            nste_keuze = leerling.keuzes.index(sport.naam)
            sport.populariteit -= abs(max_score - score_voor_n_keuze(nste_keuze))
    sport.populariteit = round(sport.populariteit, 1)
    print(f"Sport {sport.naam} heeft een populariteit van {sport.populariteit}")

sporten.sort(key=lambda sport: sport.populariteit, reverse=True)
