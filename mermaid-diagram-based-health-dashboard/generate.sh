#!/usr/bin/env bash
# generate.sh
# Script to generate a mermaid diagram with styling applied to a specific node based on a condition.

set -e

keepTempFile=false
while (( $# )); do
    if [[ "$1" == "--keep-temp-files" ]]; then keepTempFile=true;fi    
    shift
done

# Configuration
INPUT_MMD="diagram.mmd"
OUTPUT_PNG="diagram-result.png"
TEMP_MMD="diagram_temp.mmd"

# Copy the original diagram to a temporary file
cp "$INPUT_MMD" "$TEMP_MMD"

# Array to hold nodes that require error styling
error_nodes=()

# Condition 1: Database healthcheck
# (Replace this with real condition; using the user's example)
if ! curl -s --connect-timeout 1 http://database.local/healthcheck >/dev/null; then 
    echo "Condition failed for Database! Flagging 'db' node."
    error_nodes+=("db")
    error_nodes+=("disk1")
fi

# Example Condition 2 (You can add any other nodes here based on conditions)
# if ! some_other_command; then
#     error_nodes+=("server")
# fi

# If we have any error nodes, inject the custom CSS to highlight them
if [ ${#error_nodes[@]} -gt 0 ]; then
    # Dynamically build the CSS string for all flagged nodes
    theme_css=""
    for node in "${error_nodes[@]}"; do
        # We need \" literally in the final JSON, so we escape it for bash
        theme_css+="[id*=\\\"${node}\\\"] rect { stroke: #ff0000 !important; stroke-width: 4px !important; } "
    done
    
    echo "Injecting CSS for nodes: ${error_nodes[*]}"
    
    # Export the directive to the environment so awk doesn't process escape sequences
    export mermaid_init="%%{init: {\"themeCSS\": \"$theme_css\"} }%%"
    
    # Prepend the Mermaid init directive
    awk 'BEGIN{print ENVIRON["mermaid_init"]}1' "$TEMP_MMD" > temp_inject.mmd && mv temp_inject.mmd "$TEMP_MMD"
fi

# Run the Mermaid CLI against the modified temporary diagram
echo "Generating diagram using mmdc..."
mmdc -i "$TEMP_MMD" -o "$OUTPUT_PNG"

# Cleanup
if [[ "$keepTempFile" != "true" ]]; then
    rm "$TEMP_MMD"
else
    echo "Keeping temporary file: $TEMP_MMD"
fi

echo "Diagram successfully generated: $OUTPUT_PNG"
