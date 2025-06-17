# Variables para el módulo de CloudFront, incluye configuraciones por defecto y opciones personalizables para la distribución de CloudFront.

variable "aliases" {
  type    = list(string)
  default = []
}

variable "comment" {
  type    = string
  default = "CloudFront Distribution"
}

variable "is_ipv6_enabled" {
  type    = bool
  default = false
}

variable "default_root_object" {
  type    = string
  default = ""
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "acm_certificate_arn" {
  type = string
}

variable "ssl_support_method" {
  type    = string
  default = "sni-only"
}

variable "minimum_protocol_version" {
  type    = string
  default = "TLSv1.2_2021"
}

variable "cloudfront_default_certificate" {
  type    = bool
  default = false
}

variable "restriction_type" {
  type    = string
  default = "none"
}

variable "restriction_locations" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "waf_web_acl_id" {
  type    = string
  default = null
}

variable "origins" {
  description = "Lista de orígenes para la distribución de CloudFront"
  type = list(object({
    origin_id                = string
    origin_type              = string
    domain_name              = string
    origin_path              = optional(string, null)
    http_port                = optional(number, 80)
    https_port               = optional(number, 443)
    origin_protocol_policy   = optional(string, "https-only")
    origin_ssl_protocols     = optional(list(string), ["TLSv1.2"])
    origin_read_timeout      = optional(number, 30)
    origin_access_control_id = optional(string, "")
  }))
}


variable "ordered_cache_behaviors" {
  description = "Lista opcional de comportamientos de caché ordenados para CloudFront"
  type = list(object({
    path_pattern               = optional(string, null)
    target_origin_id           = string
    viewer_protocol_policy     = optional(string)
    allowed_methods            = optional(list(string))
    cached_methods             = optional(list(string), ["GET", "HEAD"])
    compress                   = optional(bool, true)
    cache_policy_id            = optional(string)
    origin_request_policy_id   = optional(string)
    response_headers_policy_id = optional(string)
  }))
  default = []
}

variable "default_cache_behavior" {
  description = "Comportamiento de caché por defecto para CloudFront"
  type = object({
    target_origin_id           = string
    viewer_protocol_policy     = optional(string)
    allowed_methods            = optional(list(string))
    cached_methods             = optional(list(string), ["GET", "HEAD"])
    compress                   = optional(bool, true)
    cache_policy_id            = optional(string)
    origin_request_policy_id   = optional(string)
    response_headers_policy_id = optional(string)
  })
}

variable "custom_error_responses" {
  description = "Lista opcional de respuestas de error personalizadas para S3 CloudFront"
  type = list(object({
    error_code            = number
    response_code         = optional(number, null)
    response_page_path    = optional(string, null)
    error_caching_min_ttl = optional(number, null)
  }))
  default = []
}