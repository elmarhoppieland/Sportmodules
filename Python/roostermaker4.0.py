# state = leerling, parent = de vorige node, action = sport indeling, score = score
class Node():
    def __init__(self, state, parent, action, score, diepte):
        self.state = state
        self.parent = parent
        self.score = score
        self.score = score
        self.diepte = diepte
        

class Dijkstrafrontier():
    def __init__(self):
        self.frontier = []
    
    def add(self, node):
        self.frontier.append(node)
    
    def remove(self):
        if self.empty():
            raise Exception("empty frontier")
        else:
            frontier.sort(key=lambda node: node.score )
            node = frontier[0]
            frontier = frontier[1:]
            return node


class Leerling:
    def __init__(self, naam, keuzes):
        self.naam = naam
        self.keuzes = keuzes



# Lees de sporten en de leerlingen       
with open("keuzes.txt") as f:
    sporten = []
    leerlingen  = []
    sporten = list(f.readline().removeprefix("De sporten: ").removesuffix("\n").split(", "))
    next(f)
    for regel in f:
        if regel != "\n":
            leerling = regel.split(", ")
            leerling = list(map(lambda s: s.strip(), leerling))
            leerling = Leerling(leerling[0], list(leerling[1:]))
            leerlingen.append(leerling)
        


start = Node(state=None, parent=None, action=None, score=0, diepte=0)        
frontier = Dijkstrafrontier()
frontier.add(start)
explored = set()

