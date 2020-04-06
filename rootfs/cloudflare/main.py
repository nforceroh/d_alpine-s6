from cloudflare import Cloudflare
from init import Init
import json
import os
import re



def main():

    init = Init()

    if init.provider_token != None and init.provider_zone != None:
        cf = Cloudflare(token=init.provider_token, zonename=init.provider_zone)
        # try:
        #     cf = Cloudflare(token=init.provider_token, zonename=init.provider_zone)
        # except ValueError as e:
        #     print("Could not connect to DNS provider, check your token and zone")
        #     return
        if cf:
            for entry in init.parsed_dns_records:
                if(entry.get('valid') == True):
                    if(entry.get('type').upper() == 'CNAME'):
                        cf.createDNSrecord( entry.get('name'), entry.get('target'), entry.get('type'))
                    else:
                        print("Creating {} {} {}".format(entry.get('name'), entry.get('type'), entry.get('IP')))
                        cf.createDNSrecord(entry.get('name'), entry.get('IP'), entry.get('type'))


if __name__ == "__main__":
    main()
