#!/usr/bin/env python

import os
import yaml

def main():
    hosts = os.environ.get("HOSTS")
    versions = os.environ.get("VERSIONS")
    if not hosts or not versions:
        return
    hosts = hosts.split(",")
    versions = versions.split(",")

    pipeline = {"steps": []}
    for host in hosts:
        for version in versions:

            pipeline['steps'].append({
                'label': 'sync {} {}'.format(host, version),
                'command': 'cd /lineage/{} && repo init -u https://github.com/lineageos/android.git -b {} && repo sync --prune --no-tags --force-remove-dirty --force-sync --verbose -j128'.format(version, version),
                'agents': ['queue={}'.format(host)],
            })

    print(yaml.dump(pipeline))

if __name__ == '__main__':
    main()