library(reticulate)
pipenv_config <- function(required_module) {
    pipfile <- pipenv_pipfile_path()
    if (!file.exists(pipfile)) {
        return(NULL)
    }

    python <- pipenv_python()
    py_config(python, required_module, forced = "Pipfile")
}

pipenv_pipfile_path <- function() {
    pipfile <- getOption("reticulate.pipenv.pipfile")

    if (!is.null(pipfile)) {
        return(pipfile)
    }

    tryCatch(
        here::here("Pipfile"),
        error = function(e) {
            ""
        }
    )
}

pipenv_python <- function() {
    if (!nzchar(Sys.which("pipenv"))) {
        stop("pipenv is not available")
    }

    root <- here::here()
    owd <- setwd(root)
    on.exit(setwd(owd), add = TRUE)

    envpath <- system("pipenv --venv", intern = TRUE)
    status <- attr(envpath, "status") %||% 0L
    if (status != 0L) {
        fmt <- "'pipenv --venv' had bad status"
        stop(fmt, status)
    }

    virtualenv_python(envpath)
}
