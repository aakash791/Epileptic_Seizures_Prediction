#!/bin/bash
#export PATH="$PATH:/home/ad930/temp_wfdb/bin"
summary_path="/home/ad930/chbmit/"
seizure_path="/home/ad930/datasetsv4/seizures/"
non_seizure_path="/home/ad930/datasetsv4/non_seizures/"
sec=23.6
filename=""
star=0
end=0
arg=($(grep -o -e 'chb[0-9A-Za-z]*_[0-9\+]*.edf' -e '[0-9]* s' -e '[0-9]*:[0-9]*:[0-9]*' $summary_path$1))

declare -a arr
declare -a df
df_ind=0

fpattern="chb[0-9A-Za-z]*_[0-9\+]*.edf"
tpattern='^[0-9]+$'


flag=0
index=0
s=0
k=0
length=${#arg[@]}

for (( i=0; i<${length}; i++ )); 
do
	echo "  "
	index=0
	flag=0
	if [[ ${arg[$i]} =~ $fpattern ]]
	then    
		filename=${arg[$i]}
		echo ${arg[$i]}

		star=${arg[$i+1]}
		echo "Start Time:- "$star
		end=${arg[$i+2]}
		echo "End Time:- "$end
		IFS=":" read -r h1 m1 s1 <<<"$star"
		IFS=":" read -r h2 m2 s2 <<<"$end"
		
		diff_s=$((10#$s2-10#$s1))
		diff_m=$((10#$m2-10#$m1))
		diff_h=$((10#$h2-10#$h1))	

		if [[ $diff_s -lt 0 ]]
		then
			diff_s=$((diff_s+60))
			diff_m=$((diff_m-1))
		fi

		if [[ $diff_m -lt 0 ]]
		then
		 	diff_m=$((diff_m+60))
                        diff_h=$((diff_h-1))
		fi 	

		if [[ $diff_h -lt 0 ]]
		then
			diff_h=0
		fi
		
		file_endTime=$((diff_h*60*60+diff_m*60+diff_s-1))
		#fi
		echo "Total Seconds:- "$file_endTime
		i=$((i+2))

			
		if [[ ${arg[$((i+1))]} =~ $tpattern ]]
		then	
			flag=1
			#echo ${arg[$((i+1))]}
			i=$((i+1))
			for (( ; ; i++));
			do
				if [[ ${arg[$i]} =~ $tpattern  ]]
				then
					arr[$index]=${arg[$i]}
					echo ${arr[$index]}
					index=$((index+1))
				elif [[ ${arg[$i]} == "s" ]]
				then
					continue
				elif [[ ${arg[$i]} =~ $fpattern ]]
				then
					i=$((i-1))
					break
				else
					break
				fi	
			done
		fi
		

		ch=0
		#df=0
		while [[ flag -eq 1 && ch -lt ${#arr[@]}  ]]
		do
			df[$df_ind]=$((arr[ch+1]-arr[ch]))
			#echo "Seizure Size:- "$df[df_ind]
			ch=$((ch+2))
			df_ind=$((df_ind+1))	
		done

		echo $((index/2)) "seizures found in "$filename
		data=${1:0:5}"_"
		#k=0
		#sez_path="/mnt/d/Australia/UOW/Spring_2018/Research_Project_991/sez_datasets/seizures/"
		#nonsez_path="/mnt/d/Australia/UOW/Spring_2018/Research_Project_991/sez_datasets/non_seizures/"
		#s=0
		typ="seizure"
		arr_index=0
		format=".csv"
		#file_endTime=$((file_endTime*60*60))
		arr_length=${#arr[@]}
		if [[ $flag -eq 0 ]]  #no seizure found
		then    
			j=0
			#while [[ $j -le $((file_endTime-sec)) ]]
			#echo [[ $j -le $((file_endTime-arr_index)) ]]
			#echo $(python3 -c "print($j <= "$(python3 -c "print($file_endTime - $sec)")")")
			while [[ "$(python3 -c "print($j <= "$(python3 -c "print($file_endTime - $sec)")")")" = "True" ]]
			#for j in `seq 0 $file_endTime`; 
			do
				#echo $j"---"$((j+sec))	
                        	#rdsamp -v -r $filename -c -f $j -t $((j+sec)) > $non_seizure_path$data$k$format
				#rdsamp -v -r $filename -c -f $j -t "$(python3 -c "print($j+$sec)")" > $non_seizure_path$data$k$format
                                k=$((k+1))
				#j=$((j+sec))
				j="$(python3 -c "print($j+$sec)")"
			done
		else		      # seizure found
			temp=0
			#for j in `seq 0 $file_endTime`; do
			#for j in $(eval echo {0..$file_endTime} )
			j=0
			#while [[ $j -le $((file_endTime-sec)) ]]
			while [[ "$(python3 -c "print($j <= "$(python3 -c "print($file_endTime - $sec)")")")" = "True" ]] 
			do
				#echo "---"$j"---"
				#echo "choo"
				if [[ $arr_index -ne $((arr_length-1))  ]]
				then
					temp=${arr[$arr_index]}   # take first index representing start of seizure
					#echo $temp
				#	 echo "---"$j"---"	
				fi
				#if [[  $((j+sec)) -le $temp || $arr_index -eq $arr_length ]]
				if [[  "$(python3 -c "print("$(python3 -c "print($j+$sec)")" <= float($temp))")" = "True" || $arr_index -eq $arr_length  ]]
				then   
 					#echo $j",done_non"
			        	#rdsamp -v -r $filename -c -f $j -t $((j+sec)) > $non_seizure_path$data$k$format
					#rdsamp -v -r $filename -c -f $j -t "$(python3 -c "print($j+$sec)")" > $non_seizure_path$data$k$format
					#j=$((j+sec))
					j="$(python3 -c "print($j+$sec)")"
			        	k=$((k+1))	 
				#	 echo "**"$j"**"
				#elif [[ flag -eq 1 && $j -ge ${arr[$arr_index]} && $((j+sec)) -le ${arr[$arr_index+1]} ]]  # the signal should lie between seizure start time and end time
				elif [[ flag -eq 1 && "$(python3 -c "print($j <= ${arr[$arr_index]})")" = "True" && "$(python3 -c "print("$(python3 -c "print($j+$sec)")" <= ${arr[$arr_index+1]})")" = "True" ]]
				then
				#	echo $j"done"
					#echo ${arr[$arr_index+1]} 
					#rdsamp -v -r $filename -c -f $j -t $((j+sec)) > $seizure_path$data$s$typ$format
					rdsamp -v -r $filename -c -f $j -t "$(python3 -c "print($j+$sec)")" > $seizure_path$data$s$typ$format
					#echo $((arr_index+1))"--"$((arr_length-1))
					#echo $((j+sec))"---"${arr[$arr_index+1]}  # uncomment this if u want to see the duration 
					#if [[ $((j+sec)) -eq ${arr[$arr_index+1]} && $((arr_index+1)) -lt $((arr_length-1)) ]]  # move index more further to generate more seizures in the same record
					#then
					#	echo "boo"
					#	arr_index=$((arr_index+2))
					#elif [[ $((j+sec)) -eq ${arr[$arr_index+1]} && $((arr_index+1)) -eq $((arr_length-1))  ]] # no more seizure left move to end of index 
					#then 
					#	echo "choo"
					#	arr_index=$((arr_index+1))
					#	temp=$file_endTime
					#fi
					s=$((s+1))
					j="$(python3 -c "print($j+$sec)")"
					#j=$((j+sec))
				#	 echo "++"$j"++"
				#elif [[ flag -eq 1 && $((j+sec)) -ge ${arr[$arr_index+1]} &&  $arr_index -lt $arr_length ]]
				elif [[ flag -eq 1 && "$(python3 -c "print("$(python3 -c "print($j+$sec)")" >= ${arr[$arr_index+1]})")" = "True" &&  $arr_index -lt $arr_length ]]
				then   
					#if [[ $arr_index -le $arr_length ]]
					#then
						arr_index=$((arr_index+2))
					#	j=$((j+1))
					#fi
				#j=$((j+1))
				j="$(python3 -c "print($j+1)")"	
				#echo "##"$j"##"
				#elif [[ $flag -eq 1 && ( $j -le ${arr[$arr_index+1]} || $j -le $file_endTime )  ]]  # could be temp --> check
				elif [[ "$(python3 -c "print($j <= $file_endTime)")" = "True" ]] 
				then
					#echo "too"
					#j=$((j+1))
					j="$(python3 -c "print($j+1)")"
				fi
			#j=$((j+sec))
			#echo $j	
			done
		fi
		
	fi

done


df_ind=0
while [[ df_ind -lt ${#df[@]}  ]]
do
      echo "Seizure Size:- "$((df_ind+1))" -- "${df[$df_ind]}
      df_ind=$((df_ind+1))    
done

