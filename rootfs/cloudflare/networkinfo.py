import ipaddress
import netifaces as ni
            
class NetworkingInfo:
    def __init__(self, ifname="eth0"):
        self.ifname = ifname

    def checkIPv4(self, IP):  
        try:
            address = ipaddress.IPv4Address(IP)
        except ipaddress.AddressValueError:
            return False
        else:
            return True

    def checkIPv6(self, IP):  
        try:
            address = ipaddress.IPv6Address(IP)
        except ipaddress.AddressValueError:
            return False
        else:
            return True

    def getifaddr4(self):
        ipv4=[]
        for ifconf in ni.ifaddresses(self.ifname)[ni.AF_INET]:
            ipv4.append(ifconf['addr'])
        
        if(len(ipv4) >= 1):
            if(self.checkIPv4(ipv4[0])):
                return ipv4[0]
        
        return False

    def getifaddr6(self):
        ipv6=[]
        for ifconf in ni.ifaddresses(self.ifname)[ni.AF_INET6]:
            if not ifconf['addr'].startswith('fe80:'):
                ipv6.append(ifconf['addr'])
        
        if(len(ipv6) >= 1):
            if(self.checkIPv6(ipv6[0])):
                return ipv6[0]
        
        return False

