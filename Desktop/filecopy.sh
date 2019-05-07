#!/bin/bash
SUM=0
MAX=$1
HardDrive="/home/rajgopal/Desktop"
HardDrive2="/home/rajgopal/seeni"
# Creation of RAM DISK 1 if its not available
ram1="/mnt/ramdisk1"
if [ ! -d $ram1 ]
then
    sudo mkdir $ram1
    sudo mount -t tmpfs -o rw,size=1G tmpfs $ram1
    echo "RAM DISK 1 Created"
fi
# Creation of RAM DISK 2 if its not available
ram2="/mnt/ramdisk2"
if [ ! -d $ram2 ]
then    
    sudo mkdir $ram2
    sudo mount -t tmpfs -o rw,size=1G tmpfs $ram2
    echo "RAM DISK 2 Created"
fi
# Creation of 512MB file inside RAMDISK 1
file="file1.txt"
if [ ! -f $ram1/$file ]
then 
      head -c 512M </dev/urandom > $ram1/$file
      echo "512MB File created"
fi

# Creation of 512MB file in Desktop
if [ ! -f $HardDrive2/$file ]
then 
      head -c 512M </dev/urandom > $HardDrive2/$file
      echo "512MB File created at HD"
fi

#File Transfer from Ramdisk to Ramdisk
SUM=0
for i in `seq 1 $MAX`
do
   START=$(date +%s.%N)
   sudo cp $ram1/$file $ram2 &
   wait
   END=$(date +%s.%N)
   DIFF=$( echo "scale=3; (${END} - ${START})*1000/1000" | bc )
   SUM=$( echo "scale=3; (${SUM} + ${DIFF})*1000/1000" | bc )
   sudo rm -f $ram2/$file
done
avg=$( echo "scale=3; (${SUM} / ${MAX})*1000/1000" | bc )
echo "RAMDISK1 to RAMDISK2" "AVG is " $avg

# File Transfer from Ramdisk to Hard Drive
SUM=0
for i in `seq 1 $MAX`
do
   START=$(date +%s.%N)
   cp $ram1/$file $HardDrive &
   wait
   END=$(date +%s.%N)
   DIFF=$( echo "scale=3; (${END} - ${START})*1000/1000" | bc )
   SUM=$( echo "scale=3; (${SUM} + ${DIFF})*1000/1000" | bc )
   rm -f $HardDrive/$file
done
avg=$( echo "scale=3; (${SUM} / ${MAX})*1000/1000" | bc )
echo "RAMDISK1 to HARD DRIVE" "AVG is " $avg
rm $ram1/$file 

#File Transfer from Hard Drive to Ramdisk
SUM=0
for i in `seq 1 $MAX`
do
   START=$(date +%s.%N)
   cp $HardDrive2/$file $ram1 &
   wait
   END=$(date +%s.%N)
   DIFF=$( echo "scale=3; (${END} - ${START})*1000/1000" | bc )
   SUM=$( echo "scale=3; (${SUM} + ${DIFF})*1000/1000" | bc )
   rm -f $ram1/$file
done
avg=$( echo "scale=3; (${SUM} / ${MAX})*1000/1000" | bc )
echo "HARD DRIVE to RAMDISK" "AVG is " $avg

#File Transfer from Hard Drive to Hard Drive
SUM=0
for i in `seq 1 $MAX`
do
   START=$(date +%s.%N)
   cp $HardDrive2/$file $HardDrive/$file
   wait
   END=$(date +%s.%N)
   DIFF=$( echo "scale=3; (${END} - ${START})*1000/1000" | bc )
   SUM=$( echo "scale=3; (${SUM} + ${DIFF})*1000/1000" | bc )
   rm -f $HardDrive/$file
done
avg=$( echo "scale=3; (${SUM} / ${MAX})*1000/1000" | bc )
echo "HARD DRIVE to HARD DRIVE" "AVG is " $avg
exit 1
