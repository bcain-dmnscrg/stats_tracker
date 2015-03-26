# stats_tracker
Simple Bash 3 friendly script to capture 'show global status' every x seconds and display the change in values. 
Only values that change between samples are displayed.

Takes 2 arguments
- delay - number of seconds to pass to sleep between samples. Defaults to 2
- regex - regex string to pass to egrep to narrow the values from show global status. No default

If regex is set, delay must be as well as the order of arguments is static

Example:

./stats_tracker.sh 4 'row|History'

A delay of 4 seconds is used between samples and only status values with 'row' or 'history' will be examined.

Assumption:

The user running the script has sufficient permissions to run 'show global status' and credentials are stored in .my.cnf.
