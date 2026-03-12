# 🤖 Available Agents - terraform-provider-azurecaf

This document lists AI agents for the `terraform-provider-azurecaf` repository (naming provider in Go).

## 🏗️ Core Development Agents

### **Provider Feature Developer**
**Purpose:** Implement new naming features, resource types, and behavior updates.

**When to use:**
- "Add support for a new Azure resource type"
- "Update slug/validation behavior"

### **Validation Rules Maintainer**
**Purpose:** Keep naming constraints and sanitization rules accurate.

**When to use:**
- "Fix invalid generated names"
- "Update min/max or allowed chars"

### **Acceptance Test Engineer**
**Purpose:** Strengthen and fix provider acceptance/unit tests.

**When to use:**
- "Add tests for new resource_type"
- "Fix flaky provider tests"

### **Release & Compatibility Manager**
**Purpose:** Maintain provider compatibility and release hygiene.

**When to use:**
- "Prepare release notes/changelog"
- "Validate Terraform/provider SDK compatibility"

## ✅ Validation Checklist

- `go test` passes for changed packages
- Acceptance tests updated when behavior changes
- Docs/examples reflect new behavior
- Backward compatibility assessed

**Last Updated:** March 2026
**Namespace:** aztfmodnew/terraform-provider-azurecaf
