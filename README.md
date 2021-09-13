# argus-robot-testsuite

A function testsuite for Argus based on Robot Framework

## Synopsis

This test suite provides a bunch of tests for validate the components of Argus:

1. PAP tests
   * Add, remove, update and list policies from the repository
   * Ban and Unban users
   * Check status
   * Configuration parameters
2. PDP tests
   * Check status
   * Configuration parameters
   * Policies management
3. PEP tests
   * Authorization requests
   * Different user mapping scenarios
   * Check status
   * Configuration parameters

Test cases are classified in four types:

  * local: must be executed on the same host where Argus services run and they require root privileges to run.
  * remote: can be run from external host, because they interact with Argus endpoints.
  * cli: test the command line, both in local and remote configuration.
  * iota: requires iota CA installed (excluded by default from CI).



## Configuration
The testsuite needs some Linux tools for run properly:
 * EPEL repo
 * wget
 * curl
 * voms-clients

For install them, in RedHat-based distribution, run:

```console
$ sudo yum install -y epel-release
$ sudo yum install -y wget voms-clients
```

For run the testsuite, you need Robot Framework. Install it with:

```console
$ sudo yum install -y python-pip
$ sudo pip install robotframework
```

## Run manually
To run local tests the testsuite requires an ssh key pair on the node where Argus services are installed.

Then execute the entire testsuite:

```console
$ cd argus-robot-testsuite
$ pybot --pythonpath .:lib  -d /tmp/robot  tests/
```
You can also run test for a single service, or a single test case, specifying the sub-directory or the single file as last argument in the comment above.
Some useful option are:

```
  --exclude=<tag>      : execute all test except those tagged with "tag"
  --include=<tag>      : execute only tests tagged with "tag"
  -d /path/to/some/dir : specify directory where write final output, log and report
  -t "Test name"       : execute only the test named with "Test name"
```

To run remote tests only, just type:

```console
$ cd argus-robot-testsuite
$ robot --pythonpath .:lib -d /tmp/robot -e local tests/
```
**Warnings**

1. This implementation is safe just for test cases with the _remote_ tag: these tests interact with Argus endpoints. On the other hand, _local_ tests require direct access to the Argus host and root privileges; don't do run them production!
2. Ensure that PDP admin port (default 8153) is both open and reachable from the testsuite host. Usually admin port listens only on `localhost`: to change this behavior, set `adminHost=0.0.0.0` in `pdp.ini` configuration file.
3. Expose admin ports outside `localhost`, is useful for test purposes, but dangerous for security: don't do this in production!

## Run with Docker
This testsuite provides a `docker-compose.yml` file with three services:
* `trust`
* `argus`: a centos7 container where the services run
* `testsuite`: runned against the services.
  
An ssh key pair is already set up in the container to run both *remote* and *local* tests. *Iota* tests are excluded by default.  
All the needed files are located in _compose_ folder.

Explanation on *How to run the tests locally* can be found [here](compose/README.md).


##### Available environment variables

| Variable             | Default                                                      | Meaning |
| -------------------- | ------------------------------------------------------------ | ------- |
| TESTSUITE_REPO       | https://github.com/marcocaberletti/argus-robot-testsuite.git | Repository hosting testsuite code |
| TESTSUITE_BRANCH     | master                                                       | Git branch to checkout |
| T_PDP_ADMIN_PASSWORD | pdpadmin_password                                            | Password use to communicate to PDP admin service |
| PAP_HOST             | argus-centos7.cnaf.test                                       | Argus PAP service hostname |
| PDP_HOST             | argus-centos7.cnaf.test                                       | Argus PDP service hostname |
| PEP_HOST             | argus-centos7.cnaf.test                                       | Argus PEP service hostname |
| OUTPUT_REPORTS       | /home/tester/argus-robot-testsuite/reports                   | Directory where RobotFramework save execution report and tests outputs |

