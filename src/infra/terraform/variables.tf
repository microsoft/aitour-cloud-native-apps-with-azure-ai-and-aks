variable "owner" {
  description = "value to identify the owner of the resources"
  type        = string
}

variable "location" {
  description = "value of azure region"
  type        = string
  default     = "swedencentral"
}

# reference for model availability: https://learn.microsoft.com/azure/ai-services/openai/concepts/models#standard-deployment-model-availability
variable "ai_location" {
  description = "value of azure region for deploying azure open ai service"
  type        = string
  default     = "swedencentral"
}

variable "gpt_model_name" {
  description = "value of azure open ai gpt model name"
  type        = string
  default     = "gpt-4o"
}

variable "gpt_model_version" {
  description = "value of azure open ai gpt model version"
  type        = string
  default     = "2024-08-06"
}


variable "gpt_model_sku_name" {
  description = "value of azure open ai gpt model sku name"
  type        = string
  default     = "GlobalStandard"
}

variable "gpt_model_capacity" {
  description = "value of azure open ai gpt model capacity"
  type        = number
  default     = 8
}

variable "dalle_model_name" {
  description = "value of azure open ai dall-e model name"
  type        = string
  default     = "dall-e-3"
}

variable "dalle_model_version" {
  description = "value of azure open ai dall-e model version"
  type        = string
  default     = "3.0"
}

variable "dalle_model_sku_name" {
  description = "value of azure open ai dall-e model sku name"
  type        = string
  default     = "Standard"
}

variable "dalle_model_capacity" {
  description = "value of azure open ai dall-e model capacity"
  type        = number
  default     = 1
}

variable "dalle_openai_api_version" {
  description = "value of azure open ai dall-e api version"
  type        = string
  default     = "2024-02-15-preview"
}

variable "k8s_version" {
  description = "value of kubernetes version"
  type        = string
  default     = "1.30.0"
}

variable "k8s_namespace" {
  description = "value of kubernetes namespace"
  type        = string
  default     = "pets"
}
