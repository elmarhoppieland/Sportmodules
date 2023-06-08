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

n_k_1 = 0
n_k_2 = 0
n_k_3 = 0
n_k_4 = 0

def deel_in():
    for leerling in leerlingen:
        if leerling.plek == None:
            if leerling.keuze_1 == "a" and max_a > len(a):
                a.append(leerling)
                leerling.plek = "a"
            elif leerling.keuze_1 == "b" and max_b > len(b):
                b.append(leerling)
                leerling.plek = "b"
            elif leerling.keuze_1 == "c" and max_c > len(c):
                c.append(leerling)
                leerling.plek = "c"
            elif leerling.keuze_1 == "d" and max_d > len(d):
                d.append(leerling)
                leerling.plek = "d"
            elif leerling.keuze_1 == "e" and max_e > len(e):
                e.append(leerling)
                leerling.plek = "e"

    for leerling in leerlingen:
        if leerling.plek == None:
            if leerling.keuze_2 == "a" and max_a > len(a):
                a.append(leerling)
                leerling.plek = "a"
            elif leerling.keuze_2 == "b" and max_b > len(b):
                b.append(leerling)
                leerling.plek = "b"
            elif leerling.keuze_2 == "c" and max_c > len(c):
                c.append(leerling)
                leerling.plek = "c"
            elif leerling.keuze_2 == "d" and max_d > len(d):
                d.append(leerling)
                leerling.plek = "d"
            elif leerling.keuze_2 == "e" and max_e > len(e):
                e.append(leerling)
                leerling.plek = "e"

    for leerling in leerlingen:
        if leerling.plek == None:
            if leerling.keuze_3 == "a" and max_a > len(a):
                a.append(leerling)
                leerling.plek = "a"
            elif leerling.keuze_3 == "b" and max_b > len(b):
                b.append(leerling)
                leerling.plek = "b"
            elif leerling.keuze_3 == "c" and max_c > len(c):
                c.append(leerling)
                leerling.plek = "c"
            elif leerling.keuze_3 == "d" and max_d > len(d):
                d.append(leerling)
                leerling.plek = "d"
            elif leerling.keuze_3 == "e" and max_e > len(e):
                e.append(leerling)
                leerling.plek = "e"

    for leerling in leerlingen:
        if leerling.plek == None:
            if max_a > len(a):
                a.append(leerling)
                leerling.plek = "a"
            elif max_b > len(b):
                b.append(leerling)
                leerling.plek = "b"
            elif max_c > len(c):
                c.append(leerling)
                leerling.plek = "c"
            elif max_d > len(d):
                d.append(leerling)
                leerling.plek = "d"
            elif max_e > len(e):
                e.append(leerling)
                leerling.plek = "e"

def print_leerlingen():
    print(f"De {len(a)} mensen die sport a doen zijn: ")
    for leerling in a:
        print(leerling.naam, end = " ")
    print("\n")
    print(f"De {len(b)} mensen die sport b doen zijn: ")
    for leerling in b:
        print(leerling.naam, end = " ")
    print("\n")
    print(f"De {len(c)} mensen die sport c doen zijn: ")
    for leerling in c:
        print(leerling.naam, end = " ")
    print("\n")
    print(f"De {len(d)} mensen die sport d doen zijn: ")
    for leerling in d:
        print(leerling.naam, end = " ")
    print("\n")
    print(f"De {len(e)} mensen die sport e doen zijn: ")
    for leerling in e:
        print(leerling.naam, end = " ")
    print("\n")
    score, n_k_1, n_k_2, n_k_3, n_k_4 = bereken_score()
    print(f"Dit rooster heeft een score van {score}\n")
    print(f"Aantal leerlingen met met 1ste keuze : {n_k_1}, 2e: {n_k_2}, 3e {n_k_3}, 4e: {n_k_4}\n")

def bereken_score():
    score = 0
    n_k_1 = 0
    n_k_2 = 0
    n_k_3 = 0
    n_k_4 = 0

    for leerling in leerlingen:
        score += leerling.bereken_score_leerling()
        if leerling.bereken_score_leerling() == 0:
            n_k_1 += 1
        elif leerling.bereken_score_leerling() == 1:
            n_k_2 += 1
        elif leerling.bereken_score_leerling() == 2:
            n_k_3 += 1
        else:
            n_k_4 += 1
    return score, n_k_1, n_k_2, n_k_3, n_k_4

def herschik():
    a.clear()
    b.clear()
    c.clear()
    d.clear()
    e.clear()
    for leerling in leerlingen:
        if leerling.plek == "a":
            a.append(leerling)
        elif  leerling.plek == "b":
            b.append(leerling)
        elif  leerling.plek == "c":
            c.append(leerling)
        elif  leerling.plek == "d":
            d.append(leerling)
        elif  leerling.plek == "e":
            e.append(leerling)

def optimaliseer():
    while True:
        basis_score = nieuwe_score = bereken_score()[0]
        for leerling_1 in leerlingen:
            for leerling_2 in leerlingen:
                plek_leerling_1 = leerling_1.plek
                leerling_1.plek = leerling_2.plek
                leerling_2.plek = plek_leerling_1
                if bereken_score()[0] < nieuwe_score:
                    nieuwe_score = bereken_score()[0]
                else:
                    plek_leerling_1 = leerling_1.plek
                    leerling_1.plek = leerling_2.plek
                    leerling_2.plek = plek_leerling_1
        if basis_score == nieuwe_score:
            break
global leerlingen

global a
global b
global c
global d
global e

global max_a
global max_b
global max_c
global max_d
global max_e

leerlingen = []
a = []
b = []
c = []
d = []
e = []

max_a = int(input("Wat is het max aantal deelnemers van sport a: "))
max_b = int(input("Wat is het max aantal deelnemers van sport b: "))
max_c = int(input("Wat is het max aantal deelnemers van sport c: "))
max_d = int(input("Wat is het max aantal deelnemers van sport d: "))
max_e = int(input("Wat is het max aantal deelnemers van sport e: "))

print("Keuzes.txt lezen...")

keuzes = open(r"keuzes.txt", 'r')

aantal_leerlingen = 0

for regel in keuzes:
    if regel != "\n":
        aantal_leerlingen += 1
    naam, keuze_1, keuze_2, keuze_3 = regel.split(" ")
    leerling = Leerling(naam, keuze_1, keuze_2, keuze_3)
    leerlingen.append(leerling)

tot_cap = max_a + max_b + max_c + max_d + max_e

if tot_cap < aantal_leerlingen:
    print("Er is niet genoeg capaciteit.")
    quit()

print("Berekenen...")
print("\n")

deel_in()

bereken_score()

print(f"De lijst voor de verbetering: \n")

print_leerlingen()

print("Optimaliseren...")

optimaliseer()

bereken_score()

herschik()

print("De nieuwe indeling:")
print_leerlingen()