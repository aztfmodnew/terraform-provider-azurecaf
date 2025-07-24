# CAF Resource Abbreviations Compliance Update

## Overview

This document describes the changes made to align the terraform-provider-azurecaf with the official Microsoft Cloud Adoption Framework (CAF) resource abbreviation recommendations.

## Issues Identified

Several resources in `resourceDefinition.json` were not following the official CAF abbreviation recommendations:

1. **Front Door (Classic)**: Using `fd` instead of official CAF `afd`
2. **Azure Automation Resources**: Using `automati` instead of official CAF `aa`
3. **App Configuration Resources**: Using `appconfi` instead of official CAF `appcs`
4. **Active Directory Resources**: Using `activedi` instead of official CAF `aad`

## Changes Made

### 1. Front Door Resources
- **Resource**: `azurerm_frontdoor`
- **Changed**: `slug` from `fd` to `afd`
- **Changed**: `official.slug` from `fd` to `afd`
- **Rationale**: Aligns with CAF recommendation for Front Door (classic)

### 2. Azure Automation Resources
Updated all automation resources to use the correct CAF abbreviation `aa`:

- `azurerm_automation_account`
- `azurerm_automation_certificate`
- `azurerm_automation_connection_type`
- `azurerm_automation_credential`
- `azurerm_automation_hybrid_runbook_worker`
- `azurerm_automation_hybrid_runbook_worker_group`
- `azurerm_automation_module`
- `azurerm_automation_runbook`
- `azurerm_automation_schedule`
- `azurerm_automation_source_control`
- `azurerm_automation_software_update_configuration`
- `azurerm_automation_variable_bool`
- `azurerm_automation_variable_datetime`
- `azurerm_automation_variable_int`
- `azurerm_automation_variable_object`
- `azurerm_automation_variable_string`
- `azurerm_automation_watcher`
- `azurerm_automation_webhook`

**Changes**:
- Fixed `official.slug` from `automati` to `aa`
- Added missing `official.slug` fields where they were absent

### 3. App Configuration Resources
- **Resources**: `azurerm_app_configuration_feature`, `azurerm_app_configuration_key`
- **Changed**: `official.slug` from `appconfi` to `appcs`
- **Rationale**: Aligns with CAF recommendation for App Configuration store

### 4. Active Directory Resources
- **Changed**: `official.slug` from `activedi` to `aad`
- **Rationale**: Aligns with CAF recommendation for Azure Active Directory

## Testing

Added comprehensive tests to ensure CAF compliance:

### Test Files Created
- `azurecaf/resource_caf_abbreviations_test.go`: Contains tests to validate CAF abbreviation compliance

### Test Functions
1. **TestResourceAbbreviationsCAFCompliance**: Tests specific resources for correct slug and official slug values
2. **TestCAFOfficialAbbreviations**: Validates all automation resources use `aa` abbreviation
3. **TestAppConfigurationCAFAbbreviation**: Validates App Configuration resources use `appcs` abbreviation

### Test Results
All tests pass, confirming that:
- Resource abbreviations follow CAF recommendations
- Official slugs are correctly set
- No regressions were introduced

## Impact Assessment

### Breaking Changes
**None** - These changes only affect the official CAF abbreviation mappings and do not change the actual resource slugs used for naming (except Front Door which was updated to the correct CAF standard).

### Benefits
1. **Compliance**: Full alignment with Microsoft CAF abbreviation recommendations
2. **Consistency**: Standardized abbreviations across all automation resources
3. **Documentation**: Clear mapping between resource types and official CAF abbreviations
4. **Future-proofing**: Easier maintenance and updates as CAF evolves

## References

- [Microsoft Cloud Adoption Framework - Abbreviation recommendations for Azure resources](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Define your naming convention](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)

## Files Modified

1. `resourceDefinition.json` - Updated resource definitions with correct CAF abbreviations
2. `azurecaf/models_generated.go` - Regenerated from updated JSON (via `go generate`)
3. `azurecaf/resource_caf_abbreviations_test.go` - New test file for CAF compliance validation
