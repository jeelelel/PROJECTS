"""
Jessica Lim
31954081

FIT2004 ASSIGNMENT 3
"""

def best_revenue(revenue, travel_days,start):
    """
    This function to decide when it is better to sell on the city you
    are located in and when it is better to move to another city. 
    Written by Jessica Lim - 31954081

    Precondition: Empty list of profits, but there hasn't been found any relation between revenue-travel_days in new list. Still empty list
    Postcondition: The first row contained the best profits for each start 

    Input:
    - revenue : is a list of lists. All interior lists are length n. Each
    interior list represents a different day. revenue[z][x] is the revenue that you would make if
    you work in city x on day z.
    - travel_days :travel_days[x][y]
    will contain either:
        • A positive integer number indicating the number of days you need to spend to travel on
        the direct road from city x to city y.
        • -1, to indicate that there is no direct road for you to travel from city x to city y.
    - start :denote the city you start in on day 0.
        
    Return: maximum possible revenue
        
    Time complexity: 
        N is the length of travel days / revenue (more into travel_days because of the cities)
        Best:  O(N**2(d+N))
        Worst: O(N**2(d+N))
    Space complexity: 
        Input: O(N**2), the nested list
        Aux: O(N**2), the nested loops (?)
    
    """
    #make this into variable for easier read
    cities_len= len(revenue[0])
    days_len = len(revenue)
    
    #what if the start city not in the city list
    if (start > cities_len):
        return "Invalid Start"
    
    #what if there is only one cities so only one way
    if (cities_len == 1):
        return sum(revenue[i][0] for i in range(days_len))
    #the normal way
    else:
        #create empty list of revenue/ profits
        profits = [[0 for i in range(cities_len)] for j in range(days_len)]
        
        # O (N)
        # Bottom of profits = bottom of revenues
        for i in range(cities_len):
            profits[days_len - 1][i] = revenue[days_len - 1][i]
        #print(profits)
            
        # O((N^2)d)
        # We do the dynamic programming inspired by the DP Maze
        i = days_len - 2
        while (i >= 0):
            #iterate through the city
            for j in range(cities_len):
                max_count = revenue[i][j] + profits[i + 1][j]
                moves = 0
                #to check the needed days or if can go to that city
                for k in range(cities_len):
                    days_needed = travel_days[j][k]
                    #check by days needed whether can or not then do the math
                    if ((i + days_needed) < days_len and (days_needed != -1)):
                        if (days_needed > 0):
                            moves = max(moves, profits[i + days_needed][k])
                        else:
                            moves = max(moves, revenue[i][k] + profits[i + 1][k])
                profits[i][j] = max(max_count, moves)
            #moving up
            i -= 1

        #Returns the profit from the first col in start index
        max_possible_revenue = profits[0][start]
        return max_possible_revenue
    
    
    
def hero(attacks):
    """
    This function to quickly determine the optimal
    multiverse travel before Master X rules the multiverse with a goal 
    to defeat the most Master X clones you can in order to weaken him.
    Written by Jessica Lim - 31954081

    Precondition: Attack Unsorted and has clashing days 
    Postcondition: No clashing dates in the new list

    Input:
    attacks is a non-empty list of N attacks, where each attack is a list of 4 items [m, s, e, c]:
    • m is the multiverse which Master X is attacking.
        * m is an integer in the range of 1 to N.
        * Master X will only attack each multiverse once; because he do not like setbacks.
    • s and e are the starting and ending days of the attack.
        * s and e are integers in the range of 1 to D.
        * You can assume that s <= e.
        * You would need to be throughout the entire attack duration from day s to day e
        inclusive in order to defeat the clones.
    • c is the number of Master X clones in the attack.
        * c is an integer in the range of 2 to C.
        * Master X will always attack with at least 2 clones because he needs friends.
        
    Return:Your algorithm returns a list of Master X attacks that you, Dr Weird, will attend to:
        • Result in the most Master X clones defeated.
        • The returned list doesnt need to be sorted.
        • It is possible for the return list to not be unique.
        
        
    Time complexity: 
    N is the length of an attack
        Best: O(NlogN)  
        Worst: O(NlogN) 
    Space complexity: 
        Input: O(N)
        Aux: O(N)
    
    """     
    def binarySearch(attack, start_index):
        #Initialize lo and hi 
        lo = 0
        hi = start_index - 1
        
        #Perform binary search iteratively
        #this is a modified binary search made for this task
        while lo <= hi:
            mid = (lo+hi) // 2
            #to make sure there is no clashing date through out start to end
            if attack[mid][2] < attack[start_index][1]: #removed the equal sign check in case
                if attack[mid+1][2] < attack[start_index][1]: #removed the equal sign check in case
                    lo = mid + 1
                else:
                    return mid
            else:
                hi = mid - 1
        #if clashed
        return -1
    
    #sort based on the finish dates
    attack = sorted(attacks, key= lambda x:x[2])
    #print(attack)
    
    #Create a list to save the max defeated clones 
    #and a tasks list/memo to save all of the attacks
    n = len(attack)
    maxDefeated = [None]*n
    tasks = [[] for _ in range(n)]
    
    #initialized the first attack on both
    maxDefeated[0] = attack[0][3]
    tasks[0].append(0)
    
    #fill bottom up
    #n log n
    #n
    for i in range(1,n):
        #with modified binary job to find non-clashed attack then try to add it on
        #log n
        j = binarySearch(attack, i)
        defeated_monster = attack[i][3]
        
        if (j!=-1):
            defeated_monster += maxDefeated[j]
            
        #include the current attack that leads to more defeated monster
        if maxDefeated[i-1] < defeated_monster:
            maxDefeated[i] = defeated_monster
            
            if j != -1:
                tasks[i] = tasks[j][:]
            tasks[i].append(i)
            
        #if current attack not leading the max defeated
        else:
            tasks[i] = tasks[i-1][:]
            # print(tasks[i])
            maxDefeated[i] = maxDefeated[i-1]
            
    # print(tasks)
    #need to backtrack with inclusion-exclusion principle ? or need to recheck ?
    #backtrack supposed to from getting the max profit and we have tasks[n-1] that returns the path
    #but to recheck and in case. The backtrack are supposed to get the list that gives the max defeated
    answer = [attack[m] for m in tasks[n-1]]
    
    #but as we found the list already i think no need backtrack anymore to find the tasks
    
    return answer

        
# test
#attacks = [[1, 2, 7, 5], [2, 1, 4, 4], [3, 6, 9, 2]]
attacks = [[1, 2, 7, 6], [2, 7, 9, 10], [3, 8, 9, 5]]
#attacks = [[1, 2, 4, 7], [2, 1, 4, 2], [3, 6, 7, 3]]
# print(hero(attacks))

#city:    0  1  2  3   # city:
travel_days = [[-1,-1, 3, 1], # 0
                       [-1,-1,-1, 1], # 1
                       [ 1,-1,-1, 1], # 2
                       [ 1, 1, 2,-1]] # 3
        
        #       city:    0     1  2  3 # day:
revenue =     [[ 1,    2, 3, 4], # 0
                       [ 3,    6, 1, 5], # 1
                       [ 1,    8, 4, 1], # 2
                       [ 1,   10, 4, 5], # 3
                       [10,    4, 5, 9]] # 4
start = 2
expected_max_profit = 22

# print(best_revenue(revenue, travel_days, start))


    
            
        