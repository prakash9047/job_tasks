#!/bin/bash
# AMFI NAV Extractor - Extracts Scheme Name and Asset Value from AMFI NAV file
# Usage: ./extract_amfi_nav.sh

# Variables
NAV_URL="https://www.amfiindia.com/spages/NAVAll.txt"
OUTPUT_TSV="amfi_nav_data.tsv"
OUTPUT_JSON="amfi_nav_data.json"
TEMP_FILE="nav_data_temp.txt"

echo "Downloading AMFI NAV data..."
# Download the NAV file
if ! curl -s "$NAV_URL" -o "$TEMP_FILE"; then
    echo "Error: Failed to download the NAV data. Please check your internet connection."
    exit 1
fi

echo "Extracting Scheme Name and Asset Value..."

# Create or overwrite the TSV file with headers
echo -e "Scheme Name\tAsset Value" > "$OUTPUT_TSV"

# Process the NAV file and extract relevant data
# The NAV file format has scheme name and NAV values on separate lines
# We'll use awk to process the file and extract required fields
awk -F ";" '
    # Skip empty lines and header lines
    length($0) > 0 && $0 !~ /^(Scheme Code|Open End|Close End)/ { 
        # If the line has at least 5 fields, it likely contains scheme details
        if (NF >= 5) {
            # Store the scheme name (field 4)
            scheme_name = $4
            # Store the NAV value (field 5)
            nav_value = $5
            
            # If both fields exist, output them to TSV
            if (length(scheme_name) > 0 && length(nav_value) > 0) {
                # Remove any leading/trailing whitespace
                gsub(/^[ \t]+|[ \t]+$/, "", scheme_name)
                gsub(/^[ \t]+|[ \t]+$/, "", nav_value)
                
                # Print to TSV format
                print scheme_name "\t" nav_value
            }
        }
    }
' "$TEMP_FILE" >> "$OUTPUT_TSV"

echo "TSV extraction complete. Data saved to $OUTPUT_TSV"

# Convert to JSON as well since it was requested
echo "Converting to JSON format..."

# Create JSON with jq if available, otherwise use awk
if command -v jq &> /dev/null; then
    # Convert TSV to JSON using jq
    (
        echo "["
        awk -F '\t' 'NR>1 {
            if (NR>2) printf ","
            printf "{\n  \"scheme_name\": \"%s\",\n  \"asset_value\": \"%s\"\n}", $1, $2
        }' "$OUTPUT_TSV"
        echo "]"
    ) | jq '.' > "$OUTPUT_JSON"
else
    # Fallback to awk if jq is not available
    (
        echo "["
        awk -F '\t' 'BEGIN { first = 1 }
        NR>1 {
            if (!first) printf ","
            first = 0
            gsub(/"/, "\\\"", $1)  # Escape double quotes in scheme name
            printf "{\n  \"scheme_name\": \"%s\",\n  \"asset_value\": \"%s\"\n}", $1, $2
        }' "$OUTPUT_TSV"
        echo "]"
    ) > "$OUTPUT_JSON"
fi

echo "JSON conversion complete. Data saved to $OUTPUT_JSON"

# Clean up temporary file
rm "$TEMP_FILE"

echo "Processing complete!"

# Answer to the question: Should this data be in JSON instead?
cat << 'EOF'

*** Should this data be in JSON instead? ***

Yes, storing this data in JSON format has several advantages over TSV:

1. Hierarchical Structure: JSON supports nested structures, useful for representing fund categories, subcategories, and schemes.

2. Type Preservation: JSON distinguishes between numbers and strings. Asset values could be stored as numeric types instead of strings.

3. Self-describing: JSON keys make the data self-documenting, eliminating the need for separate column headers.

4. Programming Interface: Most programming languages have built-in JSON parsing, making it easier to work with the data.

5. Extensibility: JSON easily accommodates additional fields without breaking existing implementations.

6. Web Compatibility: JSON is the standard format for web APIs, making it ideal if you're building web applications.

The script provides both formats so you can choose based on your use case.
EOF



# AMFI NAV Extractor
# Description
# This shell script downloads the NAV data from AMFI's website and extracts the Scheme Name and Asset Value information, saving it in both TSV and JSON formats.
# Features

# Downloads NAV data directly from AMFI website
# Extracts relevant fields (Scheme Name and Asset Value)
# Saves data in both TSV and JSON formats
# Includes error handling for download failures
# Provides a detailed explanation of data format advantages

# Requirements

# Bash shell
# curl
# awk
# jq (optional, for prettier JSON formatting)

# Usage
# bashchmod +x extract_amfi_nav.sh
# ./extract_amfi_nav.sh
# Output
# The script generates two files:

# amfi_nav_data.tsv - Tab-separated values file
# amfi_nav_data.json - JSON format data

# Notes on Data Format
# The AMFI script provides data in both TSV and JSON formats. JSON is generally preferred for:

# Hierarchical data representation
# Type preservation (numbers vs. strings)
# Self-documenting format
# Better language support
# Extensibility
# Web API compatibility

# TSV may be preferred when:

# Simplicity is required
# The data needs to be viewed in spreadsheet applications
# Processing with command-line tools is a primary use case