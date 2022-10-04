"""
Jessica Lim
31954081

FIT2004 ASSIGNMENT 2
"""
from cmath import inf
from copy import copy
from queue import PriorityQueue
import sys
import math
from ctypes import py_object
from typing import TypeVar, Generic

from pyparsing import empty

T = TypeVar('T')

# sorts the given arr[] with worst-case time complexity of O(n)
def countSort(arr):
    #find max arr
    #O(n)
    maxelement = int(max(arr))
    #find min arr
    #O(n)
    minelement = int(min(arr))
    #so, range :
    #O(1)
    rangeElements = maxelement - minelement + 1
    # Create a count array to store count of individual
    # elements and initialize count array as 0
    # worse case O(n)
    count = [0 for i in range(rangeElements)]
    output = [0 for j in range(len(arr))]
  
    # store each character
    #O(n)
    for i in range(0, len(arr)):
        count[arr[i]-minelement] += 1
  
    # count[i] changed so that count[i] is niw
    # pos of this element in output
    for i in range(1, len(count)):
        count[i] += count[i-1]
  
    # output character array
    #O(n)
    for i in range(len(arr)-1, -1, -1):
        output[count[arr[i] - minelement] - 1] = arr[i]
        count[arr[i] - minelement] -= 1
  
    # copy output contained sorted chars
    #O(n)
    for i in range(0, len(arr)):
        arr[i] = output[i]
  
    return arr
        
def median_of_medians(lst):
    """
    this method act as a way to select the partitioning
    """
    #check if none
    if lst is None or len(lst) == 0:
        return None

    #not none
    return select_pivot(lst, len(lst) // 2)


def select_pivot(arr, k):
    """
    Select a pivot corresponding to the kth largest element in the array
    :param arr: Array from which we need to find the median.
    :param k: cardinality that represents the kth larget element in the array
    :return: The value of the pivot
    
    Complexity : will call on countSort which has worst case complexity O(n)
    """
    # divide array into smaller parts /  divisions of 5
    # O(log n)
    divisions = [arr[i : i+5] for i in range(0, len(arr), 5)]

    #sort each
    #O(n)
    sorted_divisions = [countSort(division) for division in divisions]


    #median of each 
    #O(log n)
    medians = [division[len(division) // 2] for division in sorted_divisions]

    #find the median of medians
    #O(n), best case = O(1)
    if len(medians) <= 5:
        pivot = countSort(medians)[len(medians) // 2]
    else:
        pivot = select_pivot(len(medians) // 2)

    #partition the array around the pivot
    #O(log n) ?
    p = partition(arr, pivot)

    #find pivot if its on k pos
    #O(1)
    if k == p:
        #select that pivot
        return pivot

    if k < p:
        #looking on the low side of the partioning to select pivot
        return select_pivot(arr[0:p], k)
    else:
        #select a new pivot by looking on the high side of the partioning
        return select_pivot(arr[p+1:len(arr)], k - p - 1)


def partition(arr, pivot):
    """
    Partition the array around the given pivot
    :param arr: array
    :param pivot: pivot
    :return: final position
    """
    low = 0
    high = len(arr) - 1
    mid = 0

    #O(log n)
    while mid <= high:
        if arr[mid] == pivot:
            mid += 1

        elif arr[mid] < pivot:
            arr[low], arr[mid] = arr[mid], arr[low]
            low += 1
            mid += 1
        else:
            arr[high], arr[mid] = arr[mid], arr[high]
            high -= 1

    return low

def ideal_place(relevant):
    """
    given a set of n relevant points (x1, y1),(x2, y2), . . . ,(xn, yn), which are all intersections
    in the grid. Your goal is to compute the coordinates (x, y) of an optimal intersection to open is minimal.

    Precondition: x and y not sorted
    Postcondition: x and y got sorted in seperate lists

    Input:
    Your ideal place finder is a Python function ideal_place(relevant), where relevant =
    [[x1, y1], [x2, y2], [x3, y3], . . . , [xn, yn]] contains the coordinates of the n relevant points.
        
    Return:
    Your algorithm should output a single pair of coordinates x and y such that Pn
    i=1(|x - xi|) + (|y - yi |) is minimal. The output should be in the following format: [x, y]. If there are multiple
    optimal solutions, your algorithm can output anyone of them (but should output exactly one).
        
    Time complexity: 
        Best: O(1) if None even tho technically still O(N)
        Worst: worst-case time complexity of O(n) 
    Space complexity: 
        Aux: 

    Reasoning : 
    
    """
    #the x of the coordinates
    x = [relevant[i][0] for i in range (len(relevant))]
    
    #the y of the coordinates
    y = [relevant[i][1] for i in range (len(relevant))]
    
    point_x = median_of_medians(x)
    point_y = median_of_medians(y)
    
    optimal_point = [point_x,point_y]
    # print(optimal_point)
    return optimal_point

    
class Vertex:
    """Class of vertex that contains size, distance and etc.
    """
    def __init__(self, vertex):
        self.vertex = vertex
        self.vertex_edges = []
        self.discovered = False
        self.visited = False
        self.distance = None ######################################
        self.previous = None
        self.index = None
        self.pred = []

    def add_edge_to_vertex(self, edge):
        self.vertex_edges.append(edge)
        
class Edge:
    """
    Class of edge that contains all edge and its infos
    """
    def __init__(self, u, v, w):
        self.u = u
        self.v = v
        self.w = w

class MinHeap():
    """
    Class to find min heap from the array
    """
 
    def __init__(self,graph):
        self.array = [(None,float(inf))]
        self.size = 0
        self.graph = graph
 
    def is_empty(self):
        return self.size == 0
    
    def swap(self,u,v):
        tmp = self.array[u]
        self.array[u] = self.array[v]
        self.array[v] = tmp
 
    def  __len__(self):
        return self.size
    
    def smallest_child(self,k):
        if 2*k == self.size or self.array[2*k+1][1] > self.array[2*k][1]:
            return 2*k
        return 2*k+1
    
    def rise(self,k):
        graph = self.graph
        
        while k > 1 and self.array[k][1] < self.array[k//2][1]:

            # v1=graph.vertices[(self.array[k][0]).order]
            # v2=graph.vertices[(self.array[k//2][0]).order]
            # v1.idx_in_heap,v2.idx_in_heap = v2.idx_in_heap,v1.idx_in_heap

            temp_index = self.array[k][0].index 
            self.array[k][0].index = self.array[k//2][0].index
            self.array[k//2][0].index = temp_index 

            self.swap(k, k // 2)
            k = k // 2
            
    def sink(self, k):
        """ Make the element at index k sink to the correct position """
        graph = self.graph
        while 2*k <= self.size:
            child = self.smallest_child(k)
            if not self.array[child][1] >= self.array[k][1]:
                # v1=graph.vertices[(self.array[k][0]).order]
                # v2=graph.vertices[(self.array[k//2][0]).order]
                # v1.idx_in_heap,v2.idx_in_heap = v2.idx_in_heap,v1.idx_in_heap
                
                temp_index = self.array[k][0].index 
                self.array[k][0].index = self.array[child][0].index
                self.array[child][0].index = temp_index

                self.swap(child, k)
            k = child
            
    def insert(self,e):
        self.array.append((e,e.distance))
        e.index = self.size
        self.size += 1
        self.rise(self.size)
        
    def serve(self):
        graph = self.graph
        if self.size != 0:
            # v1=graph.vertices[(self.array[1][0]).order]
            # v2=graph.vertices[(self.array[self.size][0]).order]
            # v1.idx_in_heap,v2.idx_in_heap = v2.idx_in_heap,v1.idx_in_heap

            temp_index = self.array[1][0].index 
            self.array[1][0].index = self.array[self.size][0].index
            self.array[self.size][0].index = temp_index

            self.swap(1,self.size)
            
            item = self.array.pop()
            self.size -= 1
            self.sink(1)
            return item

    def update(self,e):
        self.rise(e.index)
        
    # def update_key(self,k):
    #     graph = self.graph
        
    #     while k > 1 and self.array[k][1] < self.array[k//2][1]:
    #         v1=graph.vertices[(self.array[k//2][0]).order]
    #         v2=graph.vertices[(self.array[k][0]).order]
    #         v1.idx_in_heap,v2.idx_in_heap = v2.idx_in_heap,v1.idx_in_heap
    #         self.swap(k,k//2)
            

class RoadGraph:
    """
    a class RoadGraph that represents the roads in the city. The __init__ method
    of RoadGraph would take as an input a list of roads roads represted as a list of tuples (u, v, w)
    where:
        •u is the starting location ID for a road, represented as a non-negative integer.
        •v is the ending location ID for a road, represented as a non-negative integer.
        •w is the distance along that road, represented as a non-negative integer.
        •You cannot assume that the list of tuples are in any specific order.
        •You cannot assume that the roads are 2-way roads.
    """
    
    def __init__(self, roads):
        # ToDo: Initialize the graph data structure here
        self.roads = roads 
        self.vertices = [None] * len(roads)
        self.graph = []
        for i in range(len(roads)):
            self.vertices[i] = Vertex(i)
            
        self.vertices_copy = [None] * len(roads)
        for j in range(len(roads)):
            self.vertices_copy[j] = Vertex(j)
        
        for edge in roads:
            u = edge[0]
            v = edge[1]
            w = edge[2]
            current_edge = Edge(u,v,w)
            current_vertex = self.vertices[u]
            current_vertex.add_edge_to_vertex(current_edge)
            
            current_edge_copy = Edge(u,v,w)
            current_vertex_copy = self.vertices_copy[u]
            current_vertex_copy.add_edge_to_vertex(current_edge)
        
    
    def connect_graph(self,chores_location):
        for edge in range(len(self.vertices)):
            self.graph.append(self.vertices[edge])
        
        for edge in range(len(self.vertices)):
            self.graph.append(self.vertices_copy[edge])
                
        # connecting the chores to duplicated chores
        for i in range(len(chores_location)):
            self.graph[chores_location[i]].add_edge_to_vertex(Edge(chores_location[i], chores_location[i]+len(self.vertices), 0))
        
    
    
    def routing(self, start, end, chores_location):
        """
        This function search the shortest distance from the start to end location with
        choosing one of the shortest path to chores in distance.

        Precondition: dijkstra have not iterate all nodes
        Postcondition: dijkstra have iterated all nodes to find the shortest distance

        Input:
        You would now proceed to implement routing(self, start, end, chores_location) as a
        function within the RoadGraph class. The functions accepts 3 arguments:
            •start is a non-negative integer that represents the starting location of your journey. Your
            route must begin from this location.
            •end is a non-negative integer that represents the ending location of your journey. Your
            route must end in this location.
            •chores_location is a non-empty list of non-negative integers that stores all of the loca-
            tion where your chores could be performed.
            •Do note that it is possible for the locations in chores_location to include the start
            and/or end as well.
            •Do note that the locations in chores_location is not sorted.
            •Do note that all locations in chores_location are valid locations in the roads list
        
        Return:
        The function would then return the shortest route from the start location to the end location,
        going through at least 1 of the locations listed in chores_location.
        
        Time complexity: 
            Best: O(|E|log|V |) 
            Worst: O(|E|log|V |) 
        Space complexity: 
            Input: O(|V |+ |E|)
            Aux: O(|V |+ |E|)
    
        """
        # ToDo: Performs the operation needed to find the optimal route.
        self.connect_graph(chores_location)
        saved_vertex = []
        for chores in chores_location:
            for edge in self.vertices_copy[chores].vertex_edges:
                self.vertices[chores].add_edge_to_vertex(edge)
        
        end = end + len(self.vertices)
        self.connect_graph(chores_location)
        
        return self.dijkstra(start,end)
        
        
    
        # shortest_dist =  self.vertices_copy[end]
        
        # path = [end]
        
        # while self.vertices_copy.previous is not None:
        #     prev = self.vertices_copy.previous
        #     self.vertices_copy.previous = self.vertices_copy.previous
        #     path.append(prev.vertex)
            
        # answer = []    
        # for c in range(len(path)-1,-1,-1):
        #     answer.append(path[c])
        
        # for chores in chores_location:
        #     self.vertices[chores].vertex_edges = save_vertex_edges
            
        # return answer
    
    # The main function that calculates distances
    # of shortest paths from src to all vertices.
    # It is a O(ELogV) function
    def dijkstra(self,source,end):
        priority_queue = MinHeap(len(self.graph)) #self.graph used to be self.vertices
        self.graph[source].distance = 0
        priority_queue.insert(self.graph[source])
        # print("self.graph[source]",self.graph[source])
        
        self.graph[source].discovered = True
        # while priority_queue is not empty
        while not priority_queue.is_empty():
            # min from priority_queue  
            u = priority_queue.serve()        
            u = u[0]
            u.visited = True 
            #if vertex != source, add vertex to priority_queue
            for edge in u.vertex_edges:
                v = self.graph[edge.v]
                if not v.discovered:          
                    v.discovered = True
                    v.distance = u.distance + edge.w
                    v.previous = u 
                    v.pred.append(v.vertex)
                    priority_queue.insert(v)
                    
                #for each unvisted neighbour v of u
                #if distance of v > distance of u + edge_weight (u,v)
                elif not v.visited:                         
                    if v.distance > u.distance + edge.w:    
                        v.distance = u.distance + edge.w    
                        v.previous = u 
                        priority_queue.update(v)
                # print(v.vertex,v.distance)
                
        vertices = self.graph
        source_v= vertices[source]
        source_v.distance = 0
        source_v.previous = None
        dist=[]    
        for i in self.graph: #get all the distances from source
            dist.append(i.distance)
            # print(dist)
            
        sol = []
        vertices2 = self.graph
        back_v = vertices2[end]
        while back_v != None:
            # sol.append([back_v.vertex,back_v.distance])
            sol.append(back_v.vertex)
            back_v = back_v.previous
            
        # sol2 = []
        # while last != None:
        #     # sol.append([back_v.vertex,back_v.distance])
        #     sol2.append(last.vertex)
        #     last = last.previous
            
        # print(sol)
        # print(sol)
        return sol

        
    
                

            
        


if __name__ == "__main__":
    #wordlist = ["hello", "helps", "harpy"]
    rel = [[61, 99], [-52, -19], [-48, -87], [-56, 45], [-82, -65], [-35, -83], [93, -95], [80, -27], [11, -69], [3, -91], 
               [96, 14], [-69, 30], [-32, -56], [48, -61], [-12, -84], [9, 95], [-22, 45], [-80, -34], [-1, -61], [-81, 3]]
    ideal_place(rel)
    
    roads = [(0,1,4), (1,2,2), (2,3,3), (3,4,1), (1,5,2), (5,6,5), (6,3,2), (6,4,3), (1,7,4), (7,8,2), (8,7,2), (7,3,2), (8,0,11)]
    start = 0
    end = 4
    chores_location = [6,8]
    answers = [[0,1,5,6,4], [0,1,5,6,3,4]]
        
    myGraph = RoadGraph(roads)
    result = myGraph.routing(start, end, chores_location)
    
    # Loop to print the distance of
    # every node from start,end vertex
    # for i in range(len(result)):
    #     if (result[i] == math.inf):
         
    #         print("{0} and {1} are not " +
    #                           "connected".format(start, end));
    #         continue;       
    #     print("Distance of {}th vertex from start,end vertex {} is: {}".format(
    #                       start, end, result[i]));

