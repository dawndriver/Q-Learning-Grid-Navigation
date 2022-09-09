# Q-Learning-Grid-Navigation

Suppose that a robot is to traverse on a 10 * 10 grid, with the start state being the top-left cell and the goal state being the bottom-right cell

The robot is to reach the goal state by maximizing the total reward of the trip. Note that the numbers (from 1 to 100) assigned to the individual cells represent the states; they do not represent the reward for the cells. At a state, the robot can take one of four actions to move up (a = 1), right (a = 2),down (a = 3), or left (a = 4), into the corresponding adjacent state deterministically.

The learning process will consist of a series of trials. In a trial the robot starts at the initial state (s = 1) and makes transitions, according to the algorithm for Q-learning with greedy exploration, until it reaches the goal state (s = 100), upon which the trial ends. The above process repeats until the values of the Q-function converge to the optimal values. An optimal policy can be then obtained.
