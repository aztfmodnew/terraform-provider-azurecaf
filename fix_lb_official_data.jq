map(
    if .name == "azurerm_lb_backend_address_pool" then
        .official = {
            "slug": "lbbap",
            "resource": "Load Balancer Backend Address Pool",
            "resource_provider_namespace": "Microsoft.Network/loadBalancers"
        }
    elif .name == "azurerm_lb_backend_pool" then
        .official = {
            "slug": "lbbp", 
            "resource": "Load Balancer Backend Pool",
            "resource_provider_namespace": "Microsoft.Network/loadBalancers"
        }
    elif .name == "azurerm_lb_nat_pool" then
        .official = {
            "slug": "lbnatp",
            "resource": "Load Balancer NAT Pool", 
            "resource_provider_namespace": "Microsoft.Network/loadBalancers"
        }
    elif .name == "azurerm_lb_outbound_rule" then
        .official = {
            "slug": "lbor",
            "resource": "Load Balancer Outbound Rule",
            "resource_provider_namespace": "Microsoft.Network/loadBalancers"
        }
    elif .name == "azurerm_lb_probe" then
        .official = {
            "slug": "lbprobe",
            "resource": "Load Balancer Probe",
            "resource_provider_namespace": "Microsoft.Network/loadBalancers"
        }
    elif .name == "azurerm_lb_rule" then
        . + {
            "official": {
                "slug": "lbrule",
                "resource": "Load Balancer Rule",
                "resource_provider_namespace": "Microsoft.Network/loadBalancers"
            },
            "slug": "lbrule"  # Cambiar slug de "rule" a "lbrule" para evitar conflictos
        }
    else
        .
    end
)
