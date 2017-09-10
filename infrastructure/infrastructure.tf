provider "aws" {
    region = "${var.myRegion}"
}

resource "aws_vpc" "main_vpc" {
    cidr_block = "${var.myCidrBlock}"
    instance_tenancy = "default"
    enable_dns_hostnames = true

    tags {
        Name = "main_vpc"
    }
}

resource "aws_internet_gateway" "main_vpc_igw" {
    vpc_id = "${aws_vpc.main_vpc.id}"

    tags {
        Name = "main_vpc_igw"
    }
}

resource "aws_default_route_table" "main_vpc_default_route_table" {
    default_route_table_id = "${aws_vpc.main_vpc.default_route_table_id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main_vpc_igw.id}"
    }

    tags {
        Name = "main_vpc_default_route_table"
    }
}

resource "aws_subnet" "main_vpc_subnet" {
    vpc_id = "${aws_vpc.main_vpc.id}"
    availability_zone = "${var.myPrimaryAvailabilityZone}"
    cidr_block = "${var.myCidrBlock}"
    map_public_ip_on_launch = true

    tags {
        Name = "main_vpc_subnet"
    }
}

resource "aws_default_network_acl" "main_vpc_nacl" {
    default_network_acl_id = "${aws_vpc.main_vpc.default_network_acl_id}"
    subnet_ids = ["${aws_subnet.main_vpc_subnet.id}"]

    ingress {
        protocol   = -1
        rule_no    = 1
        action     = "allow"
//        cidr_block = "${var.myIp}"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }

    egress {
        protocol   = -1
        rule_no    = 2
        action     = "allow"
        cidr_block = "0.0.0.0/0"
        from_port  = 0
        to_port    = 0
    }

    tags {
        Name = "main_vpc_nacl"
    }
}

resource "aws_default_security_group" "main_vpc_security_group" {
    vpc_id = "${aws_vpc.main_vpc.id}"

    ingress {
        protocol    = "-1"
//        cidr_blocks = ["${var.myIp}"]
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = 0
        to_port     = 0
    }

    egress {
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        from_port       = 0
        to_port         = 0
    }

    tags {
        Name = "main_vpc_security_group"
    }
}

//// t2.medium Test AMI //////////////////////////////////////////////
//resource "aws_instance" "test" {
//    ami             = "ami-c58c1dd3"
//    instance_type   = "t2.medium"
//    security_groups = ["${aws_default_security_group.main_vpc_security_group.id}"]
//    subnet_id       = "${aws_subnet.main_vpc_subnet.id}"
//    associate_public_ip_address = true
//    key_name        = "${var.myKeyPair}"
//    ebs_block_device    = {
//        device_name = "/dev/xvda"
//        volume_size = 20
//        volume_type = "gp2"
//        delete_on_termination = true
//    }
//}

//// Amazon Compute Optimized Amazon Linux AMI /////////////////////////////////////////
//resource "aws_spot_instance_request" "aws_compute_optimized_spot" {
//    spot_price    = "0.15"
//    ami             = "ami-c58c1dd3"
//    instance_type   = "m4.large"
//    security_groups = ["${aws_default_security_group.main_vpc_security_group.id}"]
//    subnet_id       = "${aws_subnet.main_vpc_subnet.id}"
//    associate_public_ip_address = true
//    key_name        = "${var.myKeyPair}"
//    ebs_block_device    = {
//        device_name = "/dev/xvda"
//        volume_size = 30
//        volume_type = "gp2"
//        delete_on_termination = true
//    }
//
//    tags {
//        Name = "aws_compute_optimized_spot"
//    }
//}

// Pragmatic Machine Learning Linux AMI /////////////////////////////////////////
resource "aws_spot_instance_request" "aws_compute_optimized_spot" {
    spot_price      = "0.03"

    // AMI Settings
//    ami             = "ami-c58c1dd3" // Amazon Linux AMI
//    ami             = "ami-de897ec8" // Pragmatic Deep Learning AMI - https://aws.amazon.com/marketplace/pp/B01MUHVO4J
    ami             = "ami-4b44745d" // Amazon Deep Learning AMI

    // Instance Type Settings
//    instance_type   = "c4.4xlarge"  // 16 CPU, 30 GB RAM, 2 Gb bandwith (spot = 0.21)
    instance_type   = "m4.large"    // 2 CPU, 8 GB RAM, 450 Mb bandwith (spot = 0.025)
//    instance_type   = "m4.xlarge"    // 4 CPU, 16 GB RAM, 750 Mb bandwith (spot = 0.025)

    security_groups = ["${aws_default_security_group.main_vpc_security_group.id}"]
    subnet_id       = "${aws_subnet.main_vpc_subnet.id}"
    associate_public_ip_address = true
    key_name        = "${var.myKeyPair}"
//    ebs_block_device    = {
//        device_name = "/dev/xvda"
//        volume_size = 30
//        volume_type = "gp2"
//        delete_on_termination = true
//    }

    tags {
        Name = "aws_compute_optimized_spot"
    }
}

// Amazon Deep Learning AMI /////////////////////////////////////////
//resource "aws_spot_instance_request" "aws_deep_learning_custom_spot" {
//    ami           = "ami-4b44745d"
//    spot_price    = "0.25"
//    instance_type = "p2.xlarge"
//    security_groups = ["${aws_default_security_group.main_vpc_security_group.id}"]
//    subnet_id = "${aws_subnet.main_vpc_subnet.id}"
//    key_name = "${var.myKeyPair}"
//
//    tags {
//        Name = "aws_deep_learning_custom_spot"
//    }
//}