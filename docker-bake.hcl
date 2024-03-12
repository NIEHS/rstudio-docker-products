variable BASE_BUILD_MATRIX {
    default = {
        builds = [
            {os = "centos7", r_primary = "4.2.0", r_alternate = "3.6.2", py_primary = "3.9.5", py_alternate = "3.8.10"},
            {os = "centos7", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.14", py_alternate = "3.8.15"},
            {os = "ubuntu2204", r_primary = "4.2.0", r_alternate = "3.6.2", py_primary = "3.9.5", py_alternate = "3.8.10"},
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.14", py_alternate = "3.8.15"},
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.17", py_alternate = "3.8.17"},
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.12.1", py_alternate = "3.11.7"},
        ]
    }
}

variable PRO_BUILD_MATRIX {
    default = BASE_BUILD_MATRIX
}

variable PACKAGE_MANAGER_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.12.1", py_alternate = "3.11.7"},
        ]
    }
}

variable CONNECT_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.17", py_alternate = "3.8.17"},
        ]
    }
}

variable CONNECT_CONTENT_INIT_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204"},
        ]
    }
}

variable R_SESSION_COMPLETE_BUILD_MATRIX {
    default = {
        builds = [
            {os = "centos7", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.14", py_alternate = "3.8.15"},
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.14", py_alternate = "3.8.15"},
        ]
    }
}

variable WORKBENCH_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.14", py_alternate = "3.8.15"},
        ]
    }
}

variable WORKBENCH_GOOGLE_CLOUD_WORKSTATION_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2004", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.12.1", py_alternate = "3.11.7"},
        ]
    }
}

variable WORKBENCH_MICROSOFT_AZURE_ML_BUILD_MATRIX {
    default = {
        builds = [
            {os = "ubuntu2204", r_primary = "4.2.3", r_alternate = "4.1.3", py_primary = "3.9.14", py_alternate = "3.8.15"},
        ]
    }
}

group "default" {
    targets = [
        "product-base", 
        "product-base-pro", 
        "connect", 
        "connect-content-init",
        "package-manager", 
        "r-session-complete",
        "workbench", 
        "workbench-for-google-cloud-workstations", 
        "workbench-for-microsoft-azure-ml",
    ]
}

target "base" {
    labels = {
        "maintainer" = "RStudio Docker <docker@rstudio.com>"
    }
}   

target "product-base" {
    inherits = ["base"]
    name = "product-base-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-base:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-base:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]    
    
    dockerfile = "Dockerfile.${builds.os}"
    context = "product/base"    

    matrix = BASE_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
    }    
}

target "product-base-pro" {
    inherits = ["base"]

    name = "product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-base-pro:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-base-pro:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]    

    dockerfile = "Dockerfile.${builds.os}"   
    context = "product/pro"
    contexts = {
        baseapp = "target:product-base-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = PRO_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        DEBIAN_FRONTEND = "noninteractive"
        DRIVERS_VERSION = builds.os == "centos7" ? "2023.12.1-1" : "2023.12.1"
    }    
}


target "package-manager" {
    inherits = ["base"]

    name = "package-manager-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-package-manager:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-package-manager:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]    

    dockerfile = "Dockerfile.${builds.os}"
    context = "package-manager"
    contexts = {
        baseapp = "target:product-base-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = PACKAGE_MANAGER_BUILD_MATRIX
    args = {
      R_VERSION = builds.r_primary
      R_VERSION_ALT = builds.r_alternate
      PYTHON_VERSION = builds.py_primary
      PYTHON_VERSION_ALT = builds.py_alternate
      RSPM_VERSION = "2023.12.0-13"
    }
}

target "connect" {
    inherits = ["base"]

    name = "connect-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-connect:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-connect:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]    

    dockerfile = "Dockerfile.${builds.os}"
    context = "connect"
    contexts = {
        baseapp = "target:product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = CONNECT_BUILD_MATRIX
    args = {
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        RSC_VERSION = "2024.02.0"
    }
}

target "connect-content-init" {
    inherits = ["base"]

    name = "connect-content-init-${builds.os}"
    tags = [
        "ghcr.io/rstudio/product-connect-content-init:${builds.os}",
        "docker.io/rstudio/product-connect-content-init:${builds.os}",
    ]    

    dockerfile = "Dockerfile.${builds.os}"
    context = "connect-content-init"

    matrix = CONNECT_CONTENT_INIT_BUILD_MATRIX

    args = {
        DEBIAN_FRONTEND = "noninteractive"
        RSC_VERSION = "2024.02.0"
    }
}

target "r-session-complete" {
    inherits = ["base"]

    name = "r-session-complete-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-r-session-complete:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-r-session-complete:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]    

    dockerfile = "Dockerfile.${builds.os}"
    context = "r-session-complete"
    contexts = {
        baseapp = "target:product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = R_SESSION_COMPLETE_BUILD_MATRIX
    args = {
        DEBIAN_FRONTEND = "noninteractive"
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        JUPYTERLAB_VERSION = "3.6.5"
        RSW_VERSION = "2023.12.1+402.pro1"
        RSW_NAME = builds.os == "centos7" ? "rstudio-workbench-rhel" : "rstudio-workbench"
        RSW_DOWNLOAD_URL = builds.os == "centos7" ? "https://s3.amazonaws.com/rstudio-ide-build/server/centos7/x86_64" : "https://download2.rstudio.org/server/jammy/amd64"
    }
}

target "workbench" {
    inherits = ["base"]

    name = "workbench-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-workbench:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-workbench:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]    

    dockerfile = "Dockerfile.${builds.os}"
    context = "workbench"
    contexts = {
        baseapp = "target:product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = WORKBENCH_BUILD_MATRIX
    args = {
        DEBIAN_FRONTEND = "noninteractive"
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        PYTHON_VERSION_JUPYTER = builds.py_alternate
        RSW_VERSION = "2023.12.1+402.pro1"
        RSW_NAME = "rstudio-workbench"
        RSW_DOWNLOAD_URL = "https://download2.rstudio.org/server/jammy/amd64"
    }        
}

target "workbench-for-google-cloud-workstations" {
    inherits = ["base"]

    name = "workbench-for-google-cloud-workstation-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-workbench-for-google-cloud-workstation:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-workbench-for-google-cloud-workstation:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]    

    dockerfile = "Dockerfile.${builds.os}"
    context = "workbench-for-google-cloud-workstations"

    matrix = WORKBENCH_GOOGLE_CLOUD_WORKSTATION_BUILD_MATRIX
    args = {
        DEBIAN_FRONTEND = "noninteractive"
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        PYTHON_VERSION_JUPYTER = builds.py_alternate
        JUPYTERLAB_VERSION = "3.6.5"
        QUARTO_VERSION = "1.4.550"
        DRIVERS_VERSION = "2023.05.0"
        RSW_VERSION = "2023.12.1+402.pro1"
        RSW_NAME = "rstudio-workbench"
        RSW_DOWNLOAD_URL = "https://download2.rstudio.org/server/focal/amd64"
    } 
}

target "workbench-for-microsoft-azure-ml" {
    inherits = ["base"]

    name = "workbench-for-microsoft-azure-ml-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    tags = [
        "ghcr.io/rstudio/product-workbench-for-microsoft-azure-ml:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
        "docker.io/rstudio/product-workbench-for-microsoft-azure-ml:${builds.os}-r${builds.r_primary}_${builds.r_alternate}-py${builds.py_primary}_${builds.py_alternate}",
    ]    

    dockerfile = "Dockerfile.${builds.os}"
    context = "workbench-for-microsoft-azure-ml"
    contexts = {
        baseapp = "target:product-base-pro-${builds.os}-r${replace(builds.r_primary, ".", "-")}_${replace(builds.r_alternate, ".", "-")}-py${replace(builds.py_primary, ".", "-")}_${replace(builds.py_alternate, ".", "-")}"
    }

    matrix = WORKBENCH_MICROSOFT_AZURE_ML_BUILD_MATRIX
    args = {
        DEBIAN_FRONTEND = "noninteractive"
        R_VERSION = builds.r_primary
        R_VERSION_ALT = builds.r_alternate
        PYTHON_VERSION = builds.py_primary
        PYTHON_VERSION_ALT = builds.py_alternate
        PYTHON_VERSION_JUPYTER = builds.py_alternate
        JUPYTERLAB_VERSION = "3.6.5"
        RSW_VERSION = "2023.12.1+402.pro1"
        RSW_NAME = "rstudio-workbench"
        RSW_DOWNLOAD_URL = "https://download2.rstudio.org/server/jammy/amd64"
    } 
}