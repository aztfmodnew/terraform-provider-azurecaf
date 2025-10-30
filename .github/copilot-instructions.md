# Azure CAF Terraform Provider - AI Agent Instructions

## Project Overview
This is a Terraform provider for Azure resource naming following Cloud Adoption Framework (CAF) guidelines. It generates compliant names for 631+ Azure resource types with validation, cleaning, and multiple naming conventions.

**Origin**: Fork of aztfmod/azurecaf starting from v1.2.28 with independent evolution.

## Architecture

### Core Components
- **`resourceDefinition.json`**: Single source of truth for ALL Azure resource naming rules (17K+ lines, 631+ resources)
  - Each entry defines: `name`, `min_length`, `max_length`, `validation_regex`, `scope`, `slug`, `dashes`, `lowercase`, `regex`, `official` block
  - Official slugs from Microsoft CAF docs stored in `official.slug` field
- **`gen.go`**: Code generator that reads resourceDefinition.json → generates `models_generated.go`
  - Run via `go generate` (see go:generate directive in main.go)
- **`azurecaf/` package**: Core provider logic
  - `resource_name.go` / `data_name.go`: Main name generation resources
  - `resource_naming_convention.go`: Legacy resource (deprecated, use azurecaf_name instead)
  - `models.go`: Core constants (naming conventions, regex patterns)
  - `provider.go`: Terraform provider registration

### Naming Conventions (models.go constants)
1. **`cafclassic`**: `[prefix]-[slug]-[name]-[suffix]` (default CAF)
2. **`cafrandom`**: Pads with random chars to max length
3. **`random`**: Fully random within Azure constraints
4. **`passthrough`**: Validation-only, no modification

### Key Data Flows
1. User defines resource → Provider reads resourceDefinition.json → Validates constraints → Generates name
2. Code changes to resourceDefinition.json → Run `go generate` → Updates models_generated.go → Rebuild

## Development Workflows

### Testing (via Makefile)
```bash
make unittest              # Fast unit tests
make test_integration      # TF_ACC=1 integration tests
make test_all_resources    # Test ALL 631 resource types (30min timeout)
make test_ci               # CI suite: unit + coverage + validation
make test_coverage_html    # Generate HTML coverage report
```

**Critical**: Always run `make test_resource_definitions` after modifying resourceDefinition.json to validate completeness.

### Adding/Modifying Resources
1. **Edit resourceDefinition.json** with new/updated resource definition
2. **Verify official slug** against [Microsoft CAF docs](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
3. **Run code generation**: `go generate`
4. **Test**: `make test_resource_definitions && make unittest`
5. **Update CHANGELOG.md** with changes and impact assessment

### Slug Validation Process
When updating slugs, ALWAYS verify against official Microsoft documentation:
- Use `official.slug` field to store Microsoft CAF recommendations
- Cross-reference with https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
- Document source in commit message if updating based on new Microsoft guidance

## Project-Specific Conventions

### Resource Definition Schema
```json
{
  "name": "azurerm_resource_type",        // Terraform resource type
  "min_length": 3,                         // Azure minimum
  "max_length": 24,                        // Azure maximum
  "validation_regex": "\"^[a-z0-9]+$\"",  // Escaped regex for validation
  "scope": "global",                       // global|resourceGroup|parent
  "slug": "st",                            // Short abbreviation
  "dashes": false,                         // Allow dashes in name
  "lowercase": true,                       // Force lowercase
  "regex": "\"[^0-9a-z]\"",               // Char cleaning regex (escaped)
  "official": {                            // Microsoft CAF official data
    "slug": "st",
    "resource": "Storage account",
    "resource_provider_namespace": "Microsoft.Storage/storageAccounts"
  }
}
```

### Test Organization
- `*_test.go` files organized by convention: `cafclassic_test.go`, `cafrandom_test.go`, `passthrough_test.go`
- Integration tests require `TF_ACC=1` environment variable
- `integration_all_resource_types_test.go`: Comprehensive validation of ALL resources
- `resource_coverage_analysis_test.go`: Coverage reporting per resource type

### Documentation Structure
- `/docs/data-sources/`: Data source documentation (prefer over resources)
- `/docs/resources/`: Resource documentation
- `/examples/`: Working Terraform examples (tested via `run_examples.sh`)
- Each example should demonstrate a specific pattern or use case

## Critical Knowledge

### Data Source vs Resource
**Prefer data sources** (`data "azurecaf_name"`) for single-name generation:
- Evaluated at plan time → names visible before apply
- Example: `data "azurecaf_name" "storage" { ... }`

**Use resources** (`resource "azurecaf_name"`) for multi-resource naming:
- Supports `resource_types` parameter for generating multiple related names
- Example: Generate app service + plan + insights names together

### Regex Escaping
resourceDefinition.json stores regexes as **JSON strings** → double-escaped:
- Go string: `[^0-9a-z]`
- JSON string: `"[^0-9a-z]"`
- In validation_regex: `"\"^[a-z0-9]+$\""`

### Environment Variables for Testing
```bash
CHECKPOINT_DISABLE=1           # Disable Terraform checkpoint checks
TF_IN_AUTOMATION=1            # Suppress interactive prompts
TF_ACC=1                      # Enable acceptance tests
TF_CLI_ARGS_init="-upgrade=false"  # Prevent provider upgrades during tests
```

## Common Tasks

### Validate All Resource Definitions
```bash
make test_resource_definitions
```

### Add New Resource Type
1. Add entry to `resourceDefinition.json` with all required fields
2. Verify official slug from Microsoft docs
3. Run `go generate` to update generated code
4. Add test case in `integration_all_resource_types_test.go`
5. Test: `make test_all_resources`
6. Update CHANGELOG.md

### Update Existing Slug
1. Locate resource in `resourceDefinition.json`
2. Verify new slug against Microsoft CAF documentation
3. Update both `slug` and `official.slug` fields
4. Run `go generate && make unittest`
5. Document in CHANGELOG.md with rationale

## Quality Standards

### MUST DO
- **Update CHANGELOG.md** with ALL changes and assess impact
- **Write tests** for new functionality (unit + integration if applicable)
- **Run `make test_ci`** before committing
- **Validate resource definitions** after JSON changes
- **Document** new resources/features in `/docs/`

### Code Style
- Follow standard Go formatting (`go fmt`)
- Use descriptive variable names (avoid single-letter except loops)
- Add comments for non-obvious logic, especially regex patterns
- Keep functions focused (< 50 lines when possible)

### Testing Requirements
- Unit tests for all new functions
- Integration tests for resource/data source changes
- Coverage > 80% for new code
- All 631 resource types must validate without errors

## External Dependencies
- Terraform Plugin SDK v2
- Go 1.21+
- Microsoft CAF documentation for slug validation
- Azure naming rules per resource type (dynamic, check Azure docs)