resource "aws_route53domains_domain" "main" {
  domain_name = var.domain_name
  auto_renew  = false

  admin_contact {
    address_line_1    = var.registrant_address_line1
    city              = var.registrant_city
    contact_type      = var.contact_type
    country_code      = var.registrant_country_code
    email             = var.registrant_email
    fax               = var.registrant_fax
    first_name        = var.registrant_first_name
    last_name         = var.registrant_last_name
    organization_name = var.organization_name
    phone_number      = var.registrant_phone_number
    state             = var.registrant_state
    zip_code          = var.zip_code
  }

  registrant_contact {
    address_line_1    = var.registrant_address_line1
    city              = var.registrant_city
    contact_type      = var.contact_type
    country_code      = var.registrant_country_code
    email             = var.registrant_email
    fax               = var.registrant_fax
    first_name        = var.registrant_first_name
    last_name         = var.registrant_last_name
    organization_name = var.organization_name
    phone_number      = var.registrant_phone_number
    state             = var.registrant_state
    zip_code          = var.zip_code
  }

  tech_contact {
    address_line_1    = var.registrant_address_line1
    city              = var.registrant_city
    contact_type      = var.contact_type
    country_code      = var.registrant_country_code
    email             = var.registrant_email
    fax               = var.registrant_fax
    first_name        = var.registrant_first_name
    last_name         = var.registrant_last_name
    organization_name = var.organization_name
    phone_number      = var.registrant_phone_number
    state             = var.registrant_state
    zip_code          = var.zip_code
  }

  tags = {
    Environment = "test"
    Name        = "${var.project_name}-domain"
  }
}

# Variable definitions for domain registration
variable "registrant_address_line1" {
  type    = string
  default = "101 Main Street"
}

variable "registrant_city" {
  type    = string
  default = "San Fransokyo"
}

variable "contact_type" {
  type    = string
  default = "COMPANY"
}

variable "registrant_country_code" {
  type    = string
  default = "US"
}
variable "registrant_email" {
  type    = string
  default = "kt.kington@gmail.com"
}

variable "registrant_fax" {
  type    = string
  default = "+1.4155551234"
}

variable "registrant_first_name" {
  type    = string
  default = "Teng"
}

variable "registrant_last_name" {
  type    = string
  default = "Comiru"
}

variable "organization_name" {
  type    = string
  default = "Comiru"
}

variable "registrant_phone_number" {
  type    = string
  default = "+1.4155551234"
}

variable "registrant_state" {
  type    = string
  default = "CA"
}

variable "zip_code" {
  type    = string
  default = "94105"
}
