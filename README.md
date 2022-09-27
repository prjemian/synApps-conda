# synApps-conda

Build synApps into a conda package.  Make it easy to run a new pre-built EPICS IOC.

Provide EPICS IOCs with custom names using `conda` package(s).  Hope to speed up
the time to provision test environments for continuous integration and also to
create new versions as the upstream packages are revised.  Additional benefit
will be for any APS user to run these without need for additional sysAdmin
support.

Could create `docker` images that uses these package(s).
