output "unit_root_folder" {
  value = {
    name         = google_folder.unit.name
    display_name = google_folder.unit.display_name
    parent       = google_folder.unit.parent
  }
}

output "unit_environment_folders" {
  value = {
    for key, value in local.environments : key => {
      parent       = google_folder.environment[key].parent
      name         = google_folder.environment[key].name
      display_name = google_folder.environment[key].display_name
    }
  }
}

output "unit_automation_project" {
  value = {
    project_id = module.automation_project.project_id
    name       = module.automation_project.name
    number     = module.automation_project.number
  }
}

output "unit_svpc_projects" {
  value = {
    for key, value in local.shared_vpc_hosts : key => {
      project_id = module.env_svpc_hosts[key].project_id
      name       = module.env_svpc_hosts[key].name
      number     = module.env_svpc_hosts[key].number
    }
  }
}
