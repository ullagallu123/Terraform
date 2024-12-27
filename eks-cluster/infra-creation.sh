#!/bin/bash

# Set environment variables for AWS credentials
export AWS_PROFILE="eks-siva.bapatlas.site"
export AWS_DEFAULT_REGION="us-east-1"

# Define existing Terraform directories
DIRS=("00.vpc" "05.sg")

# Function to run Terraform commands
run_terraform() {
    local dir=$1
    echo "🚀 Processing directory: $dir"
    cd "$dir" || exit
    
    if [ -f "main.tf" ]; then
        echo "🔹 Running terraform init..."
        terraform init -upgrade
        
        echo "🔹 Running terraform fmt..."
        terraform fmt
        
        echo "🔹 Running terraform validate..."
        terraform validate
        
        echo "🔹 Running terraform plan..."
        terraform plan
        
        echo "🔹 Running terraform apply..."
        terraform apply -auto-approve
        
        echo "✅ Terraform operations completed successfully in $dir"
    else
        echo "⚠️ No Terraform files (main.tf) found in $dir. Skipping..."
    fi
    
    cd - > /dev/null
}

# Loop through each directory and run Terraform commands
for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        run_terraform "$dir"
    else
        echo "❌ Directory not found: $dir"
    fi
done

echo "🎯 All Terraform tasks completed successfully!"
