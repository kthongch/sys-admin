WORKING_DIRECTORY="/path"
HTML_REPORT="$WORKING_DIRECTORY/Daily_Check.html"
NEW_HTML_REPORT="$WORKING_DIRECTORY/Clean_Daily_Check.html"

while IFS= read -r line; do
    if [[ $line == *"<"* || $line == *">"* ]]; then
    echo "$line" >> "$NEW_HTML_REPORT"
    fi
done < "$HTML_REPORT"

mv "$NEW_HTML_REPORT" "$HTML_REPORT"