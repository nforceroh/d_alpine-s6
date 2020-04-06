from networkinfo import NetworkingInfo
from ipinfo import IPinfo
import json
import os
import re


class Init:
    def __init__(self):
        self.provider_zone = None
        self.provider_token = None
        self.dns_records = None
        self.parsed_dns_records = []

        self.parse_env()
        if self.dns_records is not None:
            self.parse_records()
            self.validate_records()

    def parse_env(self):
        for item, value in os.environ.items():
            if re.match("^dns_provider_token", item, re.IGNORECASE):
                print(item, value)
                self.provider_token = value
            if re.match("^dns_provider_zone", item, re.IGNORECASE):
                print(item, value)
                self.provider_zone = value
            if re.match("^dns_records", item, re.IGNORECASE):
                try:
                    self.dns_records = json.loads(value)
                except ValueError as error:
                    print("invalid json: %s" % error)

    def validate_entry(self, item, defaultvalue):
        if len(self.parsed_dns_records) > 0:
            if self.parsed_dns_records[0].get(item):
                return self.parsed_dns_records[0].get(item)
        else:
            return defaultvalue

    def parse_records(self):
        default_entry = {
            "valid": False,
            "device": "external",
            "type": "A",
            "ttl": "600",
            "name": None,
            "target": None,
            "IP": None,
        }
        for entry in self.dns_records:
            new_entry = {}
            for item, value in default_entry.items():
                if item in entry:
                    new_entry[item] = entry.get(item)
                if item not in entry:
                    new_entry[item] = self.validate_entry(item, value)

            if "name" in entry:
                new_entry["name"] = entry.get("name")
            if "name" not in entry:
                temp = self.validate_entry("name", None)
                if temp is None:
                    print("No FQDN name set, cannot continue")
                else:
                    new_entry["name"] = temp

            if new_entry["type"].upper() == "CNAME":
                if "target" in entry:
                    new_entry["target"] = entry.get("target")
                if "target" not in entry:
                    temp = self.validate_entry("target", None)
                    if temp is None:
                        print("No CNAME target set, cannot continue")
                    else:
                        new_entry["target"] = temp

            if new_entry["device"].lower() == "external":
                ipinfo = IPinfo()
                if new_entry["type"].upper() == "A":
                    new_entry["IP"] = ipinfo.getExternalIP(4)
                if new_entry["type"].upper() == "AAAA":
                    new_entry["IP"] = ipinfo.getExternalIP(6)
            else:
                ni = NetworkingInfo(ifname=new_entry["device"])
                if new_entry["type"].upper() == "A":
                    new_entry["IP"] = ni.getifaddr4()
                if new_entry["type"].upper() == "AAAA":
                    new_entry["IP"] = ni.getifaddr6()

            self.parsed_dns_records.append(new_entry)

    def validate_records(self):
        for entry in self.parsed_dns_records:
            if entry["type"].upper() == "CNAME":
                if entry["IP"] is not None:
                    if entry["name"] is not None:
                        if entry["target"] is not None:
                            entry["valid"] = True

            if entry["type"].upper() == "A":
                if entry["IP"] is not None:
                    if entry["name"] is not None:
                        entry["valid"] = True

            if entry["type"].upper() == "AAAA":
                if entry["IP"] is not None:
                    if entry["name"] is not None:
                        entry["valid"] = True
