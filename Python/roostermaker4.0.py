import copy


class Node():
    def __init__(self, indeling, score, sporten):
        self.indeling = indeling
        self.score = score
        self.sporten = sporten

class Dijkstrafrontier():
    def __init__(self):
        self.frontier = []
    
    def add(self, node):
        self.frontier.append(node)
    
    def remove(self):
        self.frontier.sort(key=lambda node: node.score - len(node.indeling))
        node = self.frontier[0]
        self.frontier = self.frontier[1:]
        return node

            
class Sport:
    def __init__(self, naam, max_cap, leerlingen):
        self.naam = naam
        self.max_cap = max_cap
        self.leerlingen = leerlingen
        
        
class Leerling:
    def __init__(self, naam, keuzes):
        self.naam = naam
        self.keuzes = keuzes


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
    return 0.3*(x+1)**2 + 2*(x+1) - 2.3
    
def print_resultaat(node):
    for n in range(len(node.indeling)):
        leerling = leerlingen[n]
        print(f"{leerling.naam} heeft de sport {node.indeling[n]}")
    quit()

    
# Lees de sporten en de leerlingen       
with open("/home/merlijn/Desktop/GitHub/Sportmodules/Python/keuzes.txt") as f:
    sporten = []
    leerlingen  = []
    sporten = list(f.readline().removeprefix("De sporten: ").removesuffix("\n").split(", "))
    n_keuzes = int(f.readline().removeprefix("Aantal keuzes: "))
    sporten_objects = []
    for sport in sporten:
        sport = Sport(sport, cap_req(sport, min=0), [])
        sporten_objects.append(sport)
    sporten = sporten_objects
    for regel in f:
        if regel != "\n":
            leerling = regel.split(", ")
            leerling = list(map(lambda s: s.strip(), leerling))
            leerling = Leerling(leerling[0], list(leerling[1:]))
            leerlingen.append(leerling)
        
# Check of er genoeg capaciteit is
tot_cap = 0
for sport in sporten:
    tot_cap += sport.max_cap
if tot_cap < len(leerlingen):
    print("Er is niet genoeg capaciteit...")
    quit()

# Geef de leerlingen met maar 1 keuze extra keuzes.
for leerling in leerlingen:
    if len(leerling.keuzes) < n_keuzes:
        for n in range(n_sporten):
            if sporten[n].naam not in leerling.keuzes:
                leerling.keuzes.append(sport.naam)
            if len(leerling.keuzes) == n_keuzes:
                break

start = Node([], 0, sporten)        
frontier = Dijkstrafrontier()
frontier.add(start)

while True:
    parent = frontier.remove()
    if len(parent.indeling) >= len(leerlingen):
        print_resultaat(parent)
    

    leerling = leerlingen[len(parent.indeling)]
    n = 0
    for sport in parent.sporten:
        
        if len(sport.leerlingen) >= sport.max_cap:
            continue
        
        child = copy.deepcopy(parent)
        child.indeling.append(sport.naam)
        child.sporten[n].leerlingen.append(leerling.naam)
        if sport.naam in leerling.keuzes:
            child.score += score_voor_n_keuze(leerling.keuzes.index(sport.naam))
        else:
            child.score += score_voor_n_keuze(n_keuzes)
        
        n += 1
        
        frontier.add(child)
