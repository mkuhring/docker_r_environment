# General purpose Docker R environment

This Docker image is meant to create a general purpose container for analysis or
package development in which different projects maintain their own package
dependencies using [renv](https://rstudio.github.io/renv/articles/renv.html).
I.e., the container is continously used as default R environment (in contrast to
single purpose Docker images build for one project, e.g. deploying one specific
tool).

This image is based on the established Rocker Project image
[rocker/verse]((https://hub.docker.com/r/rocker/verse)
which includes base R, RStudio Server, tidyverse and tex/publishing packages
(as well as corresponding non-R dependencies).


## Build
Docker needs to be installed to build and run this image. Please refer to the
[Docker webpage](https://www.docker.com/) or any of the other many tutorials on
the web on how to install and use Docker.

Since renv is added to the rocker/verse base image, a new image needs to build.
Within this directory run:

    docker build -t general_r_env:4.0.1 .


## Run a container
Run an instance of this image as follows:

    docker run -d -p 8787:8787 -v d:\Workspace:/home/rstudio/workspace -e DISABLE_AUTH=true --name general_r_env --restart=unless-stopped general_r_env:4.0.1

This will:

* Run the Docker container with an RStudio Server
* Expose the RStudio Server port from the container to the host
* Mount a local folder into the container (e.g. the workspace with projects)
* Disable RStudio Server authentification (only use locally, otherwise set as password via `-e PASSWORD=yourpassword`)
* Name the container for better differentiation
* Enable constant container restart, so it is always available (also make sure to enable Docker on computer boot up)


## Accessing RStudio
RStudio should be now available in a browser via
[http://localhost:8787/](http://localhost:8787/).


## Project environment
In an R/RStudio project, create a distinct environment as follows
(refer to the [renv docs](https://rstudio.github.io/renv/articles/renv.html) for
more details):

    # init the environment
    # (will try to install dependencies automatically in an existing project)
    renv::init()
    # install additional packages
    # (also, sometimes missing dependencies need a re-install of a package)
    install.packages(...)
    # make snapshot of environment
    renv::snapshot()
    
For easy restoration of the environment in a different container (e.g. on
another computer, preferably from the same image), add these renv files to the
project git repository:

    git add .Rprofile renv.lock renv/.gitignore renv/activate.R renv/settings.dcf
    
After check out the repository, restore the renv environment in the container's
R/RStudio session:

    renv::restore()
    
Note: This may redownload all packages in the environment if the renv cache is
empty (which is the case for a new container). However, while renv::restore
currently does not consider to recycle packages from the system library (as
actually already provided in the image, more details below), package versions
should be still the
same.
    
 
## Additional Notes

`init` should make use of the local and system libraries, i.e. cache them if not
already done. It is not clear to me currently, if the following option change\
upfront is necessary for that ot not:

    options(renv.option.sandbox.enabled = FALSE)
    
Restoring might not use local or system library packages, if not cached yet
(e.g. by the inititalization of another project). Hence, an preceding `hydrate`
might move available packages to the cache, before confirming and correcting
version with `restore`:

    renv::hydrate() # potential workaround to get system libraries into to cache
    renv::restore()
    
More details on this maybe found in
[this issue](https://github.com/rstudio/renv/issues/492).

In comparison to the desktop version, RStudio Server doesn't allow to open
several projects in different windows at the same time. A workaround could be to
have a couple of containers from the same image running with a different name and
port. This would require restoring a projects environment everytime a project is
used in a container for the first the time (as the cache might be incomplete).

In this context it should also be noted that an renv environment is located
within a projects folder. From there, symlinks point the packages in the renv
cache. In the Docker scenario, this cache is within an container. Hence opening
a project in another container (preferably from the same image, R and renv
version) requires restoring the environment, as the cache might be not complete
for this project and symlinks might not be valid.
