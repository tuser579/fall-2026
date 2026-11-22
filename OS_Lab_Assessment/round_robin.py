
n = int(input("Enter number of processes: "))

at = []
bt = []

for i in range(n):
    a = int(input(f"Enter arrival time of P{i+1}: "))
    b = int(input(f"Enter burst time of P{i+1}: "))
    at.append(a)
    bt.append(b)

q = int(input("Enter CPU time quantum: "))

rt = bt.copy()
ct = [0] * n
res = [-1] * n

time = 0
queue = []
done = 0

while done < n:

    for i in range(n):
        if at[i] <= time and rt[i] > 0 and i not in queue:
            if res[i] == -1:
                queue.append(i)

    if not queue:
        time = time + 1
        continue

    i = queue.pop(0)

    if res[i] == -1:
        res[i] = time - at[i]

    if rt[i] > q:
        time = time + q
        rt[i] = rt[i] - q
    else:
        time = time + rt[i]
        rt[i] = 0
        ct[i] = time
        done = done + 1

tat = [0] * n
wt = [0] * n

for i in range(n):
    tat[i] = ct[i] - at[i]
    wt[i] = tat[i] - bt[i]

print("\nProcess\tAT\tBT\tCT\tTAT\tWT\tRT")

for i in range(n):
    print(f"P{i+1}\t{at[i]}\t{bt[i]}\t{ct[i]}\t{tat[i]}\t{wt[i]}\t{res[i]}")

print("\nAverage Waiting Time =", sum(wt) / n)
print("Average Turnaround Time =", sum(tat) / n)
print("Average Response Time =", sum(res) / n)