package azurecaf

import (
	"encoding/json"
	"io/ioutil"
	"path/filepath"
	"testing"
)

// ResourceJSON represents the JSON structure from resourceDefinition.json
type ResourceJSON struct {
	Name            string `json:"name"`
	MinLength       int    `json:"min_length"`
	MaxLength       int    `json:"max_length"`
	ValidationRegex string `json:"validation_regex"`
	Scope           string `json:"scope"`
	Slug            string `json:"slug"`
	Dashes          bool   `json:"dashes"`
	Lowercase       bool   `json:"lowercase"`
	Regex           string `json:"regex"`
	Official        struct {
		Slug                      string `json:"slug,omitempty"`
		Resource                  string `json:"resource,omitempty"`
		ResourceProviderNamespace string `json:"resource_provider_namespace,omitempty"`
	} `json:"official,omitempty"`
}

// loadResourceDefinitionsFromJSON loads the resource definitions from the JSON file
func loadResourceDefinitionsFromJSON(t *testing.T) []ResourceJSON {
	// Get the current directory
	currentDir := "."
	jsonPath := filepath.Join(currentDir, "..", "resourceDefinition.json")
	
	data, err := ioutil.ReadFile(jsonPath)
	if err != nil {
		t.Fatalf("Failed to read resourceDefinition.json: %v", err)
	}
	
	var resources []ResourceJSON
	err = json.Unmarshal(data, &resources)
	if err != nil {
		t.Fatalf("Failed to parse resourceDefinition.json: %v", err)
	}
	
	return resources
}

// TestResourceAbbreviationsCAFCompliance tests that resource abbreviations follow
// the official Microsoft Cloud Adoption Framework (CAF) recommendations
func TestResourceAbbreviationsCAFCompliance(t *testing.T) {
	resources := loadResourceDefinitionsFromJSON(t)
	
	tests := []struct {
		resourceName     string
		expectedSlug     string
		expectedOfficial string
		description      string
	}{
		{
			resourceName:     "azurerm_frontdoor",
			expectedSlug:     "afd",
			expectedOfficial: "afd",
			description:      "Front Door (classic) should use CAF abbreviation 'afd'",
		},
		{
			resourceName:     "azurerm_automation_account",
			expectedSlug:     "aa",
			expectedOfficial: "aa",
			description:      "Azure Automation Account should use CAF abbreviation 'aa'",
		},
		{
			resourceName:     "azurerm_automation_connection_type",
			expectedSlug:     "aacontype",
			expectedOfficial: "aa",
			description:      "Azure Automation Connection Type official should be 'aa'",
		},
		{
			resourceName:     "azurerm_automation_hybrid_runbook_worker",
			expectedSlug:     "aahrbwkr",
			expectedOfficial: "aa",
			description:      "Azure Automation Hybrid Runbook Worker official should be 'aa'",
		},
		{
			resourceName:     "azurerm_app_configuration_feature",
			expectedSlug:     "acfeat",
			expectedOfficial: "appcs",
			description:      "App Configuration Feature official should be 'appcs'",
		},
		{
			resourceName:     "azurerm_app_configuration_key",
			expectedSlug:     "ackey",
			expectedOfficial: "appcs",
			description:      "App Configuration Key official should be 'appcs'",
		},
	}

	// Create a map for easy lookup
	resourceMap := make(map[string]ResourceJSON)
	for _, r := range resources {
		resourceMap[r.Name] = r
	}

	for _, tt := range tests {
		t.Run(tt.resourceName, func(t *testing.T) {
			resource, exists := resourceMap[tt.resourceName]
			if !exists {
				t.Fatalf("Resource %s not found in resourceDefinition.json", tt.resourceName)
			}

			if resource.Slug != tt.expectedSlug {
				t.Errorf("Resource %s: expected slug %s, got %s", tt.resourceName, tt.expectedSlug, resource.Slug)
			}

			if resource.Official.Slug != tt.expectedOfficial {
				t.Errorf("Resource %s: expected official slug %s, got %s", tt.resourceName, tt.expectedOfficial, resource.Official.Slug)
			}

			t.Logf("✓ %s: %s", tt.resourceName, tt.description)
		})
	}
}

// TestCAFOfficialAbbreviations validates that all automation resources use
// the correct CAF abbreviation 'aa' in their official slug
func TestCAFOfficialAbbreviations(t *testing.T) {
	resources := loadResourceDefinitionsFromJSON(t)
	
	automationResources := []string{
		"azurerm_automation_account",
		"azurerm_automation_certificate",
		"azurerm_automation_connection_type",
		"azurerm_automation_credential",
		"azurerm_automation_hybrid_runbook_worker",
		"azurerm_automation_hybrid_runbook_worker_group",
		"azurerm_automation_module",
		"azurerm_automation_runbook",
		"azurerm_automation_schedule",
		"azurerm_automation_source_control",
		"azurerm_automation_software_update_configuration",
		"azurerm_automation_variable_bool",
		"azurerm_automation_variable_datetime",
		"azurerm_automation_variable_int",
		"azurerm_automation_variable_object",
		"azurerm_automation_variable_string",
		"azurerm_automation_watcher",
		"azurerm_automation_webhook",
	}

	// Create a map for easy lookup
	resourceMap := make(map[string]ResourceJSON)
	for _, r := range resources {
		resourceMap[r.Name] = r
	}

	for _, resourceName := range automationResources {
		t.Run(resourceName, func(t *testing.T) {
			resource, exists := resourceMap[resourceName]
			if !exists {
				t.Fatalf("Resource %s not found in resourceDefinition.json", resourceName)
			}

			if resource.Official.Slug != "aa" {
				t.Errorf("Resource %s: expected official CAF slug 'aa', got '%s'", resourceName, resource.Official.Slug)
			}
		})
	}
}

// TestAppConfigurationCAFAbbreviation validates that App Configuration resources
// use the correct CAF abbreviation 'appcs' in their official slug
func TestAppConfigurationCAFAbbreviation(t *testing.T) {
	resources := loadResourceDefinitionsFromJSON(t)
	
	appConfigResources := []string{
		"azurerm_app_configuration_feature",
		"azurerm_app_configuration_key",
	}

	// Create a map for easy lookup
	resourceMap := make(map[string]ResourceJSON)
	for _, r := range resources {
		resourceMap[r.Name] = r
	}

	for _, resourceName := range appConfigResources {
		t.Run(resourceName, func(t *testing.T) {
			resource, exists := resourceMap[resourceName]
			if !exists {
				t.Fatalf("Resource %s not found in resourceDefinition.json", resourceName)
			}

			if resource.Official.Slug != "appcs" {
				t.Errorf("Resource %s: expected official CAF slug 'appcs', got '%s'", resourceName, resource.Official.Slug)
			}
		})
	}
}
