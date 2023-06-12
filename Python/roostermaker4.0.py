# state = totale indeling
class Node():
    def __init__(self, state=list):
        self.state = state
            

class Dijkstrafrontier():
    def __init__(self):
        self.frontier = []
    
    def add(self, node):
        self.frontier.append(node)
    
    def remove(self):
        self.frontier.sort(key=lambda node: node.state[0])
        node = self.frontier[0]
        self.frontier = self.frontier[1:]
        return node

            
class Sport:
    def __init__(self, naam, max_cap, leerlingen=[]):
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
    print(node.state)
    quit()

# Lees de sporten en de leerlingen       
with open("/home/merlijn/Desktop/GitHub/Sportmodules/Python/keuzes.txt") as f:
    sporten = []
    leerlingen  = []
    sporten = list(f.readline().removeprefix("De sporten: ").removesuffix("\n").split(", "))
    n_keuzes = int(f.readline().removeprefix("Aantal keuzes: "))
    sporten_objects = []
    for sport in sporten:
        sport = Sport(sport, cap_req(sport, min=0))
        sporten_objects.append(sport)
    sporten = sporten_objects
    for regel in f:
        if regel != "\n":
            leerling = regel.split(", ")
            leerling = list(map(lambda s: s.strip(), leerling))
            leerling = Leerling(leerling[0], list(leerling[1:]))
            leerlingen.append(leerling)
        

start = Node(list([0]))        
frontier = Dijkstrafrontier()
frontier.add(start)

while True:
    parent = frontier.remove()
    if len(parent.state) == len(leerlingen) + 1:
        print_resultaat(parent)
        
    diepte = len(parent.state) - 1
    leerling = leerlingen[diepte]
    for sport in sporten:
        if len(parent.state) - 1 >= sport.max_cap:
            continue
        
        child = Node(parent.state.append(sport.naam))
        
        if sport.naam in leerling.keuzes:
            child.state[0] += score_voor_n_keuze(leerling.keuzes.index(sport.naam))
        else:
            child.state[0] += score_voor_n_keuze(n_keuzes + 1)
        frontier.add(child)
