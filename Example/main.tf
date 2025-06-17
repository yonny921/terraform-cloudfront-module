#Ejemplo de uso del módulo de CloudFront en Terraform
# Este archivo main.tf muestra cómo utilizar el módulo de CloudFront para crear una distribución con configuraciones personalizadas, incluyendo orígenes de S3 y ALB, políticas de caché, y configuraciones de seguridad.

module "cloudfront" {
  source = "./modules/cloudfront"

  aliases             = ["example.com", "www.example.com"] # Lista de dominios personalizados para la distribución de CloudFront
  comment             = "CloudFront with S3 + ALB" # Comentario descriptivo para la distribución de CloudFront
  acm_certificate_arn = "arn:aws:acm:us-east-1:example:certificate/e36ac477-8406-4e85-b412-example" # ARN del certificado ACM para HTTPS

  # Configuración de los orígenes de la distribución de CloudFront, se pueden incluir multiples orígenes de tipo S3 y ALB (Custom)
  # Se pueden agregar parametros adicionales como origin_path, http_port, https_port, etc. según sea necesario.
  origins = [
    {
      origin_id                = "s3-origin" # Identificador único para el origen S3
      origin_access_control_id = "E3FLV6YK5QGE11" # Reemplazar con OAC para S3
      origin_type              = "s3" # Tipo de origen S3
      domain_name              = "domain.s3.amazonaws.com" # Reemplazar con el nombre de dominio del bucket S3
    },
    {
      origin_id   = "alb-origin" # Identificador único para el origen ALB
      origin_type = "custom" # Tipo de origen personalizado (ALB)
      domain_name = "domain.us-east-1.elb.amazonaws.com" # Reemplazar con el nombre de dominio del ALB
    }
  ]

  price_class         = "PriceClass_All" # Necesario para permitir el uso de todos los puntos de presencia de CloudFront

  # Si se incluye mas de un origen, se debe especificar el comportamiento de caché ordenado para cada uno de ellos. #Por ahora solo soporta politicas modernas de caché y CORS
  ordered_cache_behaviors = [
    {
      path_pattern               = "/bucket/*"
      target_origin_id           = "s3-origin"
      viewer_protocol_policy     = "redirect-to-https"
      allowed_methods            = ["GET", "HEAD", "OPTIONS"]
      cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
      origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin
      response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03" # SecurityHeadersPolicy
    }
  ]

  # Comportamiento de caché por defecto, se debe especificar al menos uno
  default_cache_behavior = {
    target_origin_id           = "alb-origin"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cache_policy_id            = "83da9c7e-98b4-4e11-a168-04f0df8e2c65" # UseOriginCacheControlHeaders
    origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03" # SecurityHeadersPolicy
  }

  # Configuración de seguridad opcional, se puede omitir si no se requiere WAF
  waf_web_acl_id = "arn:aws:wafv2:us-east-1:577638401085:global/webacl/waf-front/b177a9bf-deb7-48f0-9dc1-519aa303c788"


  # Configuración de respuestas de error personalizadas, se puede omitir si no se requiere
  custom_error_responses = [
    {
      error_code         = 404
      response_code      = 404
      response_page_path = "/index.html"
    }
  ]

  default_root_object = "index.html" # Objeto raíz por defecto para la distribución de CloudFront, solo es necesario si se utiliza un bucket S3 como origen
  

  tags = {
    Environment = "production"
    id_proyecto     = "example"
  }
}
