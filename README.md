# Terraform Module: CloudFront

Este módulo de Terraform permite crear una distribución de Amazon CloudFront configurable, soportando múltiples orígenes (S3 y ALB), certificados ACM personalizados y políticas de caché avanzadas.

# Ejemplo
- Revisa el folder Example

## Variables Principales

- `aliases` (list) – Lista de dominios personalizados.
- `acm_certificate_arn` (string) – ARN del certificado SSL.
- `origins` (list of maps) – Lista de orígenes S3 o ALB.
- `price_class` (string) – Clase de precios (ej. `PriceClass_100`, `PriceClass_All`).
- `tags` (map) – Tags para la distribución.
- `comment` (string) – Comentario descriptivo de la distribución.
- `default_root_object` (string) – Objeto raíz por defecto.
- `is_ipv6_enabled` (bool) – Habilita IPv6.
- `ssl_support_method` (string) – Método de soporte SSL.
- `minimum_protocol_version` (string) – Versión mínima del protocolo SSL.
- `cloudfront_default_certificate` (bool) – Indica si se usa el certificado por defecto.
- `restriction_type` (string) – Tipo de restricción geográfica.
- `restriction_locations` (list) – Lista de países para restricción.

## Outputs

- `distribution_id` – ID de la distribución de CloudFront.
- `domain_name` – Nombre de dominio asignado por CloudFront.

## Requisitos

- Terraform >= 1.0.0
- AWS Provider >= 4.0

## Autores

Yonny921.

## Licencia

MIT