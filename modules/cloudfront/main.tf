# Este módulo de Terraform crea una distribución de CloudFront y esta especialmente diseñado para permitir configuraciones personalizadas como origenes personalizados, orígenes de S3, y configuraciones de caché avanzadas.

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  comment             = var.comment
  aliases             = var.aliases
  default_root_object = var.default_root_object
  price_class         = var.price_class
  web_acl_id          = var.waf_web_acl_id
  is_ipv6_enabled     = var.is_ipv6_enabled
  tags                = var.tags

  dynamic "origin" {
    for_each = var.origins
    iterator = origin_pair
    content {
      domain_name              = origin_pair.value.domain_name
      origin_id                = try(origin_pair.value.origin_id, origin_pair.key)
      origin_path              = origin_pair.value.origin_path
      origin_access_control_id = origin_pair.value.origin_type == "s3" ? origin_pair.value.origin_access_control_id : null # Solo para orígenes de tipo S3
      
      dynamic "custom_origin_config" {
        for_each = origin_pair.value.origin_type == "custom" ? [1] : []
        content {
          http_port              = origin_pair.value.http_port
          https_port             = origin_pair.value.https_port
          origin_protocol_policy = origin_pair.value.origin_protocol_policy
          origin_ssl_protocols   = origin_pair.value.origin_ssl_protocols
          origin_read_timeout    = origin_pair.value.origin_read_timeout
          # Si se requieren agregar configuraciones adicionales para el origen personalizado, se pueden agregar aquí
        }
      }
    }
  }

  # Configuración del comportamiento de caché por defecto
  default_cache_behavior {
    target_origin_id           = var.default_cache_behavior.target_origin_id
    viewer_protocol_policy     = var.default_cache_behavior.viewer_protocol_policy
    allowed_methods            = var.default_cache_behavior.allowed_methods
    cached_methods             = var.default_cache_behavior.cached_methods
    compress                   = var.default_cache_behavior.compress
    cache_policy_id            = var.default_cache_behavior.cache_policy_id
    origin_request_policy_id   = var.default_cache_behavior.origin_request_policy_id
    response_headers_policy_id = var.default_cache_behavior.response_headers_policy_id
  }

  # Configuración de comportamientos de caché ordenados
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    iterator = ordered_cache_behaviors_pair
    content {
      path_pattern               = ordered_cache_behaviors_pair.value.path_pattern
      target_origin_id           = ordered_cache_behaviors_pair.value.target_origin_id
      viewer_protocol_policy     = ordered_cache_behaviors_pair.value.viewer_protocol_policy
      allowed_methods            = ordered_cache_behaviors_pair.value.allowed_methods
      cached_methods             = ordered_cache_behaviors_pair.value.cached_methods
      compress                   = ordered_cache_behaviors_pair.value.compress
      cache_policy_id            = ordered_cache_behaviors_pair.value.cache_policy_id
      origin_request_policy_id   = ordered_cache_behaviors_pair.value.origin_request_policy_id
      response_headers_policy_id = ordered_cache_behaviors_pair.value.response_headers_policy_id
    }
  }

  # Configuración del certificado SSL
  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.ssl_support_method
    minimum_protocol_version       = var.minimum_protocol_version
    cloudfront_default_certificate = var.cloudfront_default_certificate
  }

  # Configuración de políticas de restricción geográfica
  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
      locations        = var.restriction_locations
    }
  }

  # Custom error responses para S3 CloudFront
  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    iterator = custom_error_response_pair
    content {
      error_code            = custom_error_response_pair.value.error_code
      response_code         = custom_error_response_pair.value.response_code
      response_page_path    = custom_error_response_pair.value.response_page_path
      error_caching_min_ttl = custom_error_response_pair.value.error_caching_min_ttl
    }
  }
}