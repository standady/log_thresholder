# log_thresholder

A bash script to check that the occurence of a log message is within a threshold over a period of time. 

## Usage
```
./log_thresholder.sh <log_file> <needle> -min|max <limit> -interval <minutes>  [-format <format> ]
      log_file    path to file that will be searched
      needle      String to search file for (uses grep so regex can be used)
      min         Minimum number of times the needle is expected to be in the log
      max         Maximum of times the needle is expected to be in the log
      interval    Number of minutes we expect to see message
      format      Format of dates in log to look for. Uses format codes found in date man. 
                     Defaults to ISO-8601("%Y-%m-%dT%H:%M")
 ```
      
## Example

Given we have an application (app.log) that logs in the following format:

```
Jan 02 2017 03:34:25 localhost INFO, success
Jan 02 2017 03:34:27 localhost ERROR, failed operation
```

And we want to check that we didn't get more than 10 errors over the last 15 minutes, then we would run the following:

```
./log_thresholder.sh app.log "ERROR" -max 10 -interval 15 -format "%h %d %& %H:%M" 
```

