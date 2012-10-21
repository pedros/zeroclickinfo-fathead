#!/bin/bash

xls2csv download/fema.xls | tail -n+27 | sed '$d' >fema.csv 

./parse.pl
