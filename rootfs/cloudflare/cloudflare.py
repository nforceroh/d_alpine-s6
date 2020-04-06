import CloudFlare
import json

class Cloudflare:
    def __init__(self, token, zonename):
        self.token = token
        self.zonename = zonename
        self.cf = CloudFlare.CloudFlare(token=self.token)
        self.zoneid = self.getZoneID()
#        print(self.zoneid, self.zonename)

    def getZoneID(self):
        try:
            zones = self.cf.zones.get(params={'name': self.zonename})
        except CloudFlare.exceptions.CloudFlareAPIError as e:
            exit('/zones.get %d %s - api call failed' % (e, e))
        except Exception as e:
            exit('/zones.get - %s - api call failed' % (e))
        if len(zones) == 0:
            exit('No zones found')

        # extract the zone_id which is needed to process that zone
        zone = zones[0]
        return zone['id']

    def getDNSrecords(self):
        # request the DNS records from that zone
        pg = 0
        while True:
            pg += 1
            dns_records = self.cf.zones.dns_records.get(
                self.zoneid, params={'per_page': 10, 'page': pg})
            if len(dns_records) == 0:
                break

            for dns_record in dns_records:
                r_name = dns_record['name']
                r_type = dns_record['type']
                r_value = dns_record['content']
                r_id = dns_record['id']
                print('\t', r_id, r_name, r_type, r_value)

    def createDNSrecord(self, dns_name, ip_address, ip_address_type):
        try:
            params = {'name':dns_name, 'match':'all', 'type':ip_address_type}
            dns_records = self.cf.zones.dns_records.get(self.zoneid, params=params)
        except CloudFlare.exceptions.CloudFlareAPIError as e:
            exit('/zones/dns_records %s - %d %s - api call failed' % (dns_name, e, e))

        updated = False
        # update the record - unless it's already correct
        for dns_record in dns_records:
            old_ip_address = dns_record['content']
            old_ip_address_type = dns_record['type']

            if ip_address_type not in ['A', 'AAAA', 'CNAME']:
                # we only deal with A / AAAA / CNAME records
                continue

            if ip_address_type != old_ip_address_type:
                # only update the correct address type (A or AAAA)
                # we don't see this becuase of the search params above
                print('IGNORED: %s %s ; wrong address family' % (dns_name, old_ip_address))
                continue

            if ip_address == old_ip_address:
                print('UNCHANGED: %s %s' % (dns_name, ip_address))
                updated = True
                continue

            dns_record_id = dns_record['id']
            dns_record = {
                'name':dns_name,
                'type':ip_address_type,
                'content':ip_address,
                'proxied':False
            }
            try:
                dns_record = self.cf.zones.dns_records.put(self.zoneid, dns_record_id, data=dns_record)
            except CloudFlare.exceptions.CloudFlareAPIError as e:
                exit('/zones.dns_records.put %s - %d %s - api call failed' % (dns_name, e, e))
            print('UPDATED: %s %s -> %s' % (dns_name, old_ip_address, ip_address))
            updated = True

        if updated:
            return

        # no exsiting dns record to update - so create dns record
        dns_record = {
            'name':dns_name,
            'type':ip_address_type,
            'content':ip_address
        }
        try:
            dns_record = self.cf.zones.dns_records.post(self.zoneid, data=dns_record)
        except CloudFlare.exceptions.CloudFlareAPIError as e:
            exit('/zones.dns_records.post %s - %d %s - api call failed' % (dns_name, e, e))
        print('CREATED: %s %s' % (dns_name, ip_address))
