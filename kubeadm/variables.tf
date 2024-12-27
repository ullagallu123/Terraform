# Define Instance Names
variable "instance_names" {
  default = {
    master   = "t3a.small"
    worker-1 = "t3a.small"
    worker-2 = "t3a.small"
  }
}

# Define Other Variables
variable "zone_name" {
  default = "bapatlas.site"
}

variable "zone_id" {
  default = "Z04410211MZ57SQOXFNI3"
}

variable "key_name" {
  default = "bapatlas.site"
}