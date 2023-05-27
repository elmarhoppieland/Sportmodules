# Vraag om het max per sport
max_a = int(input("Wat is het max aantal deelnemers van sport a: "))
max_b = int(input("Wat is het max aantal deelnemers van sport b: "))
max_c = int(input("Wat is het max aantal deelnemers van sport c: "))
max_d = int(input("Wat is het max aantal deelnemers van sport d: "))
max_e = int(input("Wat is het max aantal deelnemers van sport e: "))

tot_cap = max_a + max_b + max_c + max_d + max_e

fp.close()

if tot_cap < aantal_leerlingen:
    print("Er is niet genoeg capaciteit.")
    quit()

print("Berekenen...")
print()
print()
a = []
b = []
c = []
d = []
e = []

# Bereken de populariteit van elke sport
pop_a = 4 * aantal_leerlingen
pop_b = 4 * aantal_leerlingen
pop_c = 4 * aantal_leerlingen
pop_d = 4 * aantal_leerlingen
pop_e = 4 * aantal_leerlingen

a_k_1 = []
b_k_1 = []
c_k_1 = []
d_k_1 = []
e_k_1 = []

a_k_2 = []
b_k_2 = []
c_k_2 = []
d_k_2 = []
e_k_2 = []

a_k_3 = []
b_k_3 = []
c_k_3 = []
d_k_3 = []
e_k_3 = []

keuzes = open(r"keuzes.txt", "r")
for line in keuzes:
    leerling, k_1, k_2, k_3 = line.split(" ")
    if k_1 == "a":
        pop_a -= 4
        a_k_1.append(leerling)
    elif k_1 == "b":
        pop_b -= 4
        b_k_1.append(leerling)
    elif k_1 == "c":
        pop_c -= 4
        c_k_1.append(leerling)
    elif k_1 == "d":
        pop_d -= 4
        d_k_1.append(leerling)
    elif k_1 == "e":
        pop_e -= 4
        e_k_1.append(leerling)
    
    if k_2 == "a":
        pop_a -= 2
        a_k_2.append(leerling)
    elif k_2 == "b":
        pop_b -= 2
        b_k_2.append(leerling)
    elif k_2 == "c":
        pop_c -= 2
        c_k_2.append(leerling)
    elif k_2 == "d":
        pop_d -= 2
        d_k_2.append(leerling)
    elif k_2 == "e":
        pop_e -= 2
        e_k_2.append(leerling)

    if k_3 == "a":
        pop_a -= 1
        a_k_3.append(leerling)
    elif k_3 == "b":
        pop_b -= 1
        b_k_3.append(leerling)
    elif k_3 == "c":
        pop_c -= 1
        c_k_3.append(leerling)
    elif k_3 == "d":
        pop_d -= 1
        d_k_3.append(leerling)
    elif k_3 == "e":
        pop_e -= 1
        e_k_3.append(leerling)

if max_a >= len(a_k_1):
    for l in a_k_1:
        a.append(l)
else:
    n = 0
    while len(a) < max_a:
        a.append(a_k_1[n])
        n += 1
a_k_1 = list(set(a_k_1) - set(a))

if max_b >= len(b_k_1):
    for l in b_k_1:
        b.append(l)
else:
    n = 0
    while len(b) < max_b:
        b.append(b_k_1[n])
        n += 1
b_k_1 = list(set(b_k_1) - set(b))

if max_a >= len(c_k_1):
    for l in c_k_1:
        c.append(l)
else:
    n = 0
    while len(c) < max_c:
        c.append(c_k_1[n])
        n += 1
c_k_1 = list(set(c_k_1) - set(c))

if max_d >= len(d_k_1):
    for l in d_k_1:
        d.append(l)
else:
    n = 0
    while len(d) < max_d:
        d.append(d_k_1[n])
        n += 1
d_k_1 = list(set(d_k_1) - set(d))

if max_e >= len(e_k_1):
    for l in e_k_1:
        e.append(l)
else:
    n = 0
    while len(e) < max_e:
        e.append(e_k_1[n])
        n += 1
e_k_1 = list(set(e_k_1) - set(e))

print(f" a: {a} b: {b} c: {c} d: {d} e: {e} ")

if len(a_k_1) > 0:
    for leerling in a_k_1:
        if any(leerling in b_k_2 for leerling in b_k_2):
            if max_b > len(b):
                b.append(leerling)
                a_k_1 = list(set(a_k_1) - set(b))
        if any(leerling in c_k_2 for leerling in c_k_2):
            if max_c > len(c):
                c.append(leerling)
                a_k_1 = list(set(a_k_1) - set(c))
        if any(leerling in d_k_2 for leerling in d_k_2):
            if max_d > len(d):
                d.append(leerling)
                a_k_1 = list(set(a_k_1) - set(d))
        if any(leerling in e_k_2 for leerling in e_k_2):
            if max_e > len(e):
                e.append(leerling)
                a_k_1 = list(set(a_k_1) - set(e))


if len(b_k_1)  > 0:
    for leerling in b_k_1:
        if any(leerling in a_k_2 for leerling in a_k_2):
            if max_a > len(a):
                a.append(leerling)
                b_k_1 = list(set(b_k_1) - set(a))
        if any(leerling in c_k_2 for leerling in c_k_2):
            if max_c > len(c):
                c.append(leerling)
                b_k_1 = list(set(b_k_1) - set(c))
        if any(leerling in d_k_2 for leerling in d_k_2):
            if max_d > len(d):
                d.append(leerling)
                b_k_1 = list(set(b_k_1) - set(d))
        if any(leerling in e_k_2 for leerling in e_k_2):
            if max_e > len(e):
                e.append(leerling)
                b_k_1 = list(set(b_k_1) - set(e))

if len(c_k_1) > 0:
    for leerling in c_k_1:
        if any(leerling in a_k_2 for leerling in a_k_2):
            if max_a > len(a):
                a.append(leerling)
                c_k_1 = list(set(c_k_1) - set(a))
        if any(leerling in b_k_2 for leerling in b_k_2):
            if max_b > len(b):
                b.append(leerling)
                c_k_1 = list(set(c_k_1) - set(b))
        if any(leerling in d_k_2 for leerling in d_k_2):
            if max_d > len(d):
                d.append(leerling)
                c_k_1 = list(set(c_k_1) - set(d))
        if any(leerling in e_k_2 for leerling in e_k_2):
            if max_e > len(e):
                e.append(leerling)
                c_k_1 = list(set(c_k_1) - set(e))

if len(d_k_1) > 0:
    for leerling in d_k_1:
        if any(leerling in a_k_2 for leerling in a_k_2):
            if max_a > len(a):
                a.append(leerling)
                d_k_1 = list(set(d_k_1) - set(a))
        if any(leerling in b_k_2 for leerling in b_k_2):
            if max_b > len(b):
                b.append(leerling)
                d_k_1 = list(set(d_k_1) - set(b))
        if any(leerling in c_k_2 for leerling in c_k_2):
            if max_c > len(c):
                c.append(leerling)
                d_k_1 = list(set(d_k_1) - set(c))
        if any(leerling in e_k_2 for leerling in e_k_2):
            if max_e > len(e):
                e.append(leerling)
                d_k_1 = list(set(d_k_1) - set(e))

if len(e_k_1) > 0:
    for leerling in e_k_1:
        if any(leerling in a_k_2 for leerling in a_k_2):
            if max_a > len(a):
                a.append(leerling)
                e_k_1 = list(set(e_k_1) - set(a))
        if any(leerling in b_k_2 for leerling in b_k_2):
            if max_b > len(b):
                b.append(leerling)
                e_k_1 = list(set(e_k_1) - set(b))
        if any(leerling in c_k_2 for leerling in c_k_2):
            if max_c > len(c):
                c.append(leerling)
                e_k_1 = list(set(e_k_1) - set(c))
        if any(leerling in d_k_2 for leerling in d_k_2):
            if max_d > len(d):
                d.append(leerling)
                e_k_1 = list(set(e_k_1) - set(d))
if len(a_k_1) > 0:
    for leerling in a_k_1:
        if any(leerling in b_k_3 for leerling in b_k_3):
            if max_b > len(b):
                b.append(leerling)
                a_k_1 = list(set(a_k_1) - set(b))
        if any(leerling in c_k_3 for leerling in c_k_3):
            if max_c > len(c):
                c.append(leerling)
                a_k_1 = list(set(a_k_1) - set(c))
        if any(leerling in d_k_3 for leerling in d_k_3):
            if max_d > len(d):
                d.append(leerling)
                a_k_1 = list(set(a_k_1) - set(d))
        if any(leerling in e_k_3 for leerling in e_k_3):
            if max_e > len(e):
                e.append(leerling)
                a_k_1 = list(set(a_k_1) - set(e))


if len(b_k_1) > 0:
    for leerling in b_k_1:
        if any(leerling in a_k_3 for leerling in a_k_3):
            if max_a > len(a):
                a.append(leerling)
                b_k_1 = list(set(b_k_1) - set(a))
        if any(leerling in c_k_3 for leerling in c_k_3):
            if max_c > len(c):
                c.append(leerling)
                b_k_1 = list(set(b_k_1) - set(c))
        if any(leerling in d_k_3 for leerling in d_k_3):
            if max_d > len(d):
                d.append(leerling)
                b_k_1 = list(set(b_k_1) - set(d))
        if any(leerling in e_k_3 for leerling in e_k_3):
            if max_e > len(e):
                e.append(leerling)
                b_k_1 = list(set(b_k_1) - set(e))

if len(c_k_1) > 0:
    for leerling in c_k_1:
        if any(leerling in a_k_3 for leerling in a_k_3):
            if max_a > len(a):
                a.append(leerling)
                c_k_1 = list(set(c_k_1) - set(a))
        if any(leerling in b_k_3 for leerling in b_k_3):
            if max_b > len(b):
                b.append(leerling)
                c_k_1 = list(set(c_k_1) - set(b))
        if any(leerling in d_k_3 for leerling in d_k_3):
            if max_d > len(d):
                d.append(leerling)
                c_k_1 = list(set(c_k_1) - set(d))
        if any(leerling in e_k_3 for leerling in e_k_3):
            if max_e > len(e):
                e.append(leerling)
                c_k_1 = list(set(c_k_1) - set(e))

if len(d_k_1) > 0:
    for leerling in d_k_1:
        if any(leerling in a_k_3 for leerling in a_k_3):
            if max_a > len(a):
                a.append(leerling)
                d_k_1 = list(set(d_k_1) - set(a))
        if any(leerling in b_k_3 for leerling in b_k_3):
            if max_b > len(b):
                b.append(leerling)
                d_k_1 = list(set(d_k_1) - set(b))
        if any(leerling in c_k_3 for leerling in c_k_3):
            if max_c > len(c):
                c.append(leerling)
                d_k_1 = list(set(d_k_1) - set(c))
        if any(leerling in e_k_3 for leerling in e_k_3):
            if max_e > len(e):
                e.append(leerling)
                d_k_1 = list(set(d_k_1) - set(e))

if len(e_k_1) > 0:
    for leerling in e_k_1:
        if any(leerling in a_k_3 for leerling in a_k_3):
            if max_a > len(a):
                a.append(leerling)
                e_k_1 = list(set(e_k_1) - set(a))
        if any(leerling in b_k_3 for leerling in b_k_3):
            if max_b > len(b):
                b.append(leerling)
                e_k_1 = list(set(e_k_1) - set(b))
        if any(leerling in c_k_3 for leerling in c_k_3):
            if max_c > len(c):
                c.append(leerling)
                e_k_1 = list(set(e_k_1) - set(c))
        if any(leerling in d_k_3 for leerling in d_k_3):
            if max_d > len(d):
                d.append(leerling)
                e_k_1 = list(set(e_k_1) - set(d))

for leerling in [a_k_1, b_k_1, c_k_1, d_k_1, e_k_1]:
    if max_a > len(a):
        a.append(leerling)
    elif max_b > len(b):
        b.append(leerling)
    elif max_c > len(c):
        c.append(leerling)
    elif max_b > len(d):
        d.append(leerling)
    elif max_e > len(e):
        e.append(leerling)

print("De mensen die sport a doen zijn: ")
print(*a, sep = ", ") 
print()
print("De mensen die sport b doen zijn: ")
print(*b, sep = ", ") 
print()
print("De mensen die sport c doen zijn: ")
print(*c, sep = ", ") 
print()
print("De mensen die sport d doen zijn: ")
print(*d, sep = ", ") 
print()
print("De mensen die sport e doen zijn: ")
print(*e, sep = ", ") 
