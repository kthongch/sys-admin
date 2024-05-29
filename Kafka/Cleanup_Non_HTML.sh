WORKING_DIRECTORY="/path"
HTML_REPORT="$WORKING_DIRECTORY/Chkcon.html"
NEW_HTML_REPORT="$WORKING_DIRECTORY/New_Chkcon.html"

while IFS= read -r line; do
    if [[ $line == *"<"* || $line == *">"* ]]; then
    echo "$line" >> "$NEW_HTML_REPORT"
    fi
done < "$HTML_REPORT"
