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
visited = [False] * n

time = 0
queue = []
done = 0

# Add initial processes that arrived at or before time 0
for i in range(n):
    if at[i] <= time and not visited[i]:
        queue.append(i)
        visited[i] = True

while done < n:
    if not queue:
        # If queue is empty, jump CPU time to the next process arrival
        unvisited = [at[i] for i in range(n) if not visited[i]]
        if unvisited:
            time = min(unvisited)
        else:
            time += 1
        for i in range(n):
            if at[i] <= time and not visited[i]:
                queue.append(i)
                visited[i] = True
        continue

    i = queue.pop(0)

    # First CPU allocation records Response Time
    if res[i] == -1:
        res[i] = time - at[i]

    if rt[i] > q:
        time += q
        rt[i] -= q
    else:
        time += rt[i]
        rt[i] = 0
        ct[i] = time
        done += 1

    # Add any processes that arrived while P{i} was running
    for j in range(n):
        if at[j] <= time and not visited[j]:
            queue.append(j)
            visited[j] = True

    # If the process still has remaining time, push it back to the queue
    if rt[i] > 0:
        queue.append(i)

tat = [ct[i] - at[i] for i in range(n)]
wt = [tat[i] - bt[i] for i in range(n)]

print("\nProcess\tAT\tBT\tCT\tTAT\tWT\tRT")
for i in range(n):
    print(f"P{i+1}\t{at[i]}\t{bt[i]}\t{ct[i]}\t{tat[i]}\t{wt[i]}\t{res[i]}")

print("\nAverage Waiting Time =", sum(wt) / n)
print("Average Turnaround Time =", sum(tat) / n)
print("Average Response Time =", sum(res) / n)