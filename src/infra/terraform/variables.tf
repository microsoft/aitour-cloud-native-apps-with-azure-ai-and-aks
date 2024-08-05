variable "location" {
  description = "value of azure region"
  type        = string
  default     = "australiaeast"
}

variable "ai_location" {
  description = "value of azure region for deploying azure open ai service"
  type        = string
  default     = "australiaeast"
}

variable "gpt_model_name" {
  description = "value of azure open ai gpt model name"
  type        = string
  default     = "gpt-35-turbo"
}

variable "gpt_model_version" {
  description = "value of azure open ai gpt model version"
  type        = string
  default     = "0613"
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