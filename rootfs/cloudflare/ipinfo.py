import requests

class IPinfo:
    def __init__(self):
        self.version=4

    def getExternalIP(self, version=4):
        # This list is adjustable - plus some v6 enabled services are needed
        # url = 'http://myip.dnsomatic.com'
        # url = 'http://www.trackip.net/ip'
        # url = 'http://myexternalip.com/raw'
        # url = 'https://api.ipify.org'
        if version == 6:
            url = 'http://ipv6bot.whatismyipaddress.com'
        else:
            url = 'http://ipv4bot.whatismyipaddress.com'

        try:
            ip_address = requests.get(url).text
        except:
            ip_address = None
        if ip_address == '':
            ip_address = None

        return ip_address