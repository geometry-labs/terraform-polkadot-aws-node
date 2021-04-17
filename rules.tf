locals {
  network_settings = var.network_settings == null ? { network = {
    name                = var.network_name
    shortname           = var.network_stub
    api_health          = var.health_check_port
    polkadot_prometheus = var.polkadot_prometheus_port
    json_rpc            = var.rpc_api_port
    ws_rpc              = var.wss_api_port
  } } : var.network_settings
}

//    "5500", # Polkadot health check
//    "9933", # Polkadot RPC Port
//    "9944", # Polkadot WS Port
//    "5501", # Kusama health check
//    "9934", # Kusama RPC Port
//    "9945", # Kusama WS Port
