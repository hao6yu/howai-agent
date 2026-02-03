#!/bin/bash

# Script to read .env file and export environment variables for iOS builds

ENV_FILE="../../.env"

if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from .env file..."
    
    # Read .env file and export variables
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        if [[ ! $key =~ ^[[:space:]]*# ]] && [[ -n $key ]]; then
            # Remove any quotes from the value
            value=$(echo "$value" | sed 's/^["'\'']*//;s/["'\'']*$//')
            export "$key"="$value"
            echo "Exported: $key"
        fi
    done < "$ENV_FILE"
    
    # Specifically export Google Maps API key for iOS
    if [ -n "$GOOGLE_MAPS_API_KEY" ]; then
        export GOOGLE_MAPS_API_KEY_ENV="$GOOGLE_MAPS_API_KEY"
        echo "Google Maps API key exported for iOS"
    else
        echo "WARNING: GOOGLE_MAPS_API_KEY not found in .env file"
    fi
else
    echo "WARNING: .env file not found at $ENV_FILE"
fi 