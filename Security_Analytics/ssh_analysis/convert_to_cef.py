import csv,os,json

import datetime

def escape_cef_value(value):
    return str(value).replace("\\","\\\\").replace("=","\=").replace("\n","\\n")

def get_extension_field(payload,source_field,target_field):
    if source_field in payload:
        return " %s=%s" % (target_field,escape_cef_value(payload[source_field]))
    return ""

def add_custom_string(payload,source_field,num,output_field=None):
    if source_field in payload:
        return " cs%s=%s cs%sLabel=%s" % (num,escape_cef_value(payload[source_field]),num,output_field if output_field else source_field)
    return ""

def add_custom_floating(payload,source_field,num,output_field=None):
    if source_field in payload:
        return " cfp%s=%s cfp%sLabel=%s" % (num,escape_cef_value(payload[source_field]),num,output_field if output_field else source_field)
    return ""

with open('cowrie.cef', 'w') as csvfile:
    device_vendor = "Unix"
    device_product = "Unix"
    device_version = "5.0"
    i=0
    cef_writer = csv.writer(csvfile, delimiter='|', escapechar='\\', quoting=csv.QUOTE_NONE)
    for subdir,dirs, files in os.walk("./cowrie-ssh-honeypot-json"):
        for file in files:
            print("Processing %s"%file)
            for line in open(subdir+'/'+file,'r'):
                i+=1
                payload = json.loads(line)
                timestamp = datetime.datetime.strptime(payload["timestamp"][:19],"%Y-%m-%dT%H:%M:%S").strftime("%b %d 2016 %H:%M:%S")
                device_event_id=payload["eventid"]
                deviceDirection = 0
                if "dst_ip" in payload:
                    deviceDirection = 0 if payload["dst_ip" ]== "192.168.1.105" else 1
                if "src_ip" in payload:
                    deviceDirection = 1 if payload["src_ip"] == "192.168.1.105" else 0

                categoryOutcome = "failure" if "failed" in device_event_id else ("success" if "success" in device_event_id else None)
                extension = get_extension_field(payload, "username", "destinationUserName")
                extension += " %s=%s" % ("externalId", escape_cef_value(str(i)))
                extension += " %s=%s" % ("startTime", timestamp)
                extension += " %s=%s" % ("destinationHostName", "elastic_honeypot")
                extension += " %s=%s" % ("destinationAddress", "192.168.20.2")
                extension += " %s=%s" % ("deviceReceiptTime", timestamp)
                extension += " %s=%s" % ("deviceTimeZone", "Z")
                extension += " %s=%s" % ("transportProtocol", "TCP")
                extension += " %s=%s" % ("applicationProtocol", "SSHv2")
                extension += " %s=%s" % ("destinationServiceName", "sshd")
                extension += " %s=%s" % ("devicePayloadId", str(i))
                extension += get_extension_field(payload, "message", "message")
                extension += get_extension_field(payload, "dst_ip", "destinationAddress")
                extension += get_extension_field(payload, "dst_ip", "destinationTranslatedAddress")
                extension += get_extension_field(payload, "dst_ip", "deviceTranslatedAddress")
                extension += get_extension_field(payload, "dst_ip", "deviceAddress")
                extension += get_extension_field(payload, "dst_port", "destinationTranslatedPort")
                extension += get_extension_field(payload, "dst_port", "destinationPort")
                extension += " %s=%s" % ("categoryOutcome", categoryOutcome)
                extension += " %s=%s" % ("categoryBehaviour", device_event_id)
                extension += get_extension_field(payload, "src_ip", "sourceTranslatedAddress")
                extension += get_extension_field(payload, "src_ip", "sourceAddress")
                extension += get_extension_field(payload, "src_port", "sourceTranslatedPort")
                extension += get_extension_field(payload, "src_port", "sourcePort")
                extension += " %s=%s" % ("deviceDirection", deviceDirection)
                extension += get_extension_field(payload, "url", "request")
                extension += get_extension_field(payload, "fingerprint", "fileHash")
                if deviceDirection == 0:
                    extension += get_extension_field(payload, "size", "bytesIn")
                else:
                    extension += get_extension_field(payload, "size", "bytesOut")
                extension += add_custom_string(payload, "isError", "1")
                extension += add_custom_string(payload, "system", "2")
                extension += add_custom_string(payload, "password", "3")
                extension += add_custom_string(payload, "session", "4")
                extension += add_custom_string(payload, "version", "5", "sshVersion")
                extension += add_custom_string(payload, "input", "5", "command")
                extension += add_custom_floating(payload,"duration","1")
                cef_writer.writerow(["CEF:0",device_vendor,device_product,device_version,device_event_id,payload["message"],"Unknown",extension.strip()])