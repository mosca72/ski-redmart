# ski-redmart

implementation in gawk script to solve the problem detailed in:
http://geeks.redmart.com/2015/01/07/skiing-in-singapore-a-coding-diversion/

approach:
pre-selection of local peaks + recursive depth-first visit

execution:
gawk -f anamat.awk -v mat=map_redmart.txt

where map_redmart.txt is the file:
http://s3-ap-southeast-1.amazonaws.com/geeks.redmart.com/coding-problems/map.txt

elapsed: 118s on wintel i5 1.60Ghz
tested with GNU Awk 3.1.0
