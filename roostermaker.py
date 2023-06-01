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
    sporten = list(keuzes_bestand.readline().removeprefix("De sporten: ").removesuffix(" \n").split(", "))
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


if n_leerlingen > tot_cap:
    print(f"Er zijn {n_leerlingen} leerlingen, en een totale capaciteit van {tot_cap}, dus dit werkt niet :(")
else:
    for leerling in leerlingen:
        print(f"{leerling.naam} heeft de keuzes: {leerling.keuzes}")
