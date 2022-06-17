
results_file=tmp_text.txt
rm -f $results_file
fgrep tt.log -e "ttOutputDirAndFile" | cut -d '|' -f 3 > $results_file

for file in `cat $results_file`
do
  f="$(basename -- $file)"
  echo "$f"
done


