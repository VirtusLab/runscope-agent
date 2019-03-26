# runscope-agent

A Docker image for running the [runscope agent](https://www.runscope.com/docs/radar/agent).

[![Version](https://img.shields.io/badge/version-v0.0.1-brightgreen.svg)](https://github.com/VirtusLab/runscope-agent/releases/tag/v0.0.1)
[![Build Status](https://travis-ci.org/VirtusLab/runscope-agent.svg?branch=master)](https://travis-ci.org/VirtusLab/runscope-agent)
[![Docker Repository on Quay](https://quay.io/repository/VirtusLab/runscope-agent/status "Docker Repository on Quay")](https://quay.io/repository/VirtusLab/runscope-agent)

## Using the docker image

```bash
docker run --rm quay.io/virtuslab/runscope-agent --help
Usage of radar:
  --agent-id string
        Agent uuid
  --api-host string
        Api host base url
  --cafile string
        CA certificate file
  -f, --configfile string
        Config file
  --debug
        Enable debugging web server
  --disconnect-timeout string
        Disconnect timeout (default "5")
  --ignore-env-proxy
        Ignore HTTP_PROXY and HTTPS_PROXY environment variables
  -l, --logfile string
        Logfile to write to
  --name string
        Agent name
  --pidfile string
        Pid file
  --team-id string
        team uuid
  -w, --threads int
        Number of worker threads (default 10)
  --timeout int
        Connection idle timeout (default 20)
  -t, --token string
        Runscope Auth Token
  -v, --verbose
        Log more information
  --verify-ssl string
        Verify SSL?  (true/false) (default "true")
  --version
        Get version number
  --web-host string
        Web host base url (default "https://www.runscope.com")
```
## Contribution

Feel free to file [issues](https://github.com/VirtusLab/runscope-agent/issues) 
or [pull requests](https://github.com/VirtusLab/runscope-agent/pulls).