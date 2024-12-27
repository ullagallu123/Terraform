#!/bin/bash

# # Set environment variables for AWS credentials
# export AWS_PROFILE="eks-siva.bapatlas.site"
# export AWS_DEFAULT_REGION="us-east-1"

# Define Terraform directories in reverse order
DIRS=("05.sg" "00.vpc")

# Function to run Terraform destroy
run_terraform_destroy() {
    local dir=$1
    echo "🚀 Processing directory for destroy: $dir"
    cd "$dir" || exit
    
    if [ -f "main.tf" ]; then
        
        echo "🔹 Running terraform destroy..."
        terraform destroy -auto-approve
        
        echo "✅ Terraform destroy completed successfully in $dir"
    else
        echo "⚠️ No Terraform files (main.tf) found in $dir. Skipping..."
    fi
    
    cd - > /dev/null
}

# Loop through each directory in reverse order and run Terraform destroy
for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        run_terraform_destroy "$dir"
    else
        echo "❌ Directory not found: $dir"
    fi
done

echo "🎯 All Terraform destroy tasks completed successfully!"
