# SweepMine
Minesweeper in World of Warcraft

## Installation
Simply grab the Source Code (.zip) from the releases and install like any other addon by dropping the extracted folder (`SweepMine`) in `\World of Warcraft\_retail_\Interface\AddOns`

## How to Play
To open SweepMine, simply do `/sweepmine` in chat and the game window will appear (it's draggable!). 

The grid is 8x8 and there are 10 bombs. The goal of the game is to reveal the whole board without hitting a bomb!

Each square has a number in it (unless it's a bomb). This number corresponds to the number of bombs that are adjacent to the square in any direction including diagonally.

In order to help you, you can right-click on any square to mark it as a possible bomb (THIS IS NOT NECESSARY TO WIN!). Right-click on the flagged space again to un-flag it.

The first click is guranteed to be a 0, so don't worry about guessing right on your first turn. Just decide where you feel luckiest starting from and go from there!

If you click on a bomb, it's game over! Just click the reset button to generate a new random board and try again!

[Demo Video]() Coming Soon!

## Issues 
If you find any bugs, please let me know with the issues tab. I tried my best to make sure that I caught most of the major bugs, but if you find an unwinnable board or a bug, please let me know by filling out a ticket.

## Development Environment
I used Visual Studio Code with the Lua language extension.

## Useful Websites
* [WoWpedia's API reference](https://wowpedia.fandom.com/wiki/World_of_Warcraft_API)
* My friends from the Total RP 3 discord server - Thanks for helping me with some of the weird API quirks!

## Future Work
* Make it so that the board can be bigger than 8x8 / have higher difficulties
* Make the frame hide in combat automatically, so that the user doesn't have to close it themselves
* Other Ideas? Let me know in the Issues Tab!

