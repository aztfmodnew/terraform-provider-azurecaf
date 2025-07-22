#!/bin/bash

# Generic script to add Azure resources to terraform-provider-azurecaf
# Can be used to add missing resources or new Azure resource types
# Usage: ./add_azure_resources.sh [resource_list_file]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESDEF="$SCRIPT_DIR/../resourceDefinition.json"
RESOURCE_LIST="${1:-$SCRIPT_DIR/../missing_resources.txt}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Help function
show_help() {
    echo "Azure Resource Addition Tool"
    echo "============================"
    echo ""
    echo "Usage: $0 [resource_list_file]"
    echo ""
    echo "Arguments:"
    echo "  resource_list_file    Optional. Path to file containing resource names (one per line)"
    echo "                        Default: ../missing_resources.txt"
    echo ""
    echo "Features:"
    echo "  • Automatically detects Azure naming patterns"
    echo "  • Creates appropriate slugs and validation rules"
    echo "  • Maintains JSON structure and validation"
    echo "  • Creates automatic backups"
    echo "  • Provides detailed progress reporting"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Use default missing_resources.txt"
    echo "  $0 my_resources.txt                  # Use custom resource list"
    echo "  $0 <(echo 'azurerm_new_service')     # Add single resource"
    echo ""
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Validation
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ jq is required but not installed. Please install jq first.${NC}"
    exit 1
fi

if [[ ! -f "$RESDEF" ]]; then
    echo -e "${RED}❌ resourceDefinition.json not found at: $RESDEF${NC}"
    exit 1
fi

if [[ ! -f "$RESOURCE_LIST" ]]; then
    echo -e "${RED}❌ Resource list file not found: $RESOURCE_LIST${NC}"
    echo -e "${YELLOW}💡 Create a file with Azure resource names (one per line) or use --help for more info${NC}"
    exit 1
fi

# Create backup
echo -e "${BLUE}📂 Creating backup...${NC}"
cp "$RESDEF" "$RESDEF.backup.$(date +%Y%m%d_%H%M%S)"

# Function to check if resource exists
resource_exists() {
    local resource_name="$1"
    jq -e --arg name "$resource_name" '.[] | select(.name == $name)' "$RESDEF" > /dev/null
}

# Function to add resource using intelligent pattern detection
add_resource_intelligent() {
    local name="$1"
    
    if resource_exists "$name"; then
        echo -e "${YELLOW}ℹ️  Resource $name already exists, skipping...${NC}"
        return 0
    fi
    
    echo -e "${GREEN}➕ Adding $name...${NC}"
    
    # Default properties
    local min_length=1
    local max_length=80
    local validation_regex=""
    local scope="resourceGroup"
    local slug=""
    local dashes=true
    local lowercase=false
    local regex=""
    local resource_description=""
    local resource_provider_namespace=""
    
    # Intelligent pattern detection based on Azure service categories
    case "$name" in
        # API Management resources
        *api_management*)
            min_length=1
            max_length=80
            validation_regex="\"^[a-zA-Z][a-zA-Z0-9-]{0,78}[a-zA-Z0-9]$\""
            scope="parent"
            dashes=true
            lowercase=false
            regex="\"[^a-zA-Z0-9-]\""
            resource_provider_namespace="Microsoft.ApiManagement"
            case "$name" in
                *api_diagnostic*) slug="apidiag"; resource_description="API Management API Diagnostic" ;;
                *api_operation_policy*) slug="apioppol"; resource_description="API Management API Operation Policy" ;;
                *api_operation*) slug="apiop"; resource_description="API Management API Operation" ;;
                *api_policy*) slug="apipol"; resource_description="API Management API Policy" ;;
                *api_schema*) slug="apischema"; resource_description="API Management API Schema" ;;
                *api_version_set*) slug="apivs"; resource_description="API Management API Version Set" ;;
                *authorization_server*) slug="apiauth"; resource_description="API Management Authorization Server" ;;
                *custom_domain*) slug="apidom"; resource_description="API Management Custom Domain" ;;
                *diagnostic*) slug="apimdiag"; resource_description="API Management Diagnostic" ;;
                *group_user*) slug="apimgu"; resource_description="API Management Group User" ;;
                *identity_provider_aad*) slug="apimidpd"; resource_description="API Management Identity Provider AAD" ;;
                *identity_provider_facebook*) slug="apimidpf"; resource_description="API Management Identity Provider Facebook" ;;
                *identity_provider_google*) slug="apimidpg"; resource_description="API Management Identity Provider Google" ;;
                *identity_provider_microsoft*) slug="apimidpm"; resource_description="API Management Identity Provider Microsoft" ;;
                *identity_provider_twitter*) slug="apimidpt"; resource_description="API Management Identity Provider Twitter" ;;
                *named_value*) slug="apimnv"; resource_description="API Management Named Value" ;;
                *openid_connect_provider*) slug="apimoidc"; resource_description="API Management OpenID Connect Provider" ;;
                *product_api*) slug="apimpa"; resource_description="API Management Product API" ;;
                *product_group*) slug="apimpg"; resource_description="API Management Product Group" ;;
                *product_policy*) slug="apimpp"; resource_description="API Management Product Policy" ;;
                *property*) slug="apimprop"; resource_description="API Management Property" ;;
                *) slug="apim"; resource_description="API Management Service" ;;
            esac
            ;;
            
        # Storage resources  
        *storage*)
            min_length=3
            max_length=63
            validation_regex="\"^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$\""
            scope="parent"
            dashes=true
            lowercase=true
            regex="\"[^a-z0-9-]\""
            resource_provider_namespace="Microsoft.Storage"
            case "$name" in
                *blob*) slug="blob"; resource_description="Storage Blob" ;;
                *queue*) slug="stq"; resource_description="Storage Queue" ;;
                *table*) slug="stt"; resource_description="Storage Table" ;;
                *) slug="st"; resource_description="Storage Account" ;;
            esac
            ;;
            
        # Network resources
        *network*|*dns*|*private_dns*)
            min_length=1
            max_length=80
            validation_regex="\"^[a-zA-Z0-9][a-zA-Z0-9._-]{0,78}[a-zA-Z0-9_]$\""
            scope="resourceGroup"
            dashes=true
            lowercase=false
            regex="\"[^a-zA-Z0-9._-]\""
            resource_provider_namespace="Microsoft.Network"
            case "$name" in
                *dns_a_record*) slug="dnsa"; resource_description="DNS A Record" ;;
                *dns_aaaa_record*) slug="dnsaaaa"; resource_description="DNS AAAA Record" ;;
                *dns_cname_record*) slug="dnscname"; resource_description="DNS CNAME Record" ;;
                *dns_mx_record*) slug="dnsmx"; resource_description="DNS MX Record" ;;
                *dns_txt_record*) slug="dnstxt"; resource_description="DNS TXT Record" ;;
                *private_dns_*) slug="pdns"; resource_description="Private DNS Zone" ;;
                *network_interface*) slug="nic"; resource_description="Network Interface" ;;
                *network_security_group*) slug="nsg"; resource_description="Network Security Group" ;;
                *) slug="net"; resource_description="Network Resource" ;;
            esac
            ;;
            
        # Virtual Machine resources
        *virtual_machine*|*vm*)
            min_length=1
            max_length=80
            validation_regex="\"^[a-zA-Z0-9][a-zA-Z0-9._-]{0,78}[a-zA-Z0-9]$\""
            scope="resourceGroup"
            dashes=true
            lowercase=false
            regex="\"[^a-zA-Z0-9._-]\""
            resource_provider_namespace="Microsoft.Compute"
            case "$name" in
                *scale_set*) slug="vmss"; resource_description="Virtual Machine Scale Set" ;;
                *extension*) slug="vmext"; resource_description="Virtual Machine Extension" ;;
                *) slug="vm"; resource_description="Virtual Machine" ;;
            esac
            ;;
            
        # Database resources
        *sql*|*database*|*cosmosdb*)
            min_length=1
            max_length=128
            validation_regex="\"^[a-zA-Z0-9][a-zA-Z0-9._-]{0,126}[a-zA-Z0-9]$\""
            scope="parent"
            dashes=true
            lowercase=false
            regex="\"[^a-zA-Z0-9._-]\""
            case "$name" in
                *cosmosdb*) 
                    resource_provider_namespace="Microsoft.DocumentDB"
                    slug="cosmos"
                    resource_description="Cosmos DB Resource" 
                    ;;
                *mssql*|*sql_server*) 
                    resource_provider_namespace="Microsoft.Sql"
                    slug="sql"
                    resource_description="SQL Server Resource" 
                    ;;
                *mysql*) 
                    resource_provider_namespace="Microsoft.DBforMySQL"
                    slug="mysql"
                    resource_description="MySQL Server Resource" 
                    ;;
                *postgresql*) 
                    resource_provider_namespace="Microsoft.DBforPostgreSQL"
                    slug="psql"
                    resource_description="PostgreSQL Server Resource" 
                    ;;
                *) slug="db"; resource_description="Database Resource" ;;
            esac
            ;;
            
        # Default case - generic Azure resource
        *)
            min_length=1
            max_length=80
            validation_regex="\"^[a-zA-Z0-9][a-zA-Z0-9._-]{0,78}[a-zA-Z0-9]$\""
            scope="resourceGroup"
            dashes=true
            lowercase=false
            regex="\"[^a-zA-Z0-9._-]\""
            
            # Generate slug from resource name
            slug=$(echo "$name" | sed 's/azurerm_//' | sed 's/_//g' | cut -c1-8)
            resource_description="Azure $(echo "$name" | sed 's/azurerm_//' | tr '_' ' ' | sed 's/\b\w/\U&/g')"
            ;;
    esac
    
    # Create new resource object
    local new_resource
    if [ -n "$resource_provider_namespace" ]; then
        new_resource=$(jq -n \
            --arg name "$name" \
            --argjson min_length "$min_length" \
            --argjson max_length "$max_length" \
            --arg validation_regex "$validation_regex" \
            --arg scope "$scope" \
            --arg slug "$slug" \
            --argjson dashes "$dashes" \
            --argjson lowercase "$lowercase" \
            --arg regex "$regex" \
            --arg resource_description "$resource_description" \
            --arg resource_provider_namespace "$resource_provider_namespace" \
            '{
                name: $name,
                min_length: $min_length,
                max_length: $max_length,
                validation_regex: $validation_regex,
                scope: $scope,
                slug: $slug,
                dashes: $dashes,
                lowercase: $lowercase,
                regex: $regex,
                official: {
                    slug: $slug,
                    resource: $resource_description,
                    resource_provider_namespace: $resource_provider_namespace
                }
            }')
    else
        new_resource=$(jq -n \
            --arg name "$name" \
            --argjson min_length "$min_length" \
            --argjson max_length "$max_length" \
            --arg validation_regex "$validation_regex" \
            --arg scope "$scope" \
            --arg slug "$slug" \
            --argjson dashes "$dashes" \
            --argjson lowercase "$lowercase" \
            --arg regex "$regex" \
            --arg resource_description "$resource_description" \
            '{
                name: $name,
                min_length: $min_length,
                max_length: $max_length,
                validation_regex: $validation_regex,
                scope: $scope,
                slug: $slug,
                dashes: $dashes,
                lowercase: $lowercase,
                regex: $regex,
                official: {
                    slug: $slug,
                    resource: $resource_description
                }
            }')
    fi
    
    # Add to array
    local temp_file=$(mktemp)
    jq --argjson new_resource "$new_resource" '. += [$new_resource]' "$RESDEF" > "$temp_file"
    
    # Validate the result
    if jq empty "$temp_file" 2>/dev/null; then
        mv "$temp_file" "$RESDEF"
        echo -e "${GREEN}✅ Successfully added $name${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to add $name - JSON validation failed${NC}"
        rm -f "$temp_file"
        return 1
    fi
}

# Main execution
echo -e "${BLUE}🚀 Adding Azure resources from: $RESOURCE_LIST${NC}"
echo "========================================"

# Count total resources
TOTAL_RESOURCES=$(wc -l < "$RESOURCE_LIST")
echo -e "${BLUE}📊 Found $TOTAL_RESOURCES resources to process${NC}"
echo ""

# Process all resources
ADDED_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0
PROCESSED_COUNT=0

while IFS= read -r resource_name; do
    # Skip empty lines and comments
    if [[ -n "$resource_name" && ! "$resource_name" =~ ^[[:space:]]*# ]]; then
        PROCESSED_COUNT=$((PROCESSED_COUNT + 1))
        echo -e "${BLUE}[$PROCESSED_COUNT/$TOTAL_RESOURCES] Processing $resource_name...${NC}"
        
        if add_resource_intelligent "$resource_name"; then
            if resource_exists "$resource_name"; then
                ADDED_COUNT=$((ADDED_COUNT + 1))
            else
                SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
            fi
        else
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
        
        # Progress indicator every 10 resources
        if [ $((PROCESSED_COUNT % 10)) -eq 0 ]; then
            echo -e "${YELLOW}📊 Progress: $PROCESSED_COUNT/$TOTAL_RESOURCES processed (Added: $ADDED_COUNT, Skipped: $SKIPPED_COUNT, Failed: $FAILED_COUNT)${NC}"
        fi
    fi
done < "$RESOURCE_LIST"

echo ""
echo -e "${BLUE}🔍 Final validation...${NC}"
if jq empty "$RESDEF" 2>/dev/null; then
    echo -e "${GREEN}✅ JSON validation passed${NC}"
    
    # Count final resources
    FINAL_COUNT=$(jq length "$RESDEF")
    echo ""
    echo -e "${GREEN}🎉 COMPLETION SUMMARY:${NC}"
    echo "====================="
    echo -e "${GREEN}✅ Resources added: $ADDED_COUNT${NC}"
    echo -e "${YELLOW}ℹ️  Resources skipped (already existed): $SKIPPED_COUNT${NC}"
    echo -e "${RED}❌ Resources failed: $FAILED_COUNT${NC}"
    echo -e "${BLUE}📊 Total resources processed: $PROCESSED_COUNT${NC}"
    echo -e "${BLUE}📋 Total resources in database: $FINAL_COUNT${NC}"
    echo ""
    echo -e "${GREEN}✅ Successfully processed Azure resources!${NC}"
    echo -e "${BLUE}📁 Updated file: $RESDEF${NC}"
    echo -e "${BLUE}📂 Backup created with timestamp${NC}"
    
else
    echo -e "${RED}❌ JSON validation failed - check the file manually${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}🎯 Next steps:${NC}"
echo "1. Run update_resource_status.sh to update the README"
echo "2. Test the new resource definitions"
echo "3. Commit the changes"
