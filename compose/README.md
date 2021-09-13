# How to run the tests locally

1. ```console
   $ docker-compose up trust
   ```
2. ```console
   $ docker-compose up -d argus testsuite
   ```
3. setup and start the services
   ```console
   $ docker-compose exec argus bash /scripts/setup-argus.sh  
   $ docker-compose exec argus bash /scripts/start-argus.sh
   ```
4. setup and run tests
   ```console
   $ docker-compose exec testsuite bash /scripts/setup-testsuite.sh
   $ docker-compose exec --workdir /home/test/argus-testsuite testsuite bash /home/test/argus-testsuite/run-testsuite.sh
   ```
For customizing the tests execution use the `ROBOT_ARGS` environment variable, *e.g.*
```console
$ docker-compose exec --workdir /home/test/argus-testsuite testsuite bash -c "ROBOT_ARGS='-e iota' /home/test/argus-testsuite/run-testsuite.sh"
```
to exclude `iota` tests.