# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v2.0.0]

### Fixed
- **CAF Prefix Compliance**: Fixed 'general' and 'general_safe' resources to use valid CAF slugs ('gen' and 'gensafe') and updated their official slug fields to pass CAF prefix validation tests.
- **CRITICAL**: Achieved 100% CAF Compliance with zero duplicates
  - **Load Balancer**: Updated `azurerm_lb` slug from `lb` to `lbe` (external load balancer default)
  - **Logic App Standard**: Updated `azurerm_logic_app_standard` slug from `logic` to `logicstd` to differentiate from workflow
  - **SQL Server Legacy**: Updated `azurerm_sql_server` slug from `sql` to `sqlsrv` to differentiate from `azurerm_mssql_server`
  - **Perfect Optimization**: Eliminated all remaining duplicate slugs (0 duplicates from 2 groups)
  - **CAF Validation Scripts**: Updated validation logic to properly handle differentiated resources
  - **Workflow Integration**: Enhanced CAF correction scripts to maintain compliance automatically
- **CAF Abbreviations Compliance**: Updated resource definitions to follow official Microsoft Cloud Adoption Framework abbreviation recommendations
  - Fixed Front Door (classic) to use official CAF abbreviation `afd` instead of `fd`
  - Updated all Azure Automation resources to use official CAF abbreviation `aa` instead of `automati`
  - Fixed App Configuration resources to use official CAF abbreviation `appcs` instead of `appconfi`
  - Updated Active Directory resources to use official CAF abbreviation `aad` instead of `activedi`
  - Added missing official slug mappings for automation resources that lacked them
  - Comprehensive test coverage added to ensure ongoing CAF compliance

### Added
- **MAJOR**: Authoritative Microsoft CAF Compliance System with real-time corrections
  - Complete 154-resource official CAF mapping from Microsoft Learn documentation
  - Authoritative workflow that enforces official CAF abbreviations with absolute priority
  - Intelligent duplicate resolution algorithm with meaningful slug generation
  - Automatic backup creation before applying corrections
  - Real-time CAF compliance validation and correction pipeline
  - Enhanced conflict resolution with semantic slug naming (webapp, ch, gw, cd, func, etc.)
  - Comprehensive reporting system with detailed compliance metrics
- **Enhanced Azure Resource Sync Tool v4.0**: Complete workflow automation
  - Integrated CAF validation, duplicate detection, and optimization
  - Streamlined workflow commands: sync, test, docs, analyze, status, auto-add, cleanup
  - Hashicorp Registry deep linking with improved resource extraction
  - Automated missing resource detection and prioritized addition
  - Comprehensive documentation generation with Azure-specific categorization
- **CAF Compliance Automation**: Production-ready validation and correction system
  - Automated application of 19+ CAF corrections per sync cycle
  - Reduced duplicate slugs from 10 groups to 1 (90% improvement)
  - Increased unique slugs from 1,170 to 1,184 (14 additional unique resources)
  - Idempotent operations ensuring system stability across multiple executions
- **CAF Abbreviations Test Suite**: Comprehensive test coverage for CAF compliance
  - `TestResourceAbbreviationsCAFCompliance`: Tests specific resources for correct abbreviations
  - `TestCAFOfficialAbbreviations`: Validates all automation resources use correct CAF abbreviations
  - `TestAppConfigurationCAFAbbreviation`: Validates App Configuration resources use correct abbreviations

### Changed
- **BREAKING**: Enhanced sync workflow to apply permanent CAF corrections
  - `enhanced_sync_official_resources_caf.sh` now applies and saves corrections directly
  - Eliminated audit-only mode in favor of authoritative correction system
  - Official CAF abbreviations now take absolute priority over existing slugs
  - Improved conflict resolution generates semantic suffixes instead of truncated names
- **Workflow Optimization**: Streamlined and consolidated automation scripts
  - Integrated Python optimization logic directly into bash workflow
  - Removed redundant automation scripts for simplified maintenance
  - Enhanced JQ-based processing for better performance and reliability
  - Improved error handling and rollback capabilities

### Fixed
- **Go Version Alignment**: Resolved conflicting Go version declarations in go.mod
  - Changed from conflicting `go 1.23.0` and `toolchain go1.24.4` to unified `go 1.24`
  - Eliminates version mismatch errors during builds
  - Ensures consistent Go toolchain usage across all environments
  - Impact: Medium - Fixes build reliability and development environment consistency
- **Linting Issues**: Fixed non-constant format string errors in logging and error handling
  - Fixed `fmt.Errorf` call in `resource_name.go` to use proper format string
  - Fixed `log.Printf` call in `resource_naming_convention.go` to use proper format string
  - Resolves Go vet warnings and ensures build passes all checks
  - Impact: Low - Improves code quality and eliminates build warnings
- **CAF Compliance**: Addressed systematic naming convention inconsistencies
  - Fixed Hashicorp resource extraction to prevent false azurerm_com_ artifacts
  - Improved regex filtering to exclude URLs and non-resource patterns
  - Enhanced resource validation to ensure Azure Resource Manager compatibility
  - Impact: High - Ensures reliable resource synchronization and CAF compliance

## [v1.2.30]

### Fixed
- **CI/CD Pipeline**: Fixed GoReleaser failure due to git tag mismatch and dirty state
  - Removed problematic auto-commit step that was creating commits during release process
  - Fixed generated file timestamp stability to prevent dirty git state in CI
  - Added `fetch-depth: 0` to GitHub Actions checkout for full git history
  - Stabilized `models_generated.go` timestamp format to be environment-independent
  - Resolves GoReleaser errors: "git tag was not made against commit" and "git is in a dirty state"
  - Impact: High - Fixes release automation and ensures reliable tag-based releases
- **GoReleaser Configuration**: Updated GoReleaser configuration to v2 format
  - Added `version: 2` to support GoReleaser v2.x
  - Changed `changelog.skip: true` to `changelog.disable: true`
  - Removed deprecated `archives.format` property to use automatic format selection
  - Fixes release pipeline compatibility with goreleaser-action@v6
- **GitHub Workflow**: Fixed workflow step ordering and improved GPG key import
  - Moved "Set up Go" step before "Install tfproviderlint" to resolve dependency issues
  - Enhanced GPG key import with additional configuration options
  - Added `continue-on-error: true` for GPG import to handle missing secrets gracefully
  - Improved Git signing configuration with proper trust levels
- **README Display**: Fixed GitHub repository homepage README display issue
  - Converted README.md line endings from Windows-style (CRLF) to Unix-style (LF)
  - Renamed .github/README.md to .github/README-workflows.md to prevent GitHub display conflict
  - Resolves issue where GitHub was showing workflows documentation instead of main project README
  - Ensures proper display of comprehensive project documentation on repository homepage
- **Code Generation**: Removed timestamp from generated `models_generated.go` file
  - Eliminated dynamic timestamp that was causing git dirty state during CI/CD
  - Removed `GeneratedTime` field from template data structure
  - Updated template to exclude timestamp comment from generated code
  - Impact: High - Prevents GoReleaser "git is in a dirty state" errors during releases
  - Resolves: CI builds no longer modify tracked files during generation process

### Security
- **CRITICAL**: Fixed security vulnerabilities in Go dependencies:
  - Updated `golang.org/x/net` from v0.23.0 to v0.38.0 to resolve:
    - GO-2025-3595: Cross-site Scripting vulnerability in html package
    - GO-2025-3503: HTTP Proxy bypass using IPv6 Zone IDs
    - GO-2024-3333: Non-linear parsing vulnerability in html package
  - Updated `golang.org/x/crypto` from v0.21.0 to v0.36.0
  - Updated `golang.org/x/sys` from v0.18.0 to v0.31.0
  - Updated `golang.org/x/text` from v0.14.0 to v0.23.0
- Updated Go toolchain from 1.20 to 1.23.0 with Go 1.24.4 for enhanced security
- **SECURITY**: Fixed loose POSIX file permissions in E2E testing framework:
  - Changed directory permissions from 0755 to 0750 (removed world access)
  - Changed executable file permissions from 0755 to 0750 (removed world access)
  - Affected files: `e2e/framework/e2e_test.go`, `e2e/framework/framework.go`

### Added
- **E2E Testing Infrastructure**: Complete end-to-end testing framework
  - Comprehensive test suite covering all provider functionality
  - Import functionality testing with real Terraform state management
  - Data source validation with cross-platform compatibility
  - Naming convention testing across multiple resource types
  - Multi-resource type testing for complex scenarios
- **CI/CD Integration**: Full GitHub Actions integration for automated testing
  - Quick E2E tests on every push (~10-15 seconds)
  - Full E2E tests on pull requests (~25-30 seconds) 
  - Manual workflow dispatch with selective test execution
  - Smart triggering based on file changes
- **Local CI Simulation**: Act integration for local CI environment testing
  - Complete workflow validation before pushing to GitHub
  - Docker-based CI environment simulation
  - Cross-platform testing (macOS M-series compatibility)
  - Comprehensive testing scripts for development workflow
- **Testing Scripts**: Production-ready testing automation
  - `scripts/complete-e2e-validation.sh` - Full validation pipeline
  - `scripts/quick-ci-test.sh` - Quick CI environment validation
  - `scripts/test-ci-with-act.sh` - Interactive CI simulation
  - `scripts/validate-ci-e2e.sh` - Enhanced local + CI testing
- **Documentation**: Complete testing and CI/CD documentation
  - `E2E_IMPLEMENTATION_SUMMARY.md` - Implementation overview
  - `ACT_TESTING_GUIDE.md` - Local CI testing guide
  - `CI_E2E_INTEGRATION.md` - CI/CD integration documentation
  - `e2e/README.md` - E2E testing framework documentation
- **GitHub Copilot Integration**: Enhanced development workflow automation
  - `copilot-setup-steps.yml` - GitHub Actions workflow for Copilot environment setup
  - Automated Go and Terraform environment configuration for Copilot sessions
  - Streamlined development environment preparation with proper versioning
- **MAJOR**: Comprehensive end-to-end (E2E) testing framework for real-world validation
  - Complete E2E test suite covering provider build → Terraform usage → Azure integration
  - Mock Azure RM provider integration for testing without actual Azure API calls
  - Automated provider compilation and local installation testing
  - Azure resource naming compliance validation for all supported resource types
  - Support for all naming conventions (cafclassic, cafrandom, random, passthrough)
  - Edge case testing including length limits, special characters, and error conditions
  - Integration testing with azurerm provider using mock scenarios
  - Test runner CLI with flexible execution options and debugging support
  - Comprehensive documentation and troubleshooting guides
- New Makefile targets for E2E testing:
  - `test_e2e` - Complete E2E test suite
  - `test_e2e_quick` - Fast E2E tests for CI/CD
  - `test_e2e_integration` - AzureRM integration tests
  - `test_e2e_naming` - Naming convention validation
  - `test_e2e_edge_cases` - Edge case scenarios
  - `test_e2e_verbose` - Verbose output for debugging
  - `test_complete_with_e2e` - Complete testing including E2E
- Official Azure Cloud Adoption Framework documentation mapping for 55 resources
- New nested `official` object structure containing Azure CAF documentation attributes
- Comprehensive official resource provider namespace mappings
- GitHub Copilot Agent firewall configuration for improved CI/CD testing
- Enhanced resource validation and testing framework
- Comprehensive CI testing pipeline with resource validation, matrix testing, and coverage analysis
- Advanced Makefile targets for comprehensive testing (`test_ci`, `test_ci_fast`, `test_ci_complete`)
- Shared testing utilities to reduce code duplication (SonarQube compliance)
- Refactored naming convention tests to use centralized test helpers

### Changed
- **BREAKING**: Consolidated `resourceDefinition.json` and `resourceDefinition_out_of_docs.json` into single unified file
- **BREAKING**: Refactored JSON structure to nest official Azure CAF attributes under `official` object
- Updated resource definitions to include proper Azure CAF documentation mapping for key resources:
  - API Management service instance (`apim`) - Microsoft.ApiManagement/service
  - AKS cluster (`aks`) - Microsoft.ContainerService/managedClusters
  - Container apps (`ca`) - Microsoft.App/containerApps
  - Application gateway (`agw`) - Microsoft.ApplicationGateway/applicationGateways
  - Virtual network (`vnet`) - Microsoft.Network/virtualNetworks
  - Storage account (`st`) - Microsoft.Storage/storageAccounts
  - And 49 additional resources with official mappings
- Simplified resource definition structure for non-official resources (only `resource` field in `official` object)
- Enhanced code generation logic to handle nested official attributes
- Updated documentation and contribution guidelines to reflect new structure

### Fixed
- DNS blocking issues with `checkpoint-api.hashicorp.com` during integration tests
- Resource provider namespace accuracy for officially documented Azure resources
- Resource generation and validation processes for unified file structure

### Removed
- `resourceDefinition_out_of_docs.json` file (consolidated into main file)
- Legacy flat structure for official documentation attributes

## Migration Guide

### For Contributors
- Use the new nested `official` object structure when adding or modifying resources
- Resources in official Azure CAF documentation should include `slug`, `resource`, and `resource_provider_namespace` in the `official` object
- Resources not in official documentation should only include the `resource` field in the `official` object

### For Consumers
- The root-level `slug` field remains unchanged for backward compatibility
- New official documentation data is available through the `official` object
- No breaking changes to existing provider functionality

## Statistics
- **Total Resources**: 395 (previously 364 + 31 across two files)
- **Official Azure CAF Mappings**: 55 resources with complete official documentation data
- **Non-Official Resources**: 340 resources with simplified official structure
- **Files Consolidated**: 2 → 1 resource definition file

---

*This changelog consolidates major structural changes made to the terraform-provider-azurecaf resource definitions and documentation mapping. Future releases will continue to document changes in this format for semantic versioning purposes.*