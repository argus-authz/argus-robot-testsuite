# argus-robot-testsuite
A function testsuite for Argus based on Robot Framework

## Synopsis
This test suite provides a bunch of tests for validate the components of Argus:

1. PAP tests
   * Add, remove, update and list policies from the repository
   * Ban and Unban users
   * Configuration parameters
2. PDP tests
   * Configuration parameters
3. PEP tests
   * Authorization request
   * Different user mapping scenarios
   * Configuration parameters

Test cases are classified in two type:

  * local: must be executed on the same host where Argus services run and they require root privileges to run.
  * remote: can be run from external host, because they interact with Argus endpoints.



## Configuration
The testsuite needs some Linux tools for run properly:
 * EPEL repo
 * wget
 * voms-clients

For install them, in RedHat-based distribution, run:

```bash
# yum install -y epel-release
# yum install -y wget voms-clients
```

For run the testsuite, you need Robot Framework. Install it with:

```bash
# yum install -y python-pip
# pip install robotframework
```

## Run manually
The testsuite must run on the same node where Argus services are installed.

Then execute the entire testsuite:
```bash
# cd argus-robot-testsuite
# pybot --pythonpath .:lib  -d /tmp/robot  tests/
```
You can also run test for a single service, or a single test case, specifying the sub-directory or the single file as last argument in the comment above.
Some useful option are:
```
  --exclude=<tag>      : execute all test except those tagged with "tag"
  --include=<tag>      : execute only tests tagged with "tag"
  -d /path/to/some/dir : specify directory where write final output, log and report
  -t "Test name"       : execute only the test named with "Test name"
```



## Run with Docker
This testsuite provides a Docker image for run the tests. All the needed files are located in _docker_ folder.

First, build the new image:
```bash
$ ./build-image.sh
```
This shell script creates a new docker image, named _italiangrid/argus-testsuite_ in the local image repository.
Then run the container:
```bash
$ docker run italiangrid/argus-testsuite:latest
```
The last command launch a container that run the testsuite with default setup. For customize the execution, provide to Docker the proper environment variables with _-e_ option.
For example:
```bash
$ docker run -e TESTSUITE_REPO=file:///tmp/local_repo/argus-robot-testsuite -e TESTSUITE_REPO=issue/issue-1 -e T_PDP_ADMIN_PASSWORD=pdpadmin_password -e PAP_HOST=argus-pap.cnaf.test -e PDP_HOST=argus-pdp.cnaf.test -e PEP_HOST=argus-pep.cnaf.test italiangrid/argus-testsuite:latest
```

**Warnings**

1. This Docker implementation runs only test cases with the _remote_ tag: these tests interact with Argus endpoints. Other tests, that require direct access to the Argus host and root privileges, are not executed.
2. Ensure that PDP admin port (default 8153) is both open and reachable from the Docker container that run the testsuite. Usually admin port listens only on `localhost`: to change this behavior, set `adminHost=0.0.0.0` in `pdp.ini` configuration file.
3. Expose admin ports outside localhost, is useful for test purposes, but dangerous for security: don't do this in production!

##### Available environment variables

| Variable             | Default                                                      | Meaning |
| -------------------- | ------------------------------------------------------------ | ------- |
| TESTSUITE_REPO       | https://github.com/marcocaberletti/argus-robot-testsuite.git | Repository hosting testsuite code |
| TESTSUITE_BRANCH     | master                                                       | Git branch to checkout |
| T_PDP_ADMIN_PASSWORD | pdpadmin_password                                            | Password use to communicate to PDP admin service |
| PAP_HOST             | argus-pap.cnaf.test                                          | Argus PAP service hostname |
| PDP_HOST             | argus-pdp.cnaf.test                                          | Argus PDP service hostname |
| PEP_HOST             | argus-pep.cnaf.test                                          | Argus PEP service hostname |
| OUTPUT_REPORTS       | /home/tester/argus-robot-testsuite/reports                   | Directory where RobotFramework save execution report and tests outputs |





