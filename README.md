# ece350_finalproject_scoops

RAM:  
  
Global vars:  
0x00000000 = Height of screen  
0x00000004 = Width of screen  
0x00000008 = Pointer to end of heap  
  
  
- Block:  
  - Getter methods:  
      (Each takes in 1 input: mem address of Block object)  
      (Each output is in $v0)  
      - Block_getNumRows  
        - outputs number of rows in block  
      - Block_getNumCols  
        - outputs number of cols in block  
      - Block_getUpperLeftCorner  
        - outputs mem address of Coordinate object for upper left hand corner  
      - Block_getColor  
        - outputs hex value of color of block  

- Coordinate:  
  - Getter methods:  
      (Each takes in 1 input: mem address of Coordinate object)     
      (Each output is in $v0)  
      - Coordinate_getXCoord
        - outputs x coord
      - Coordinate_getYCoord
        - outputs y coord
        
  - Conventions:
      - Upper left hand corner of screen is (0,0), right direction is positive x, down direction is positive y.
        

      

