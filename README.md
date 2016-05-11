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

## Configuration
The testsuite needs some Linux tools for run properly:
 * wget
 * voms-clients

For install them, in RedHat-based distribution, run:

```bash
# yum install -y wget voms-clients
```

For run the testsuite, you need Robot Framework. Install it with:

```bash
# yum install -y python-pip
# pip install robotframework docutils
```

## Run manually
The testsuite must run on the same node where Argus services are installed.

Then execute the entire testsuite:
```bash
# cd argus-robot-testsuite
# pybot --pythonpath .:lib  -d /tmp/robot  tests/
```
You can also run test for a single service, or a single test case, specifying the sub-directory or the single file as last argument in the comment above.



## Run with Docker
TBD





