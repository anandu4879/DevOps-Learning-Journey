```bash
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Please provide a log file"
    exit 1
fi

file=$1

if [ ! -f "$file" ]; then
    echo "File not found"
    exit 1
fi

echo "Log Analyzer"
echo

echo "Total lines:"
wc -l < "$file"

echo
echo "Top 5 frequent words:"
cat "$file" | tr ' ' '\n' | sort | uniq -c | sort -nr | head -5

echo
read -p "Enter a search term: " word

echo
echo "Matching lines:"
grep -n "$word" "$file"

echo
read -p "Save report? (yes/no): " answer

if [ "$answer" = "yes" ]; then

    echo "Log Report" > report.txt
    echo "------------" >> report.txt

    echo "Total lines:" >> report.txt
    wc -l < "$file" >> report.txt

    echo "" >> report.txt
    echo "Search term: $word" >> report.txt

    echo "Matching lines:" >> report.txt
    grep -n "$word" "$file" >> report.txt

    echo
    echo "Report saved to report.txt"

    echo
    echo "Report size:"
    ls -lh report.txt
fi

echo
echo "Done!"
```
