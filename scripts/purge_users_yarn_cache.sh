#!/bin/bash

Yarn_Users_Cache_Path="$1"
Max_Directory_Percentage="$2"

if [ ! -d "$Yarn_Users_Cache_Path" ]; then
  exit 0
fi

echo "Yarn cache directory = "$Yarn_Users_Cache_Path
echo "Allowed percentage after which exceeding the largest directory will be deleted = "$Max_Directory_Percentage%

# Calculate total space of disk = Used + Available
function Calculate_Disk_Size {
  Disk_Size=$(( $(df $Yarn_Users_Cache_Path | tail -n 1 | awk '{print $3}')+$(df $Yarn_Users_Cache_Path | tail -n 1 | awk '{print $4}') ))
  echo -n "Total space of disk in GB = " ; echo $Disk_Size/1024/1024 | bc
}

# Disk used space
function Calculate_Disk_Used_Size {
  Disk_Used_Size=$( df $Yarn_Users_Cache_Path | tail -n 1 | awk '{print $5}' | sed 's/%//' )
  echo -n "Total disk used space = " ; echo $Disk_Used_Size%
}

# Find the largest directory in Yarn cache
function Find_Largest_Directory {
  Largest_directory_name=$( du -hsx $Yarn_Users_Cache_Path* | sort -rh | head -1 | awk '{print $2}' )
  Largest_directory_size=$( du -hsx $Yarn_Users_Cache_Path* | sort -rh | head -1 | awk '{print $1}' )
  echo -n "Size of the largest directory = " ; echo $Largest_directory_size
  echo -n "Name of the largest directory = " ; echo $Largest_directory_name
}

# Current size of Yarn cache directory in GB
function Calculate_Yarn_Cache_Size {
  Yarn_Cache_Size=$( du -sk "$Yarn_Users_Cache_Path" | cut -f1 )
  echo -n "Current size of Yarn cache directory in GB = " ; echo $Yarn_Cache_Size/1024/1024 | bc
}

# Curent percentage used by the directory
function Calculate_Directory_Percentage {
  Directory_Percentage=$(echo "scale=2;100*$Yarn_Cache_Size/$Disk_Size+0.5" | bc | awk '{printf("%d\n",$1 + 0.5)}')
  echo "Curent percentage used by the directory = "$Directory_Percentage%
}

# Find the largest file in Yarn cache
function Find_Largest_File {
  Largest_file_name=$( find $Yarn_Users_Cache_Path -type f -printf '%s %p\n' | sort -nr | head -n 1 | awk '{print $2}' )
  Largest_file_size=$( find $Yarn_Users_Cache_Path -type f -printf '%s %p\n' | sort -nr | head -n 1 | awk '{print $1}' )
  echo -n "Size of the largest file in MB = " ; echo $Largest_file_size/1024/1024 | bc
  echo -n "Name of the largest file = " ; echo $Largest_file_name
}

Calculate_Disk_Size
Calculate_Disk_Used_Size
Find_Largest_Directory

if [ $Disk_Used_Size -le $Max_Directory_Percentage ] ; then
  echo `date`
  echo "YARN USER CACHE HAS NO BEEN DELETED!"
fi

# While the current percentage is higher than allowed percentage, delete the largest directory
while [ $Disk_Used_Size -gt $Max_Directory_Percentage ] ; do
  rm -rf $Largest_directory_name
  echo `date`
  echo "THE WHOLE $Largest_directory_name USER CACHE HAS BEEN DELETED!"
  Calculate_Disk_Used_Size
  Find_Largest_Directory
done
