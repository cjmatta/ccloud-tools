###########################################
########## Schema Registry LBR ############
###########################################

resource "google_compute_global_address" "schema_registry" {

    count = "${var.instance_count["schema_registry"] == 0 ? 1 : 1}"

    name = "schema-registry-global-address"

}

resource "google_compute_global_forwarding_rule" "schema_registry" {

    count = "${var.instance_count["schema_registry"] == 0 ? 1 : 1}"

    name = "schema-registry-global-forwarding-rule"
    target = "${google_compute_target_http_proxy.schema_registry.self_link}"
    ip_address = "${google_compute_global_address.schema_registry.self_link}"
    port_range = "80"

}

resource "google_compute_target_http_proxy" "schema_registry" {

    count = "${var.instance_count["schema_registry"] == 0 ? 1 : 1}"

    name = "schema-registry-http-proxy"
    url_map = "${google_compute_url_map.schema_registry.self_link}"

}

resource "google_compute_url_map" "schema_registry" {

    count = "${var.instance_count["schema_registry"] == 0 ? 1 : 1}"

    name = "schema-registry-url-map"
    default_service = "${google_compute_backend_service.schema_registry.self_link}"

}

resource "google_compute_backend_service" "schema_registry" {

    count = "${var.instance_count["schema_registry"] == 0 ? 1 : 1}"

    name = "schema-registry-backend-service"
    port_name = "http"
    protocol = "HTTP"
    timeout_sec = 5

    backend = {

        group = "${google_compute_region_instance_group_manager.schema_registry.instance_group}"

    }

    health_checks = ["${google_compute_http_health_check.schema_registry.self_link}"]

}

resource "google_compute_region_instance_group_manager" "schema_registry" {

    count = "${var.instance_count["schema_registry"] == 0 ? 1 : 1}"

    name = "schema-registry-instance-group"
    instance_template = "${google_compute_instance_template.schema_registry.self_link}"
    base_instance_name = "schema-registry"
    region = "${var.gcp_region}"
    distribution_policy_zones = "${var.gcp_availability_zones}"
    target_size = "${var.instance_count["schema_registry"]}"

    named_port = {

        name = "http"
        port = 8081

    }

}

resource "google_compute_http_health_check" "schema_registry" {

    count = "${var.instance_count["schema_registry"] == 0 ? 1 : 1}"

    name = "schema-registry-http-health-check"
    request_path = "/"
    port = "8081"
    healthy_threshold = 3
    unhealthy_threshold = 3
    check_interval_sec = 5
    timeout_sec = 3

}

resource "google_compute_instance_template" "schema_registry" {

    count = "${var.instance_count["schema_registry"] == 0 ? 1 : 1}"

    name = "schema-registry-template"
    machine_type = "n1-standard-2"

    metadata_startup_script = "${data.template_file.schema_registry_bootstrap.rendered}"

    disk {

        source_image = "centos-7"
        disk_size_gb = 100

    }    

    network_interface {

        subnetwork = "${google_compute_subnetwork.private_subnet.self_link}"

        access_config {}

    }

    tags = ["schema-registry"]

}

###########################################
############# REST Proxy LBR ##############
###########################################

resource "google_compute_global_address" "rest_proxy" {

    count = "${var.instance_count["rest_proxy"] > 0 ? var.instance_count["rest_proxy"] : 0}"

    name = "rest-proxy-global-address"

}

resource "google_compute_global_forwarding_rule" "rest_proxy" {

    count = "${var.instance_count["rest_proxy"] > 0 ? var.instance_count["rest_proxy"] : 0}"

    name = "rest-proxy-global-forwarding-rule"
    target = "${google_compute_target_http_proxy.rest_proxy.self_link}"
    ip_address = "${google_compute_global_address.rest_proxy.self_link}"
    port_range = "80"

}

resource "google_compute_target_http_proxy" "rest_proxy" {

    count = "${var.instance_count["rest_proxy"] > 0 ? var.instance_count["rest_proxy"] : 0}"

    name = "rest-proxy-http-proxy"
    url_map = "${google_compute_url_map.rest_proxy.self_link}"

}

resource "google_compute_url_map" "rest_proxy" {

    count = "${var.instance_count["rest_proxy"] > 0 ? var.instance_count["rest_proxy"] : 0}"

    name = "rest-proxy-url-map"
    default_service = "${google_compute_backend_service.rest_proxy.self_link}"

}

resource "google_compute_backend_service" "rest_proxy" {

    count = "${var.instance_count["rest_proxy"] > 0 ? var.instance_count["rest_proxy"] : 0}"

    name = "rest-proxy-backend-service"
    port_name = "http"
    protocol = "HTTP"
    timeout_sec = 5

    backend = {

        group = "${google_compute_region_instance_group_manager.rest_proxy.instance_group}"

    }

    health_checks = ["${google_compute_http_health_check.rest_proxy.self_link}"]

}

resource "google_compute_region_instance_group_manager" "rest_proxy" {

    count = "${var.instance_count["rest_proxy"] > 0 ? var.instance_count["rest_proxy"] : 0}"

    name = "rest-proxy-instance-group"
    instance_template = "${google_compute_instance_template.rest_proxy.self_link}"
    base_instance_name = "rest-proxy"
    region = "${var.gcp_region}"
    distribution_policy_zones = "${var.gcp_availability_zones}"
    target_size = "${var.instance_count["rest_proxy"]}"

    named_port = {

        name = "http"
        port = 8082

    }

}

resource "google_compute_http_health_check" "rest_proxy" {

    count = "${var.instance_count["rest_proxy"] > 0 ? var.instance_count["rest_proxy"] : 0}"

    name = "rest-proxy-http-health-check"
    request_path = "/"
    port = "8082"
    healthy_threshold = 3
    unhealthy_threshold = 3
    check_interval_sec = 5
    timeout_sec = 3

}

resource "google_compute_instance_template" "rest_proxy" {

    count = "${var.instance_count["rest_proxy"] > 0 ? var.instance_count["rest_proxy"] : 0}"

    name = "rest-proxy-template"
    machine_type = "n1-standard-2"

    metadata_startup_script = "${data.template_file.rest_proxy_bootstrap.rendered}"

    disk {

        source_image = "centos-7"
        disk_size_gb = 100

    }    

    network_interface {

        subnetwork = "${google_compute_subnetwork.private_subnet.self_link}"

        access_config {}

    }

    tags = ["rest-proxy"]

}

###########################################
########### Kafka Connect LBR #############
###########################################

resource "google_compute_global_address" "kafka_connect" {

    count = "${var.instance_count["kafka_connect"] > 0 ? var.instance_count["kafka_connect"] : 0}"

    name = "kafka-connect-global-address"

}

resource "google_compute_global_forwarding_rule" "kafka_connect" {

    count = "${var.instance_count["kafka_connect"] > 0 ? var.instance_count["kafka_connect"] : 0}"

    name = "kafka-connect-global-forwarding-rule"
    target = "${google_compute_target_http_proxy.kafka_connect.self_link}"
    ip_address = "${google_compute_global_address.kafka_connect.self_link}"
    port_range = "80"

}

resource "google_compute_target_http_proxy" "kafka_connect" {

    count = "${var.instance_count["kafka_connect"] > 0 ? var.instance_count["kafka_connect"] : 0}"

    name = "kafka-connect-http-proxy"
    url_map = "${google_compute_url_map.kafka_connect.self_link}"

}

resource "google_compute_url_map" "kafka_connect" {

    count = "${var.instance_count["kafka_connect"] > 0 ? var.instance_count["kafka_connect"] : 0}"

    name = "kafka-connect-url-map"
    default_service = "${google_compute_backend_service.kafka_connect.self_link}"

}

resource "google_compute_backend_service" "kafka_connect" {

    count = "${var.instance_count["kafka_connect"] > 0 ? var.instance_count["kafka_connect"] : 0}"

    name = "kafka-connect-backend-service"
    port_name = "http"
    protocol = "HTTP"
    timeout_sec = 5

    backend = {

        group = "${google_compute_region_instance_group_manager.kafka_connect.instance_group}"

    }

    health_checks = ["${google_compute_http_health_check.kafka_connect.self_link}"]

}

resource "google_compute_region_instance_group_manager" "kafka_connect" {

    count = "${var.instance_count["kafka_connect"] > 0 ? var.instance_count["kafka_connect"] : 0}"

    name = "kafka-connect-instance-group"
    instance_template = "${google_compute_instance_template.kafka_connect.self_link}"
    base_instance_name = "kafka-connect"
    region = "${var.gcp_region}"
    distribution_policy_zones = "${var.gcp_availability_zones}"
    target_size = "${var.instance_count["kafka_connect"]}"

    named_port = {

        name = "http"
        port = 8083

    }

}

resource "google_compute_http_health_check" "kafka_connect" {

    count = "${var.instance_count["kafka_connect"] > 0 ? var.instance_count["kafka_connect"] : 0}"

    name = "kafka-connect-http-health-check"
    request_path = "/"
    port = "8083"
    healthy_threshold = 3
    unhealthy_threshold = 3
    check_interval_sec = 5
    timeout_sec = 3

}

resource "google_compute_instance_template" "kafka_connect" {

    count = "${var.instance_count["kafka_connect"] > 0 ? var.instance_count["kafka_connect"] : 0}"

    name = "kafka-connect-template"
    machine_type = "n1-standard-2"

    metadata_startup_script = "${data.template_file.kafka_connect_bootstrap.rendered}"

    disk {

        source_image = "centos-7"
        disk_size_gb = 100

    }    

    network_interface {

        subnetwork = "${google_compute_subnetwork.private_subnet.self_link}"

        access_config {}

    }

    tags = ["kafka-connect"]

}

###########################################
############ KSQL Server LBR ##############
###########################################

resource "google_compute_global_address" "ksql_server" {

    count = "${var.instance_count["ksql_server"] > 0 ? var.instance_count["ksql_server"] : 0}"

    name = "ksql-server-global-address"

}

resource "google_compute_global_forwarding_rule" "ksql_server" {

    count = "${var.instance_count["ksql_server"] > 0 ? var.instance_count["ksql_server"] : 0}"

    name = "ksql-server-global-forwarding-rule"
    target = "${google_compute_target_http_proxy.ksql_server.self_link}"
    ip_address = "${google_compute_global_address.ksql_server.self_link}"
    port_range = "80"

}

resource "google_compute_target_http_proxy" "ksql_server" {

    count = "${var.instance_count["ksql_server"] > 0 ? var.instance_count["ksql_server"] : 0}"

    name = "ksql-server-http-proxy"
    url_map = "${google_compute_url_map.ksql_server.self_link}"

}

resource "google_compute_url_map" "ksql_server" {

    count = "${var.instance_count["ksql_server"] > 0 ? var.instance_count["ksql_server"] : 0}"

    name = "ksql-server-url-map"
    default_service = "${google_compute_backend_service.ksql_server.self_link}"

}

resource "google_compute_backend_service" "ksql_server" {

    count = "${var.instance_count["ksql_server"] > 0 ? var.instance_count["ksql_server"] : 0}"

    name = "ksql-server-backend-service"
    port_name = "http"
    protocol = "HTTP"
    timeout_sec = 5

    backend = {

        group = "${google_compute_region_instance_group_manager.ksql_server.instance_group}"

    }

    health_checks = ["${google_compute_http_health_check.ksql_server.self_link}"]

}

resource "google_compute_region_instance_group_manager" "ksql_server" {

    count = "${var.instance_count["ksql_server"] > 0 ? var.instance_count["ksql_server"] : 0}"

    name = "ksql-server-instance-group"
    instance_template = "${google_compute_instance_template.ksql_server.self_link}"
    base_instance_name = "ksql-server"
    region = "${var.gcp_region}"
    distribution_policy_zones = "${var.gcp_availability_zones}"
    target_size = "${var.instance_count["ksql_server"]}"

    named_port = {

        name = "http"
        port = 8088

    }

}

resource "google_compute_http_health_check" "ksql_server" {

    count = "${var.instance_count["ksql_server"] > 0 ? var.instance_count["ksql_server"] : 0}"

    name = "ksql-server-http-health-check"
    request_path = "/info"
    port = "8088"
    healthy_threshold = 3
    unhealthy_threshold = 3
    check_interval_sec = 5
    timeout_sec = 3

}

resource "google_compute_instance_template" "ksql_server" {

    count = "${var.instance_count["ksql_server"] > 0 ? var.instance_count["ksql_server"] : 0}"

    name = "ksql-server-template"
    machine_type = "n1-standard-8"

    metadata_startup_script = "${data.template_file.ksql_server_bootstrap.rendered}"

    disk {

        source_image = "centos-7"
        disk_size_gb = 300

    }    

    network_interface {

        subnetwork = "${google_compute_subnetwork.private_subnet.self_link}"

        access_config {}

    }

    tags = ["ksql-server"]

}

###########################################
########### Control Center LBR ############
###########################################

resource "google_compute_global_address" "control_center" {

    count = "${var.instance_count["control_center"] > 0 ? var.instance_count["control_center"] : 0}"

    name = "control-center-global-address"

}

resource "google_compute_global_forwarding_rule" "control_center" {

    count = "${var.instance_count["control_center"] > 0 ? var.instance_count["control_center"] : 0}"

    name = "control-center-global-forwarding-rule"
    target = "${google_compute_target_http_proxy.control_center.self_link}"
    ip_address = "${google_compute_global_address.control_center.self_link}"
    port_range = "80"

}

resource "google_compute_target_http_proxy" "control_center" {

    count = "${var.instance_count["control_center"] > 0 ? var.instance_count["control_center"] : 0}"

    name = "control-center-http-proxy"
    url_map = "${google_compute_url_map.control_center.self_link}"

}

resource "google_compute_url_map" "control_center" {

    count = "${var.instance_count["control_center"] > 0 ? var.instance_count["control_center"] : 0}"

    name = "control-center-url-map"
    default_service = "${google_compute_backend_service.control_center.self_link}"

}

resource "google_compute_backend_service" "control_center" {

    count = "${var.instance_count["control_center"] > 0 ? var.instance_count["control_center"] : 0}"

    name = "control-center-backend-service"
    port_name = "http"
    protocol = "HTTP"
    timeout_sec = 5

    backend = {

        group = "${google_compute_region_instance_group_manager.control_center.instance_group}"

    }

    health_checks = ["${google_compute_http_health_check.control_center.self_link}"]

}

resource "google_compute_region_instance_group_manager" "control_center" {

    count = "${var.instance_count["control_center"] > 0 ? var.instance_count["control_center"] : 0}"

    name = "control-center-instance-group"
    instance_template = "${google_compute_instance_template.control_center.self_link}"
    base_instance_name = "control-center"
    region = "${var.gcp_region}"
    distribution_policy_zones = "${var.gcp_availability_zones}"
    target_size = "${var.instance_count["control_center"]}"

    named_port = {

        name = "http"
        port = 9021

    }

}

resource "google_compute_http_health_check" "control_center" {

    count = "${var.instance_count["control_center"] > 0 ? var.instance_count["control_center"] : 0}"

    name = "control-center-http-health-check"
    request_path = "/"
    port = "9021"
    healthy_threshold = 3
    unhealthy_threshold = 3
    check_interval_sec = 5
    timeout_sec = 3

}

resource "google_compute_instance_template" "control_center" {

    count = "${var.instance_count["control_center"] > 0 ? var.instance_count["control_center"] : 0}"

    name = "control-center-template"
    machine_type = "n1-standard-8"

    metadata_startup_script = "${data.template_file.control_center_bootstrap.rendered}"

    disk {

        source_image = "centos-7"
        disk_size_gb = 300

    }    

    network_interface {

        subnetwork = "${google_compute_subnetwork.private_subnet.self_link}"

        access_config {}

    }

    tags = ["control-center"]

}