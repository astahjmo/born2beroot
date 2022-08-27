while read line ; do
  re="Sist*"
  [[ $line =~ $re ]] && continue

  data=$(echo $line | cut -f 2- -d ' ')
  echo $data
done < <(df -h /)
